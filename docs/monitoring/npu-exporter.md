---
layout: doc
title: NPU 指标采集
description: 使用 npu-smi 和 prometheus-ascend-exporter 采集昇腾 NPU 的温度、功耗、显存、算力利用率、HCCS 链路及 ECC 错误等核心运维指标。
---

# NPU 指标采集

> 指标采集是整个监控体系的数据源头。本章详解 `npu-smi` 命令的使用方法，以及如何通过 `prometheus-ascend-exporter` 将 NPU 指标接入 Prometheus。

---

## npu-smi 命令详解

`npu-smi`（NPU System Management Interface）是昇腾 NPU 的系统管理工具，类似于 NVIDIA 的 `nvidia-smi`。它随驱动一起安装，是运维人员最常用的诊断工具。

### 基本用法

```bash
# 查看 NPU 概要信息（最常用）
npu-smi info

# 查看指定 NPU 的详细信息
npu-smi info -i 0

# 查看所有 NPU 的详细信息
npu-smi info -t detailed
```

### 常用参数一览

| 参数 | 说明 | 示例 |
|------|------|------|
| `info` | 显示 NPU 概要信息 | `npu-smi info` |
| `info -i <id>` | 显示指定 NPU 信息 | `npu-smi info -i 0` |
| `info -t board` | 查看板卡信息（序列号、固件版本） | `npu-smi info -t board` |
| `info -t health` | 查看健康状态 | `npu-smi info -t health` |
| `info -t ecc` | 查看 ECC 错误统计 | `npu-smi info -t ecc` |
| `info -t power` | 查看功耗信息 | `npu-smi info -t power` |
| `info -t topo` | 查看 HCCS 拓扑 | `npu-smi info -t topo` |
| `info -t hccs` | 查看 HCCS 链路状态 | `npu-smi info -t hccs` |
| `info -t port` | 查看端口信息 | `npu-smi info -t port` |
| `info -t usage` | 查看资源使用情况 | `npu-smi info -t usage` |
| `info -t common` | 查看通用信息 | `npu-smi info -t common` |
| `set` | 设置 NPU 参数 | `npu-smi set -i 0 -c 0 -t power -d 350` |
| `watch` | 定时刷新监控 | `npu-smi info watch` |

### 输出字段含义

执行 `npu-smi info` 的典型输出：

```
+-------------------------------------------------------------------------------------------+
| npu-smi 24.1.rc1                Version: 24.1.rc1                                         |
+----------------------+-----------------+-----------------------------------------------------+
| NPU   Name           | Health          | Power(W)    Temp(C)           Hugepages-Use(page) |
| Chip                 | Bus-Id          | AICore(%)   Memory-Usage(MB)                       |
+======================+=================+=====================================================+
| 0     910B           | OK              | 120.5       42                0    / 0             |
| 0                    | 0000:C1:00.0    | 0           1024 / 65536                            |
+======================+=================+=====================================================+
| 1     910B           | OK              | 350.2       68                0    / 0             |
| 0                    | 0000:C2:00.0    | 98          60000 / 65536                          |
+======================+=================+=====================================================+
```

**字段说明：**

| 字段 | 含义 | 说明 |
|------|------|------|
| `NPU` | NPU 编号 | 从 0 开始，对应物理槽位 |
| `Name` | NPU 型号 | 如 910B、310P、910A |
| `Health` | 健康状态 | `OK`（正常）、`Warning`（警告）、`Critical`（严重）、`Fault`（故障） |
| `Power(W)` | 实时功耗 | 单位瓦特，910B 满载约 350W |
| `Temp(C)` | 芯片温度 | 单位摄氏度，正常 < 80°C，超过 85°C 需告警 |
| `Chip` | 芯片编号 | 一张 NPU 卡上可能有多个 chip |
| `Bus-Id` | PCIe 总线地址 | 用于唯一定位物理设备 |
| `AICore(%)` | AI Core 利用率 | 计算单元使用百分比 |
| `Memory-Usage(MB)` | 显存使用 | 已用 / 总量，单位 MB |

### 查看健康状态

```bash
npu-smi info -t health
```

输出示例：

```
        NPU ID                         Chip ID                     Health
        0                              0                           OK
        1                              0                           OK
        2                              0                           Warning
        3                              0                           OK
```

### 查看 ECC 错误

```bash
npu-smi info -t ecc -i 0
```

输出示例：

```
        NPU ID                         Chip ID                     Memory ECC Enable
        0                              0                           Enable
        CE Count                       UE Count
        12                             0
```

| 字段 | 含义 |
|------|------|
| `Memory ECC Enable` | ECC 功能是否开启 |
| `CE Count` | Correctable Error（可纠正错误）计数，单比特错误 |
| `UE Count` | Uncorrectable Error（不可纠正错误）计数，多比特错误 |

::: warning 注意
`UE Count > 0` 通常意味着显存硬件出现物理损坏，建议尽快安排更换。
`CE Count` 持续快速增长也是硬件老化的信号，需要密切关注。
:::

### 查看 HCCS 拓扑

```bash
npu-smi info -t topo
```

输出示例：

```
        NPU 0         NPU 1         NPU 2         NPU 3
NPU 0     X            HCCS          HCCS          HCCS
NPU 1   HCCS            X            HCCS          HCCS
NPU 2   HCCS          HCCS            X            HCCS
NPU 3   HCCS          HCCS          HCCS            X
```

正常情况下，同一服务器内的所有 NPU 之间应通过 HCCS 全互联。如果出现 `PCIE` 或 `--`，说明 HCCS 链路异常。

---

## 定时采集 NPU 指标

### 方案一：crontab + npu-smi（轻量方案）

适用于小规模集群或临时监控需求，将 `npu-smi info` 输出定时写入文件。

**创建采集脚本：**

```bash
#!/bin/bash
# /opt/ascend-monitor/npu_collect.sh
# 定时采集 NPU 指标到日志文件

LOG_DIR="/var/log/ascend-monitor"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="$LOG_DIR/npu_metrics_$(date '+%Y%m%d').log"

# 采集基本信息
echo "========================================" >> "$LOG_FILE"
echo "Timestamp: $TIMESTAMP" >> "$LOG_FILE"
npu-smi info >> "$LOG_FILE" 2>&1

# 采集健康状态
echo "--- Health Status ---" >> "$LOG_FILE"
npu-smi info -t health >> "$LOG_FILE" 2>&1

# 采集 ECC 错误（遍历每张卡）
echo "--- ECC Errors ---" >> "$LOG_FILE"
NPU_COUNT=$(npu-smi info -l 2>/dev/null | grep "Total Count" | awk '{print $3}')
for ((i=0; i<NPU_COUNT; i++)); do
    echo "NPU $i:" >> "$LOG_FILE"
    npu-smi info -t ecc -i $i >> "$LOG_FILE" 2>&1
done

# 采集 HCCS 拓扑
echo "--- HCCS Topology ---" >> "$LOG_FILE"
npu-smi info -t topo >> "$LOG_FILE" 2>&1

echo "" >> "$LOG_FILE"
```

**配置 crontab：**

```bash
# 每 5 分钟采集一次
echo "*/5 * * * * /opt/ascend-monitor/npu_collect.sh" | sudo tee -a /etc/crontab

# 或者用 crontab -e
sudo crontab -e
# 添加以下行：
# */5 * * * * /opt/ascend-monitor/npu_collect.sh
```

### 方案二：结构化采集（CSV 格式）

适合后续用 Python/pandas 分析的场景：

```bash
#!/bin/bash
# /opt/ascend-monitor/npu_csv_collect.sh
# 将 NPU 指标采集为 CSV 格式

CSV_FILE="/var/log/ascend-monitor/npu_metrics.csv"
mkdir -p "$(dirname "$CSV_FILE")"

# 如果文件不存在，写入表头
if [ ! -f "$CSV_FILE" ]; then
    echo "timestamp,npu_id,name,health,power_w,temp_c,aicore_pct,mem_used_mb,mem_total_mb" > "$CSV_FILE"
fi

TIMESTAMP=$(date '+%Y-%m-%dT%H:%M:%S')

# 解析 npu-smi info 输出
npu-smi info 2>/dev/null | awk -v ts="$TIMESTAMP" '
/^\| [0-9]/ {
    npu_id = $2
    name = $3
    health = $5
    power = $6
    temp = $7
}
/^\| [0-9].*Bus/ {
    aicore = $4
    mem_used = $5
    mem_total = $7
    gsub("/", "", mem_total)
    printf "%s,%s,%s,%s,%s,%s,%s,%s,%s\n", ts, npu_id, name, health, power, temp, aicore, mem_used, mem_total
}
' >> "$CSV_FILE"
```

---

## prometheus-ascend-exporter 方案

对于生产环境，推荐使用 `prometheus-ascend-exporter`，它以 Prometheus 标准格式暴露 NPU 指标，支持自动发现和灵活查询。

### 安装 Exporter

```bash
# 方式一：从 CANN 包获取（推荐）
# ascend-exporter 通常随 CANN 工具包或单独的监控组件包发布
# 检查是否已安装
which ascend-exporter 2>/dev/null || find /usr/local/Ascend -name "ascend-exporter" 2>/dev/null

# 方式二：从昇腾官方仓库获取
# 参考: https://gitee.com/ascend/ascend-exporter
cd /opt
git clone https://gitee.com/ascend/ascend-exporter.git
cd ascend-exporter
# 按照仓库 README 进行编译安装

# 方式三：使用预编译二进制
wget https://obs.cn-east-2.myhuaweicloud.com/ascend-exporter/ascend-exporter-latest-linux-amd64.tar.gz
tar -xzf ascend-exporter-latest-linux-amd64.tar.gz -C /usr/local/bin/
chmod +x /usr/local/bin/ascend-exporter
```

### 配置 Exporter

```yaml
# /etc/ascend-exporter/config.yaml
# Exporter 配置文件

# 监听端口
port: 9100
host: "0.0.0.0"

# 采集间隔（秒）
scrape_interval: 15

# NPU 设备过滤（留空表示采集所有）
# device_filter:
#   - "0,1,2,3"  # 只采集指定 NPU

# 采集的指标类别
metrics:
  - basic          # 基本信息：设备数量、型号、健康状态
  - temperature    # 温度
  - power          # 功耗
  - memory         # 显存使用
  - utilization    # 算力利用率
  - hccs           # HCCS 链路状态
  - ecc            # ECC 错误统计
  - health         # 健康详情

# 日志级别: debug / info / warn / error
log_level: "info"
```

### 创建 systemd 服务

```ini
# /etc/systemd/system/ascend-exporter.service
[Unit]
Description=Prometheus Ascend NPU Exporter
After=network.target
After=npu-driver.service

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/ascend-exporter --config.file=/etc/ascend-exporter/config.yaml
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

```bash
# 启动服务
sudo systemctl daemon-reload
sudo systemctl enable ascend-exporter
sudo systemctl start ascend-exporter

# 检查状态
sudo systemctl status ascend-exporter

# 验证指标输出
curl -s http://localhost:9100/metrics | head -50
```

### Exporter 暴露的指标

访问 `http://<node-ip>:9100/metrics` 可以看到如下格式的指标：

```
# HELP ascend_npu_count NPU device count
# TYPE ascend_npu_count gauge
ascend_npu_count 8

# HELP ascend_npu_health NPU health status (0=OK, 1=Warning, 2=Critical, 3=Fault)
# TYPE ascend_npu_health gauge
ascend_npu_health{npu_id="0",chip_id="0",name="910B"} 0
ascend_npu_health{npu_id="1",chip_id="0",name="910B"} 0
ascend_npu_health{npu_id="2",chip_id="0",name="910B"} 1
ascend_npu_health{npu_id="3",chip_id="0",name="910B"} 0

# HELP ascend_npu_temperature_celsius NPU temperature in Celsius
# TYPE ascend_npu_temperature_celsius gauge
ascend_npu_temperature_celsius{npu_id="0",chip_id="0"} 42
ascend_npu_temperature_celsius{npu_id="1",chip_id="0"} 68
ascend_npu_temperature_celsius{npu_id="2",chip_id="0"} 85
ascend_npu_temperature_celsius{npu_id="3",chip_id="0"} 55

# HELP ascend_npu_power_watts NPU power consumption in Watts
# TYPE ascend_npu_power_watts gauge
ascend_npu_power_watts{npu_id="0",chip_id="0"} 120.5
ascend_npu_power_watts{npu_id="1",chip_id="0"} 350.2

# HELP ascend_npu_memory_used_bytes NPU HBM memory used in bytes
# TYPE ascend_npu_memory_used_bytes gauge
ascend_npu_memory_used_bytes{npu_id="0",chip_id="0"} 1.073741824e+09
ascend_npu_memory_used_bytes{npu_id="1",chip_id="0"} 6.291456e+10

# HELP ascend_npu_memory_total_bytes NPU HBM total memory in bytes
# TYPE ascend_npu_memory_total_bytes gauge
ascend_npu_memory_total_bytes{npu_id="0",chip_id="0"} 6.8719476736e+10

# HELP ascend_npu_aicore_utilization_percent NPU AI Core utilization percentage
# TYPE ascend_npu_aicore_utilization_percent gauge
ascend_npu_aicore_utilization_percent{npu_id="0",chip_id="0"} 0
ascend_npu_aicore_utilization_percent{npu_id="1",chip_id="0"} 98

# HELP ascend_npu_hccs_link_status HCCS link status (1=UP, 0=DOWN, 2=DEGRADED)
# TYPE ascend_npu_hccs_link_status gauge
ascend_npu_hccs_link_status{npu_id="0",chip_id="0",port="0"} 1
ascend_npu_hccs_link_status{npu_id="0",chip_id="0",port="1"} 1
ascend_npu_hccs_link_status{npu_id="1",chip_id="0",port="0"} 2

# HELP ascend_npu_ecc_correctable_errors_total Total correctable ECC errors
# TYPE ascend_npu_ecc_correctable_errors_total counter
ascend_npu_ecc_correctable_errors_total{npu_id="0",chip_id="0"} 12
ascend_npu_ecc_correctable_errors_total{npu_id="2",chip_id="0"} 156

# HELP ascend_npu_ecc_uncorrectable_errors_total Total uncorrectable ECC errors
# TYPE ascend_npu_ecc_uncorrectable_errors_total counter
ascend_npu_ecc_uncorrectable_errors_total{npu_id="0",chip_id="0"} 0
ascend_npu_ecc_uncorrectable_errors_total{npu_id="2",chip_id="0"} 1
```

---

## 关键指标说明表

| 指标名 | 含义 | 正常范围 | 告警阈值 | 告警级别 |
|--------|------|----------|----------|----------|
| `ascend_npu_count` | 在线 NPU 数量 | 等于预期数量 | < 预期数量 | P0 |
| `ascend_npu_health` | 设备健康状态 | 0 (OK) | >= 1 (Warning) | P1 |
| `ascend_npu_health` | 设备健康状态 | 0 (OK) | >= 2 (Critical) | P0 |
| `ascend_npu_temperature_celsius` | NPU 温度 | < 75°C | > 85°C | P1 |
| `ascend_npu_temperature_celsius` | NPU 温度 | < 75°C | > 95°C | P0 |
| `ascend_npu_power_watts` | NPU 功耗 | < TDP (350W) | > TDP × 1.1 | P1 |
| `ascend_npu_memory_used_bytes / total_bytes` | 显存利用率 | < 95% | = 100% 持续 5min | P1 |
| `ascend_npu_aicore_utilization_percent` | AI Core 利用率 | 0~100% | 0% 持续 30min（空闲异常） | P2 |
| `ascend_npu_hccs_link_status` | HCCS 链路状态 | 1 (UP) | 0 (DOWN) | P0 |
| `ascend_npu_hccs_link_status` | HCCS 链路状态 | 1 (UP) | 2 (DEGRADED) | P1 |
| `ascend_npu_ecc_correctable_errors_total` | 可纠正 ECC 错误 | 增长缓慢 | 1h 内增量 > 100 | P1 |
| `ascend_npu_ecc_uncorrectable_errors_total` | 不可纠正 ECC 错误 | 0 | > 0 | P0 |

::: tip 指标值映射
`ascend_npu_health` 的数值映射：`0 = OK`，`1 = Warning`，`2 = Critical`，`3 = Fault`。在 Grafana 中可以通过 Value Mapping 将数值显示为文字。
:::

---

## 自定义采集脚本

以下脚本综合采集 NPU 关键指标，输出 JSON 格式，方便对接其他监控系统：

```bash
#!/bin/bash
# /opt/ascend-monitor/npu_json_collect.sh
# 采集 NPU 指标并输出 JSON 格式

set -euo pipefail

TIMESTAMP=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
HOSTNAME=$(hostname)

# 获取 NPU 数量
NPU_COUNT=$(npu-smi info -l 2>/dev/null | grep "Total Count" | awk '{print $3}')
if [ -z "$NPU_COUNT" ]; then
    NPU_COUNT=0
fi

# 开始构建 JSON
echo "{"
echo "  \"timestamp\": \"$TIMESTAMP\","
echo "  \"hostname\": \"$HOSTNAME\","
echo "  \"npu_count\": $NPU_COUNT,"
echo "  \"devices\": ["

FIRST=true
for ((i=0; i<NPU_COUNT; i++)); do
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo ","
    fi

    # 采集基本信息
    HEALTH=$(npu-smi info -t health -i $i 2>/dev/null | grep "^        $i" | awk '{print $3}')
    POWER=$(npu-smi info -i $i 2>/dev/null | grep -A1 "^\| $i" | head -1 | awk -F'|' '{print $4}' | awk '{print $1}')
    TEMP=$(npu-smi info -i $i 2>/dev/null | grep -A1 "^\| $i" | head -1 | awk -F'|' '{print $4}' | awk '{print $2}')
    AICORE=$(npu-smi info -i $i 2>/dev/null | grep "Bus-Id" | awk -F'|' '{print $4}' | awk '{print $1}')
    MEM_USED=$(npu-smi info -i $i 2>/dev/null | grep "Bus-Id" | awk -F'|' '{print $4}' | awk '{print $2}')
    MEM_TOTAL=$(npu-smi info -i $i 2>/dev/null | grep "Bus-Id" | awk -F'|' '{print $4}' | awk '{print $4}')

    # 采集 ECC
    CE_COUNT=$(npu-smi info -t ecc -i $i 2>/dev/null | grep "CE Count" | awk '{print $3}')
    UE_COUNT=$(npu-smi info -t ecc -i $i 2>/dev/null | grep "UE Count" | awk '{print $3}')

    # 默认值处理
    HEALTH="${HEALTH:-Unknown}"
    POWER="${POWER:-0}"
    TEMP="${TEMP:-0}"
    AICORE="${AICORE:-0}"
    MEM_USED="${MEM_USED:-0}"
    MEM_TOTAL="${MEM_TOTAL:-0}"
    CE_COUNT="${CE_COUNT:-0}"
    UE_COUNT="${UE_COUNT:-0}"

    echo -n "    {\"npu_id\": $i, \"health\": \"$HEALTH\", \"power_w\": $POWER, \"temp_c\": $TEMP, \"aicore_pct\": $AICORE, \"mem_used_mb\": $MEM_USED, \"mem_total_mb\": $MEM_TOTAL, \"ecc_ce\": $CE_COUNT, \"ecc_ue\": $UE_COUNT}"
done

echo ""
echo "  ]"
echo "}"
```

使用方式：

```bash
# 直接执行查看输出
/opt/ascend-monitor/npu_json_collect.sh

# 定时采集到文件
echo "*/5 * * * * /opt/ascend-monitor/npu_json_collect.sh >> /var/log/ascend-monitor/npu_metrics.jsonl" | sudo tee -a /etc/crontab

# 通过 HTTP 推送到监控平台
/opt/ascend-monitor/npu_json_collect.sh | curl -X POST -H "Content-Type: application/json" -d @- http://monitor-server:8080/api/npu-metrics
```

---

## 常见问题

**Q: `npu-smi info` 报错 `npu-smi: command not found`？**

A: 驱动未安装或环境变量未配置。检查：
```bash
# 查找 npu-smi 位置
find /usr/local/Ascend -name "npu-smi" 2>/dev/null

# 通常在 /usr/local/sbin/ 下
export PATH=$PATH:/usr/local/sbin

# 确认驱动已安装
lsmod | grep drv_pcie_host
```

**Q: Exporter 启动但 `/metrics` 没有 NPU 指标？**

A: 检查驱动是否正常加载、当前用户是否有权限访问 NPU 设备：
```bash
npu-smi info  # 确认能正常输出
ls -la /dev/davinci*  # 检查设备节点权限
```

**Q: 采集脚本中 awk 解析 `npu-smi` 输出不准确？**

A: 不同版本的 `npu-smi` 输出格式可能有差异，建议先手动执行查看格式，再调整 awk 字段索引。生产环境推荐使用 `ascend-exporter` 而非自行解析。

---

::: tip 下一步
采集层搭建完成后，请继续 [Prometheus + Grafana 搭建](./prometheus-grafana) 配置数据存储与可视化。
:::
