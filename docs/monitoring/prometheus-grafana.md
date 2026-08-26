---
layout: doc
title: Prometheus + Grafana 搭建
description: 从零搭建 Prometheus 时序数据存储与 Grafana 可视化监控仪表盘，实时展示昇腾 NPU 的温度、功耗、显存、算力利用率及 HCCS 链路状态。
---

# Prometheus + Grafana 搭建

> 本章将带您从零搭建 Prometheus 数据存储和 Grafana 可视化仪表盘，让昇腾 NPU 的运行状态一目了然。

---

## 环境准备

### 系统要求

| 组件 | 最低配置 | 推荐配置 |
|------|----------|----------|
| CPU | 2 核 | 4 核+ |
| 内存 | 4 GB | 8 GB+ |
| 磁盘 | 50 GB SSD | 200 GB SSD（按集群规模调整） |
| 操作系统 | CentOS 7.6 / Ubuntu 18.04+ | Ubuntu 22.04 / openEuler 22.03 |

### 安装 Prometheus

```bash
# 下载 Prometheus（以 2.45.0 为例）
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar -xzf prometheus-2.45.0.linux-amd64.tar.gz
mv prometheus-2.45.0.linux-amd64 prometheus

# 创建数据目录
mkdir -p /data/prometheus

# 创建专用用户
useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /opt/prometheus /data/prometheus
```

**创建 systemd 服务：**

```ini
# /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring System
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/opt/prometheus/prometheus \
  --config.file=/opt/prometheus/prometheus.yml \
  --storage.tsdb.path=/data/prometheus \
  --storage.tsdb.retention.time=30d \
  --web.console.templates=/opt/prometheus/consoles \
  --web.console.libraries=/opt/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl status prometheus

# 验证：浏览器访问 http://<server-ip>:9090
```

### 安装 Grafana

```bash
# Ubuntu/Debian
sudo apt-get install -y apt-transport-https software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana

# CentOS/RHEL
sudo cat <<EOF | sudo tee /etc/yum.repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOF
sudo yum install -y grafana

# 启动
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# 验证：浏览器访问 http://<server-ip>:3000（默认账号 admin/admin）
```

---

## 配置 Prometheus 采集 NPU 指标

### prometheus.yml 完整配置

```yaml
# /opt/prometheus/prometheus.yml
# Prometheus 配置文件 - 昇腾 NPU 监控

global:
  scrape_interval: 15s          # 全局采集间隔
  evaluation_interval: 15s      # 规则评估间隔
  scrape_timeout: 10s           # 采集超时

# 告警规则文件
rule_files:
  - "rules/ascend_alerts.yml"
  - "rules/ascend_recording.yml"

# AlertManager 配置
alerting:
  alertmanagers:
    - static_configs:
        - targets:
            - "localhost:9093"

# 采集目标配置
scrape_configs:
  # ============ NPU Exporter ============
  # 采集各计算节点的 NPU 指标
  - job_name: "ascend-npu"
    scrape_interval: 15s
    metrics_path: /metrics
    static_configs:
      - targets:
          # 计算节点1
          - "10.10.1.101:9100"
          - "10.10.1.102:9100"
          # 计算节点2
          - "10.10.2.101:9100"
          - "10.10.2.102:9100"
        labels:
          cluster: "ascend-prod"
          region: "dc1"
    # 按节点添加 hostname 标签
    relabel_configs:
      - source_labels: [__address__]
        target_label: hostname
        regex: '([^:]+):.*'
        replacement: '${1}'

  # ============ Node Exporter（主机指标） ============
  - job_name: "node"
    static_configs:
      - targets:
          - "10.10.1.101:9101"
          - "10.10.1.102:9101"
          - "10.10.2.101:9101"
          - "10.10.2.102:9101"
        labels:
          cluster: "ascend-prod"

  # ============ Prometheus 自身监控 ============
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  # ============ 使用文件发现（大规模集群推荐） ============
  # - job_name: "ascend-npu-file-sd"
  #   file_sd_configs:
  #     - files:
  #         - "/opt/prometheus/targets/ascend-npu.yml"
  #       refresh_interval: 30s
```

### 文件服务发现配置（大规模集群）

```yaml
# /opt/prometheus/targets/ascend-npu.yml
- targets:
    - "10.10.1.101:9100"
    - "10.10.1.102:9100"
  labels:
    cluster: "ascend-prod"
    rack: "R01"
    role: "training"

- targets:
    - "10.10.2.101:9100"
    - "10.10.2.102:9100"
  labels:
    cluster: "ascend-prod"
    rack: "R02"
    role: "inference"
```

### 热加载配置

```bash
# 修改配置后，无需重启即可生效
curl -X POST http://localhost:9090/-/reload

# 检查配置语法
/opt/prometheus/promtool check config /opt/prometheus/prometheus.yml
```

### 录制规则（Recording Rules）

将常用查询预计算为持久指标，提升 Grafana 查询性能：

```yaml
# /opt/prometheus/rules/ascend_recording.yml
groups:
  - name: ascend_recording_rules
    interval: 30s
    rules:
      # 显存利用率
      - record: ascend:npu:memory_utilization_percent
        expr: |
          ascend_npu_memory_used_bytes / ascend_npu_memory_total_bytes * 100

      # 在线 NPU 数量
      - record: ascend:npu:online_count
        expr: count(ascend_npu_health)

      # 异常 NPU 数量
      - record: ascend:npu:unhealthy_count
        expr: count(ascend_npu_health > 0)

      # 高温 NPU 数量
      - record: ascend:npu:high_temp_count
        expr: count(ascend_npu_temperature_celsius > 80)

      # 每节点平均算力利用率
      - record: ascend:npu:avg_aicore_utilization
        expr: avg by (hostname) (ascend_npu_aicore_utilization_percent)

      # 每节点平均显存利用率
      - record: ascend:npu:avg_memory_utilization
        expr: avg by (hostname) (ascend_npu_memory_utilization_percent)

      # ECC 错误增长率（每分钟）
      - record: ascend:npu:ecc_ce_rate_per_min
        expr: rate(ascend_npu_ecc_correctable_errors_total[5m]) * 60
```

---

## 配置 Grafana 数据源

### 添加 Prometheus 数据源

1. 登录 Grafana → 左侧菜单 **Connections** → **Data Sources**
2. 点击 **Add data source** → 选择 **Prometheus**
3. 填写配置：

| 配置项 | 值 |
|--------|-----|
| Name | `Ascend-Prometheus` |
| URL | `http://localhost:9090` |
| Access | `Server` |
| Scrape interval | `15s` |
| Query timeout | `30s` |

4. 点击 **Save & Test**，看到 "Data source is working" 即成功

### 使用 Provisioning 自动配置

```yaml
# /etc/grafana/provisioning/datasources/ascend.yml
apiVersion: 1

datasources:
  - name: Ascend-Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
    editable: true
    jsonData:
      timeInterval: "15s"
      httpMethod: POST
```

---

## 创建 NPU 监控仪表盘

### 仪表盘规划

| 面板编号 | 面板名称 | 可视化类型 | 数据来源 |
|----------|----------|------------|----------|
| 1 | 集群 NPU 概览 | Stat | `ascend_npu_count` |
| 2 | 异常设备统计 | Stat | `ascend:npu:unhealthy_count` |
| 3 | 设备健康状态矩阵 | Table | `ascend_npu_health` |
| 4 | 温度分布 | Heatmap | `ascend_npu_temperature_celsius` |
| 5 | 功耗趋势 | Time Series | `ascend_npu_power_watts` |
| 6 | 显存利用率 | Time Series | `ascend:npu:memory_utilization_percent` |
| 7 | 算力利用率 | Time Series | `ascend_npu_aicore_utilization_percent` |
| 8 | HCCS 链路状态 | Table | `ascend_npu_hccs_link_status` |
| 9 | ECC 错误趋势 | Bar Chart | `ascend_npu_ecc_*` |

### 面板 1：集群 NPU 概览（Stat 面板）

```
面板类型：Stat
Title：集群 NPU 总数
Query：ascend_npu_count
Unit：short
Thresholds：Base < 8 (red), >= 8 (green)
```

### 面板 2：异常设备统计（Stat 面板）

```
面板类型：Stat
Title：异常 NPU 数量
Query：ascend:npu:unhealthy_count
Unit：short
Thresholds：Base = 0 (green), > 0 (red)
Color mode：background
```

### 面板 3：设备健康状态矩阵（Table 面板）

```
面板类型：Table
Title：NPU 健康状态矩阵
Query：
  ascend_npu_health
Format：Table
Instant：true
Transformations：
  - Organize fields: 只保留 hostname, npu_id, name, Value
  - Value mapping: 0→"OK", 1→"Warning", 2→"Critical", 3→"Fault"
  - Cell display (background color): OK=green, Warning=yellow, Critical=red
```

### 面板 4：温度趋势（Time Series 面板）

```
面板类型：Time Series
Title：NPU 温度趋势
Query：
  ascend_npu_temperature_celsius
Legend：{{hostname}} / NPU-{{npu_id}}
Unit：Temperature (celsius)
Thresholds：80°C (yellow), 85°C (red)
Fill opacity：10
```

PromQL 进阶查询——按节点显示最高温度：

```promql
max by (hostname) (ascend_npu_temperature_celsius)
```

显示超过 80°C 的 NPU：

```promql
ascend_npu_temperature_celsius > 80
```

### 面板 5：功耗趋势（Time Series 面板）

```promql
# 每节点总功耗
sum by (hostname) (ascend_npu_power_watts)

# 单卡功耗
ascend_npu_power_watts
```

### 面板 6：显存利用率（Time Series 面板）

```promql
# 显存利用率百分比
ascend:npu:memory_utilization_percent

# 显存使用量（GB）
ascend_npu_memory_used_bytes / 1024 / 1024 / 1024

# 显存剩余量
(ascend_npu_memory_total_bytes - ascend_npu_memory_used_bytes) / 1024 / 1024 / 1024
```

### 面板 7：算力利用率（Time Series 面板）

```promql
# 单卡 AI Core 利用率
ascend_npu_aicore_utilization_percent

# 集群平均利用率
avg(ascend_npu_aicore_utilization_percent)

# 按节点分组平均
avg by (hostname) (ascend_npu_aicore_utilization_percent)
```

### 面板 8：HCCS 链路状态（Table 面板）

```promql
ascend_npu_hccs_link_status
```

Value Mapping：
- `1` → `UP` (绿色)
- `0` → `DOWN` (红色)
- `2` → `DEGRADED` (黄色)

### 面板 9：ECC 错误趋势（Bar Chart 面板）

```promql
# 可纠正 ECC 错误增长率（每小时）
rate(ascend_npu_ecc_correctable_errors_total[1h]) * 3600

# 不可纠正 ECC 错误累计值
ascend_npu_ecc_uncorrectable_errors_total
```

---

## 仪表盘变量

为了让仪表盘支持按节点、按 NPU 筛选，配置以下变量：

### 变量配置

| 变量名 | 类型 | Query | 说明 |
|--------|------|-------|------|
| `$hostname` | Query | `label_values(ascend_npu_health, hostname)` | 选择计算节点 |
| `$npu_id` | Query | `label_values(ascend_npu_health{npu_id=~"$npu_id"}, npu_id)` | 选择 NPU 编号 |
| `$datasource` | Datasource | `Ascend-Prometheus` | 选择数据源 |

在面板查询中使用变量：

```promql
# 按节点和 NPU 筛选温度
ascend_npu_temperature_celsius{hostname=~"$hostname", npu_id=~"$npu_id"}

# 按节点筛选显存利用率
ascend:npu:memory_utilization_percent{hostname=~"$hostname"}
```

---

## 导入 / 导出仪表盘

### 导出仪表盘 JSON

1. 打开仪表盘 → 点击右上角 **Share** → **Export**
2. 选择 **Export for sharing externally**（包含模板变量）
3. 点击 **Save to file**，下载 JSON 文件

### 导入仪表盘 JSON

1. 左侧菜单 → **Dashboards** → **New** → **Import**
2. 上传 JSON 文件或粘贴 JSON 内容
3. 选择数据源 `Ascend-Prometheus`
4. 点击 **Import**

### 使用 Provisioning 自动导入

```yaml
# /etc/grafana/provisioning/dashboards/ascend.yml
apiVersion: 1

providers:
  - name: "Ascend NPU Dashboards"
    orgId: 1
    folder: "昇腾监控"
    type: file
    disableDeletion: false
    updateIntervalSeconds: 30
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards/ascend
      foldersFromFilesStructure: true
```

将仪表盘 JSON 文件放入 `/var/lib/grafana/dashboards/ascend/` 目录即可自动加载。

---

## 完整仪表盘 JSON 模板

以下是一个可直接导入的 NPU 监控仪表盘 JSON 核心：

```json
{
  "annotations": {
    "list": []
  },
  "editable": true,
  "fiscalYearStartMonth": 0,
  "graphTooltip": 1,
  "id": null,
  "links": [],
  "liveNow": false,
  "panels": [
    {
      "title": "集群 NPU 总数",
      "type": "stat",
      "datasource": {
        "type": "prometheus",
        "uid": "ascend-prometheus"
      },
      "targets": [
        {
          "expr": "ascend_npu_count",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "red", "value": null },
              { "color": "green", "value": 8 }
            ]
          },
          "unit": "short"
        }
      },
      "gridPos": { "h": 4, "w": 4, "x": 0, "y": 0 }
    },
    {
      "title": "异常 NPU 数量",
      "type": "stat",
      "datasource": {
        "type": "prometheus",
        "uid": "ascend-prometheus"
      },
      "targets": [
        {
          "expr": "ascend:npu:unhealthy_count",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "green", "value": null },
              { "color": "red", "value": 1 }
            ]
          },
          "unit": "short",
          "color": { "mode": "background" }
        }
      },
      "gridPos": { "h": 4, "w": 4, "x": 4, "y": 0 }
    },
    {
      "title": "高温 NPU 数量 (>80°C)",
      "type": "stat",
      "datasource": {
        "type": "prometheus",
        "uid": "ascend-prometheus"
      },
      "targets": [
        {
          "expr": "ascend:npu:high_temp_count",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 1 },
              { "color": "red", "value": 3 }
            ]
          },
          "unit": "short"
        }
      },
      "gridPos": { "h": 4, "w": 4, "x": 8, "y": 0 }
    },
    {
      "title": "NPU 温度趋势",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "ascend-prometheus"
      },
      "targets": [
        {
          "expr": "ascend_npu_temperature_celsius{hostname=~\"$hostname\"}",
          "legendFormat": "{{hostname}} / NPU-{{npu_id}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "celsius",
          "custom": {
            "thresholdsStyle": { "mode": "line" }
          },
          "thresholds": {
            "mode": "absolute",
            "steps": [
              { "color": "green", "value": null },
              { "color": "yellow", "value": 80 },
              { "color": "red", "value": 85 }
            ]
          }
        }
      },
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 4 }
    },
    {
      "title": "显存利用率",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "ascend-prometheus"
      },
      "targets": [
        {
          "expr": "ascend:npu:memory_utilization_percent{hostname=~\"$hostname\"}",
          "legendFormat": "{{hostname}} / NPU-{{npu_id}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "max": 100,
          "min": 0,
          "custom": {
            "fillOpacity": 10
          }
        }
      },
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 4 }
    },
    {
      "title": "AI Core 利用率",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "ascend-prometheus"
      },
      "targets": [
        {
          "expr": "ascend_npu_aicore_utilization_percent{hostname=~\"$hostname\"}",
          "legendFormat": "{{hostname}} / NPU-{{npu_id}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "percent",
          "max": 100,
          "min": 0
        }
      },
      "gridPos": { "h": 8, "w": 12, "x": 0, "y": 12 }
    },
    {
      "title": "NPU 功耗",
      "type": "timeseries",
      "datasource": {
        "type": "prometheus",
        "uid": "ascend-prometheus"
      },
      "targets": [
        {
          "expr": "ascend_npu_power_watts{hostname=~\"$hostname\"}",
          "legendFormat": "{{hostname}} / NPU-{{npu_id}}",
          "refId": "A"
        }
      ],
      "fieldConfig": {
        "defaults": {
          "unit": "watt"
        }
      },
      "gridPos": { "h": 8, "w": 12, "x": 12, "y": 12 }
    },
    {
      "title": "NPU 健康状态矩阵",
      "type": "table",
      "datasource": {
        "type": "prometheus",
        "uid": "ascend-prometheus"
      },
      "targets": [
        {
          "expr": "ascend_npu_health{hostname=~\"$hostname\"}",
          "format": "table",
          "instant": true,
          "refId": "A"
        }
      ],
      "transformations": [
        {
          "id": "organize",
          "options": {
            "excludeByName": {
              "Time": true,
              "__name__": true,
              "chip_id": true,
              "cluster": true
            }
          }
        }
      ],
      "fieldConfig": {
        "defaults": {
          "mappings": [
            { "options": { "0": { "text": "OK", "color": "green" } }, "type": "value" },
            { "options": { "1": { "text": "Warning", "color": "yellow" } }, "type": "value" },
            { "options": { "2": { "text": "Critical", "color": "orange" } }, "type": "value" },
            { "options": { "3": { "text": "Fault", "color": "red" } }, "type": "value" }
          ]
        }
      },
      "gridPos": { "h": 8, "w": 24, "x": 0, "y": 20 }
    }
  ],
  "refresh": "15s",
  "schemaVersion": 38,
  "style": "dark",
  "tags": ["ascend", "npu", "monitoring"],
  "templating": {
    "list": [
      {
        "name": "hostname",
        "type": "query",
        "datasource": {
          "type": "prometheus",
          "uid": "ascend-prometheus"
        },
        "query": "label_values(ascend_npu_health, hostname)",
        "refresh": 1,
        "includeAll": true,
        "multi": true
      }
    ]
  },
  "time": {
    "from": "now-6h",
    "to": "now"
  },
  "timepicker": {},
  "timezone": "browser",
  "title": "昇腾 NPU 监控仪表盘",
  "uid": "ascend-npu-dashboard",
  "version": 1,
  "weekStart": ""
}
```

---

## 性能优化建议

### Prometheus 优化

```yaml
# 大集群优化：减少采集频率 + 使用录制规则
global:
  scrape_interval: 30s          # 大集群建议 30s
  evaluation_interval: 30s

# 启用压缩
storage.tsdb:
  retention.time: 30d
  retention.size: 100GB         # 限制磁盘使用
  no-lockfile: false
  wal-compression: true         # 启用 WAL 压缩
```

### Grafana 优化

| 优化项 | 建议 |
|--------|------|
| 查询时间范围 | 仪表盘默认 `now-6h`，避免加载过多数据 |
| 刷新频率 | 生产环境 15s~30s，避免过于频繁 |
| 录制规则 | 复杂查询用 Recording Rules 预计算 |
| 面板数量 | 单仪表盘不超过 20 个面板 |
| 数据源 | 启用 query caching |

### 磁盘容量估算

```
每指标每秒存储大小 ≈ 1.5~2 字节
每节点指标数 ≈ 60 个
节点数 = N
存储天数 = D

所需存储(GB) = N × 60 × 86400 × D × 2 / (1024^3)

示例：100 节点 × 30 天 ≈ 29 GB
```

---

## 常见问题

**Q: Prometheus Target 状态为 `DOWN`？**

A: 排查步骤：
```bash
# 1. 确认 Exporter 正在运行
sudo systemctl status ascend-exporter

# 2. 确认端口可达
curl http://<node-ip>:9100/metrics

# 3. 检查防火墙
sudo iptables -L -n | grep 9100
sudo firewall-cmd --list-ports

# 4. 检查 Prometheus 配置中的 target 地址是否正确
```

**Q: Grafana 查询很慢？**

A: 使用 Recording Rules 预计算复杂查询、缩短时间范围、降低刷新频率。详见上方性能优化部分。

**Q: 如何监控 Prometheus 自身？**

A: Grafana 官方提供 Prometheus 仪表盘（ID: `3662`），可直接导入监控 Prometheus 的采集延迟、内存使用、规则评估耗时等指标。

---

::: tip 下一步
数据可视化搭建完成后，请继续配置 [告警规则与通知](./alerting) 实现自动告警。
:::
