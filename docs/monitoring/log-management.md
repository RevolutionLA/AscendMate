---
layout: doc
title: 日志管理
description: 昇腾 NPU 日志目录结构、日志级别说明、一键诊断日志收集脚本、日志分析技巧、日志轮转清理策略及 ELK/Loki 对接方案。
---

# 日志管理

> 日志是故障排查的"黑匣子"。本章介绍昇腾日志的目录结构、收集方法、分析技巧和管理策略，让您在故障发生时能快速提取关键信息。

---

## 昇腾日志目录结构

### 日志目录总览

昇腾 NPU 相关日志分布在以下目录中：

```
/var/log/ascend/                  # 系统级日志（需 root 权限）
├── driver/                       # 驱动日志
│   ├── driver.log                # 驱动主日志
│   ├── drv_pcie_host.log         # PCIe 驱动日志
│   └── drv_davinci.log           # Davinci 驱动日志
├── ascend_*.log                  # CANN 组件日志
├── monitor/                      # 监控组件日志
│   └── ascend-exporter.log       # Exporter 日志
└── install/                      # 安装日志
    └── install_*.log

~/ascend/log/                     # 用户级日志（CANN 运行时）
├── plog/                         # 进程日志
│   ├── plog-<pid>.log            # 按进程ID分隔的日志
│   └── plog-<pid>.log.wf         # 告警级别日志
├── host/                         # Host 侧日志
│   ├── host-<timestamp>.log
│   └── host-<timestamp>.log.wf
├── device-<id>/                  # Device 侧日志（按 NPU 编号）
│   ├── device-<id>-<timestamp>.log
│   └── device-<id>-<timestamp>.log.wf
└── debug/                        # 调试日志
    └── debug-<timestamp>.log

/var/log/messages                 # 系统消息日志
/var/log/syslog                   # 系统日志（Ubuntu）
```

### 关键目录说明

| 目录 | 路径 | 说明 | 权限 |
|------|------|------|------|
| 驱动日志 | `/var/log/ascend/driver/` | NPU 驱动层日志，记录硬件交互 | root |
| CANN 日志 | `~/ascend/log/` | CANN 运行时日志，记录算子执行 | 运行用户 |
| 安装日志 | `/var/log/ascend/install/` | 驱动/CANN 安装过程日志 | root |
| 内核日志 | `dmesg` | 内核环形缓冲区，PCIe 错误等 | root |
| 系统日志 | `/var/log/messages` | 系统级事件 | root |

### 查看驱动版本与日志路径

```bash
# 查看驱动版本
npu-smi info -t board -i 0

# 查看日志配置
cat /etc/ascend_install.cfg 2>/dev/null || cat /usr/local/Ascend/driver/version.info

# 确认日志目录是否存在
ls -la /var/log/ascend/
ls -la ~/ascend/log/
```

---

## 日志级别与含义

昇腾日志采用标准的日志级别体系：

| 级别 | 名称 | 数值 | 含义 | 典型场景 |
|------|------|------|------|----------|
| DEBUG | 调试 | 0 | 详细的调试信息 | 开发调试，生产环境通常关闭 |
| INFO | 信息 | 1 | 正常运行信息 | 设备初始化、任务启动 |
| WARN | 警告 | 2 | 潜在问题，不影响运行 | 配置不推荐、资源接近上限 |
| ERROR | 错误 | 3 | 错误，影响当前操作 | 算子执行失败、通信超时 |
| FATAL | 致命 | 4 | 致命错误，进程退出 | 驱动加载失败、硬件不可用 |

### 日志级别配置

```bash
# 设置 CANN 日志级别（环境变量）
export ASCEND_SLOG_PRINT_TO_STDOUT=0     # 是否输出到终端（0=否，1=是）
export ASCEND_GLOBAL_LOG_LEVEL=1         # 全局日志级别（0=DEBUG, 1=INFO, 2=WARN, 3=ERROR, 4=FATAL）
export ASCEND_SLOG_PATH=~/ascend/log     # 日志输出路径

# 设置特定模块日志级别
export ASCEND_MODULE_LOG_LEVEL=GE=3,FE=2  # GE(Graph Engine)=ERROR, FE(Fusion Engine)=WARN

# 在 Python 代码中设置
import os
os.environ['ASCEND_GLOBAL_LOG_LEVEL'] = '3'  # ERROR
```

### `.wf` 文件

`.wf` 后缀的日志文件（Write Fail / Warning Fatal）只记录 WARN 及以上级别的日志，是快速排查问题的首选：

```bash
# 只看告警及以上级别的日志
ls ~/ascend/log/plog/*.wf
cat ~/ascend/log/plog/plog-*.log.wf | tail -100
```

---

## 日志收集脚本

### 一键收集诊断日志

```bash
#!/bin/bash
# /opt/ascend-monitor/collect_diag.sh
# 一键收集昇腾 NPU 诊断日志
# 用法: ./collect_diag.sh [输出目录]

set -euo pipefail

OUTPUT_DIR="${1:-/tmp/ascend_diag_$(date '+%Y%m%d_%H%M%S')}"
HOSTNAME=$(hostname)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=============================================="
echo " 昇腾 NPU 诊断日志收集工具"
echo " 主机: $HOSTNAME"
echo " 时间: $TIMESTAMP"
echo " 输出: $OUTPUT_DIR"
echo "=============================================="

# 创建输出目录
mkdir -p "$OUTPUT_DIR"/{npu_info,system_info,logs,config}

# ============ 1. NPU 信息 ============
echo "[1/8] 收集 NPU 基本信息..."
npu-smi info > "$OUTPUT_DIR/npu_info/npu-smi-info.txt" 2>&1
npu-smi info -t board > "$OUTPUT_DIR/npu_info/npu-smi-board.txt" 2>&1
npu-smi info -t health > "$OUTPUT_DIR/npu_info/npu-smi-health.txt" 2>&1
npu-smi info -t ecc > "$OUTPUT_DIR/npu_info/npu-smi-ecc.txt" 2>&1
npu-smi info -t topo > "$OUTPUT_DIR/npu_info/npu-smi-topo.txt" 2>&1
npu-smi info -t power > "$OUTPUT_DIR/npu_info/npu-smi-power.txt" 2>&1
npu-smi info -t usage > "$OUTPUT_DIR/npu_info/npu-smi-usage.txt" 2>&1

# ============ 2. 系统信息 ============
echo "[2/8] 收集系统信息..."
uname -a > "$OUTPUT_DIR/system_info/uname.txt"
cat /etc/os-release > "$OUTPUT_DIR/system_info/os-release.txt"
lscpu > "$OUTPUT_DIR/system_info/lscpu.txt" 2>&1
free -h > "$OUTPUT_DIR/system_info/memory.txt" 2>&1
df -h > "$OUTPUT_DIR/system_info/disk.txt" 2>&1
lspci -v -d 19e5: > "$OUTPUT_DIR/system_info/lspci-ascend.txt" 2>&1 || lspci | grep -i d500 > "$OUTPUT_DIR/system_info/lspci-ascend.txt" 2>&1
ip addr > "$OUTPUT_DIR/system_info/network.txt" 2>&1

# ============ 3. 驱动与固件信息 ============
echo "[3/8] 收集驱动与固件信息..."
systemctl status npu-driver --no-pager > "$OUTPUT_DIR/system_info/npu-driver-status.txt" 2>&1
cat /usr/local/Ascend/driver/version.info > "$OUTPUT_DIR/system_info/driver-version.txt" 2>&1
lsmod | grep -i drv > "$OUTPUT_DIR/system_info/lsmod.txt" 2>&1

# ============ 4. 内核日志 ============
echo "[4/8] 收集内核日志..."
dmesg > "$OUTPUT_DIR/logs/dmesg.txt" 2>&1
dmesg | grep -i "davinci\|d500\|npu\|ascend\|pcie" > "$OUTPUT_DIR/logs/dmesg-ascend-filtered.txt" 2>&1

# ============ 5. 驱动日志 ============
echo "[5/8] 收集驱动日志..."
if [ -d /var/log/ascend ]; then
    cp -r /var/log/ascend/ "$OUTPUT_DIR/logs/ascend-system/" 2>/dev/null || true
fi

# ============ 6. CANN 运行时日志 ============
echo "[6/8] 收集 CANN 日志..."
if [ -d ~/ascend/log ]; then
    # 只收集最近 24 小时的日志
    find ~/ascend/log -name "*.log" -mmin -1440 -exec cp --parents {} "$OUTPUT_DIR/logs/" \; 2>/dev/null || true
    find ~/ascend/log -name "*.wf" -mmin -1440 -exec cp --parents {} "$OUTPUT_DIR/logs/" \; 2>/dev/null || true
fi

# ============ 7. 配置文件 ============
echo "[7/8] 收集配置文件..."
cp /etc/ascend-exporter/config.yaml "$OUTPUT_DIR/config/" 2>/dev/null || true
cp /opt/prometheus/prometheus.yml "$OUTPUT_DIR/config/" 2>/dev/null || true
cp /opt/alertmanager/alertmanager.yml "$OUTPUT_DIR/config/" 2>/dev/null || true

# ============ 8. 进程信息 ============
echo "[8/8] 收集进程信息..."
ps aux | grep -i "ascend\|npu\|python\|cann" | grep -v grep > "$OUTPUT_DIR/system_info/processes.txt" 2>&1

# ============ 生成摘要 ============
echo ""
echo "==============================================" > "$OUTPUT_DIR/SUMMARY.md"
echo " 诊断日志收集摘要" >> "$OUTPUT_DIR/SUMMARY.md"
echo "==============================================" >> "$OUTPUT_DIR/SUMMARY.md"
echo "" >> "$OUTPUT_DIR/SUMMARY.md"
echo "| 项目 | 内容 |" >> "$OUTPUT_DIR/SUMMARY.md"
echo "|------|------|" >> "$OUTPUT_DIR/SUMMARY.md"
echo "| 主机名 | $HOSTNAME |" >> "$OUTPUT_DIR/SUMMARY.md"
echo "| 收集时间 | $TIMESTAMP |" >> "$OUTPUT_DIR/SUMMARY.md"
echo "| NPU 数量 | $(grep 'Total Count' "$OUTPUT_DIR/npu_info/npu-smi-info.txt" 2>/dev/null | awk '{print $3}' || echo 'N/A') |" >> "$OUTPUT_DIR/SUMMARY.md"
echo "| 驱动版本 | $(cat /usr/local/Ascend/driver/version.info 2>/dev/null | head -1 || echo 'N/A') |" >> "$OUTPUT_DIR/SUMMARY.md"
echo "" >> "$OUTPUT_DIR/SUMMARY.md"
echo "## 收集内容" >> "$OUTPUT_DIR/SUMMARY.md"
echo "- npu_info/: npu-smi 各类输出" >> "$OUTPUT_DIR/SUMMARY.md"
echo "- system_info/: 系统信息（CPU/内存/磁盘/PCIe）" >> "$OUTPUT_DIR/SUMMARY.md"
echo "- logs/: 驱动日志、CANN 日志、dmesg" >> "$OUTPUT_DIR/SUMMARY.md"
echo "- config/: 监控组件配置文件" >> "$OUTPUT_DIR/SUMMARY.md"

# 打包
echo ""
echo "正在打包..."
tar -czf "${OUTPUT_DIR}.tar.gz" -C "$(dirname "$OUTPUT_DIR")" "$(basename "$OUTPUT_DIR")"
rm -rf "$OUTPUT_DIR"

echo ""
echo "=============================================="
echo " 收集完成！"
echo " 打包文件: ${OUTPUT_DIR}.tar.gz"
echo " 文件大小: $(du -h "${OUTPUT_DIR}.tar.gz" | awk '{print $1}')"
echo "=============================================="
```

使用方式：

```bash
# 赋予执行权限
chmod +x /opt/ascend-monitor/collect_diag.sh

# 本机收集
/opt/ascend-monitor/collect_diag.sh

# 指定输出目录
/opt/ascend-monitor/collect_diag.sh /tmp/diag_reports

# 远程收集（配合 SSH）
ssh compute-01 'bash -s' < /opt/ascend-monitor/collect_diag.sh
```

### 批量收集多节点日志

```bash
#!/bin/bash
# /opt/ascend-monitor/batch_collect.sh
# 批量收集多节点诊断日志

NODES_FILE="/opt/ascend-monitor/nodes.txt"
COLLECT_SCRIPT="/opt/ascend-monitor/collect_diag.sh"
OUTPUT_BASE="/tmp/ascend_diag_batch_$(date '+%Y%m%d_%H%M%S')"
mkdir -p "$OUTPUT_BASE"

for node in $(grep -v '^#' "$NODES_FILE" | grep -v '^$'); do
    echo "正在收集: $node"
    ssh -o ConnectTimeout=10 "$node" 'bash -s' < "$COLLECT_SCRIPT" "/tmp/diag_$(date '+%Y%m%d_%H%M%S')" 2>&1
    # 下载打包文件
    REMOTE_FILE=$(ssh "$node" "ls -t /tmp/ascend_diag_*.tar.gz 2>/dev/null | head -1")
    if [ -n "$REMOTE_FILE" ]; then
        scp "$node:$REMOTE_FILE" "$OUTPUT_BASE/${node}_diag.tar.gz"
        ssh "$node" "rm -f $REMOTE_FILE"
    fi
    echo "完成: $node"
done

echo ""
echo "所有节点日志收集完成，文件在: $OUTPUT_BASE"
ls -lh "$OUTPUT_BASE/"
```

---

## 日志分析技巧

### 常用 grep 模式

```bash
# ============ 驱动日志分析 ============

# 查看驱动错误
grep -i "error\|fail\|fault" /var/log/ascend/driver/driver.log | tail -50

# 查看 PCIe 相关错误
grep -i "pcie\|aer\|link" /var/log/ascend/driver/driver.log | tail -50

# 查看设备初始化信息
grep -i "init\|probe\|register" /var/log/ascend/driver/driver.log | head -50

# ============ dmesg 分析 ============

# 查看 NPU 相关内核日志
dmesg | grep -i "davinci\|d500\|npu\|ascend"

# 查看 PCIe 错误
dmesg | grep -i "aer\|pcie.*error"

# 查看最近的硬件错误
dmesg --level=err,crit,alert,emerg | tail -50

# ============ CANN 日志分析 ============

# 查看 .wf 文件（告警及以上级别）
cat ~/ascend/log/plog/*.wf | tail -100

# 查看特定时间的日志
grep "2026-08-26 14:" ~/ascend/log/plog/*.log

# 查看特定 NPU 的日志
ls ~/ascend/log/device-0/

# 查看算子执行错误
grep -i "operator\|kernel\|fusion" ~/ascend/log/plog/*.log.wf | tail -50

# 查看通信错误（HCCL）
grep -i "hccl\|hccs\|communication" ~/ascend/log/plog/*.log.wf
```

### 常见错误关键词

| 关键词 | 含义 | 可能原因 | 排查方向 |
|--------|------|----------|----------|
| `device not found` | 设备未找到 | 驱动异常 / 掉卡 | 检查 npu-smi / 驱动服务 |
| `PCIe AER` | PCIe 高级错误报告 | 硬件接触不良 | 检查 dmesg / reseat |
| `link down` | 链路断开 | HCCS / PCIe 链路异常 | 检查拓扑 / 重启驱动 |
| `ECC error` | ECC 错误 | 显存硬件问题 | 查看 ECC 计数 / 更换硬件 |
| `out of memory` | 显存不足 | 任务显存超限 | 减小 batch / 检查泄漏 |
| `timeout` | 超时 | 通信 / 任务执行超时 | 检查网络 / 驱动状态 |
| `permission denied` | 权限不足 | 用户权限问题 | 检查设备节点权限 |
| `firmware mismatch` | 固件版本不匹配 | 驱动与固件版本不一致 | 检查版本 / 重新安装 |
| `core dump` | 核心转储 | 进程崩溃 | 查看转储文件 / 调试 |
| `drv_pcie_host` | PCIe 驱动 | 驱动层错误 | 检查驱动日志 |

### 日志分析实战

**场景 1：训练任务突然报错中断**

```bash
# 1. 查看 .wf 日志（最快定位）
ls -lt ~/ascend/log/plog/*.wf | head -3
cat $(ls -t ~/ascend/log/plog/*.wf | head -1) | tail -50

# 2. 查看对应时间的 device 日志
ls -lt ~/ascend/log/device-0/ | head -5

# 3. 查看系统日志中是否有 OOM
dmesg | grep -i "oom\|killed" | tail -10

# 4. 查看 NPU 当前状态
npu-smi info
npu-smi info -t health
```

**场景 2：NPU 性能下降**

```bash
# 1. 检查是否有 HCCS 降速
npu-smi info -t topo

# 2. 检查驱动日志中的链路错误
grep -i "link\|hccs\|degrad" /var/log/ascend/driver/driver.log | tail -30

# 3. 检查温度是否异常导致降频
npu-smi info | awk -F'|' '/^\| [0-9]/ {print $4}'

# 4. 检查 dmesg 中的硬件错误
dmesg | grep -i "throttl\|freq\|thermal" | tail -20
```

**场景 3：多卡通信错误**

```bash
# 1. 查看 HCCL 通信日志
grep -ri "hccl" ~/ascend/log/plog/*.log.wf | tail -30

# 2. 检查 HCCS 链路状态
npu-smi info -t hccs

# 3. 检查所有卡的健康状态
npu-smi info -t health

# 4. 检查是否有 ECC 错误导致通信异常
npu-smi info -t ecc
```

---

## 日志轮转与清理策略

### logrotate 配置

```conf
# /etc/logrotate.d/ascend
# 昇腾 NPU 日志轮转配置

# 驱动日志
/var/log/ascend/driver/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    size 500M
}

# CANN plog 日志
/var/log/ascend/plog/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    size 200M
}

# 监控组件日志
/var/log/ascend-monitor/*.log {
    weekly
    rotate 8
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    size 100M
}

# 巡检报告（仅保留最近 90 天）
/var/log/ascend-monitor/inspection/*.md {
    monthly
    rotate 3
    compress
    missingok
    notifempty
}
```

```bash
# 测试 logrotate 配置
sudo logrotate -d /etc/logrotate.d/ascend

# 手动执行 logrotate
sudo logrotate -f /etc/logrotate.d/ascend
```

### 定时清理脚本

```bash
#!/bin/bash
# /opt/ascend-monitor/log_cleanup.sh
# 定时清理昇腾日志

set -euo pipefail

KEEP_DAYS=30          # 保留天数
MAX_SIZE_GB=10        # 日志目录最大大小（GB）
LOG_DIR_CANN="${HOME}/ascend/log"
LOG_DIR_DRIVER="/var/log/ascend"
LOG_DIR_MONITOR="/var/log/ascend-monitor"

echo "[$(date)] 开始日志清理..."

# 1. 删除超过保留天数的 CANN 日志
if [ -d "$LOG_DIR_CANN" ]; then
    echo "清理 CANN 日志 (保留 $KEEP_DAYS 天)..."
    find "$LOG_DIR_CANN" -name "*.log" -mtime +$KEEP_DAYS -delete
    find "$LOG_DIR_CANN" -name "*.wf" -mtime +$KEEP_DAYS -delete
    find "$LOG_DIR_CANN" -type d -empty -delete
fi

# 2. 检查驱动日志目录大小
if [ -d "$LOG_DIR_DRIVER" ]; then
    DIR_SIZE=$(du -s "$LOG_DIR_DRIVER" 2>/dev/null | awk '{print $1}')
    DIR_SIZE_GB=$((DIR_SIZE / 1024 / 1024))
    if [ "$DIR_SIZE_GB" -gt "$MAX_SIZE_GB" ]; then
        echo "驱动日志目录 ${DIR_SIZE_GB}GB 超过限制 ${MAX_SIZE_GB}GB，清理旧日志..."
        find "$LOG_DIR_DRIVER" -name "*.log.*" -mtime +7 -delete
        find "$LOG_DIR_DRIVER" -name "*.log" -size +500M -exec truncate -s 0 {} \;
    fi
fi

# 3. 清理监控日志
if [ -d "$LOG_DIR_MONITOR" ]; then
    find "$LOG_DIR_MONITOR" -name "*.log" -mtime +60 -delete
fi

# 4. 清理压缩后的旧日志
find /var/log/ascend* -name "*.gz" -mtime +30 -delete 2>/dev/null || true

echo "[$(date)] 日志清理完成。"
echo "当前日志大小:"
du -sh /var/log/ascend/ ~/ascend/log/ /var/log/ascend-monitor/ 2>/dev/null || true
```

```bash
# 配置 crontab：每周日凌晨 3 点执行
echo "0 3 * * 0 /opt/ascend-monitor/log_cleanup.sh >> /var/log/ascend-monitor/cleanup.log 2>&1" | sudo tee -a /etc/crontab
```

### 磁盘空间告警脚本

```bash
#!/bin/bash
# /opt/ascend-monitor/disk_alert.sh
# 检查日志目录磁盘占用，超过阈值时告警

THRESHOLD=80  # 百分比
NPU_LOG_DIR="/var/log/ascend"

USAGE=$(df "$NPU_LOG_DIR" | tail -1 | awk '{print $5}' | tr -d '%')

if [ "$USAGE" -gt "$THRESHOLD" ]; then
    echo "WARNING: 磁盘使用率 ${USAGE}% 超过阈值 ${THRESHOLD}%"
    echo "日志目录大小:"
    du -sh /var/log/ascend/* 2>/dev/null
    echo ""
    echo "最大的 10 个日志文件:"
    find /var/log/ascend -name "*.log*" -exec du -h {} \; 2>/dev/null | sort -rh | head -10
    # 可集成到告警系统
    # curl -X POST -d "磁盘使用率告警: ${USAGE}%" http://alert-gateway/api/alert
fi
```

---

## 日志对接 ELK / Loki 方案

### 方案一：ELK Stack（Elasticsearch + Logstash + Kibana）

适用于大规模集群的集中式日志管理：

```
计算节点                          日志中心
┌──────────┐    ┌──────────┐    ┌─────────────────┐
│ Filebeat │───▶│ Logstash │───▶│ Elasticsearch    │
│ (采集)   │    │ (过滤)   │    │ (存储+搜索)      │
└──────────┘    └──────────┘    └────────┬────────┘
                                         │
                                         ▼
                                ┌─────────────────┐
                                │    Kibana       │
                                │  (可视化+检索)   │
                                └─────────────────┘
```

**Filebeat 配置（计算节点）：**

```yaml
# /etc/filebeat/filebeat.yml
filebeat.inputs:
  # 驱动日志
  - type: filestream
    id: ascend-driver-log
    paths:
      - /var/log/ascend/driver/*.log

  # CANN 日志
  - type: filestream
    id: ascend-cann-wf
    paths:
      - /home/*/ascend/log/plog/*.wf

  # dmesg
  - type: filestream
    id: dmesg
    paths:
      - /var/log/dmesg

# 输出到 Logstash
output.logstash:
  hosts: ["logstash-server:5044"]

# 自动添加主机名标签
processors:
  - add_fields:
      target: ''
      fields:
        hostname: ${hostname}
        service: ascend-npu
```

**Logstash 过滤配置：**

```conf
# /etc/logstash/conf.d/ascend.conf
input {
  beats {
    port => 5044
  }
}

filter {
  # 昇腾驱动日志解析
  if "ascend-driver-log" in [tags] {
    grok {
      match => {
        "message" => "%{TIMESTAMP_ISO8601:timestamp} \[%{LOGLEVEL:level}\] %{GREEDYDATA:content}"
      }
    }
  }

  # 添加日志级别标签
  if [level] == "ERROR" or [level] == "FATAL" {
    mutate {
      add_tag => ["alert"]
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "ascend-logs-%{+YYYY.MM.dd}"
  }
}
```

### 方案二：Grafana Loki（轻量级）

Loki 是 Grafana 团队推出的轻量级日志系统，与 Prometheus/Grafana 生态无缝集成：

```
计算节点                    日志中心
┌──────────┐              ┌─────────────────┐
│ Promtail │─────────────▶│     Loki         │
│ (采集)   │              │   (存储+索引)    │
└──────────┘              └────────┬────────┘
                                   │
                                   ▼
                          ┌─────────────────┐
                          │    Grafana       │
                          │ (日志+指标一体)  │
                          └─────────────────┘
```

**Promtail 配置：**

```yaml
# /etc/promtail/promtail.yml
server:
  http_listen_port: 9080

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki-server:3100/loki/api/v1/push

scrape_configs:
  # 昇腾驱动日志
  - job_name: ascend-driver
    static_configs:
      - targets: [localhost]
        labels:
          job: ascend-driver
          hostname: node-01
          __path__: /var/log/ascend/driver/*.log

  # CANN .wf 日志
  - job_name: ascend-cann-wf
    static_configs:
      - targets: [localhost]
        labels:
          job: ascend-cann-wf
          hostname: node-01
          __path__: /home/*/ascend/log/plog/*.wf

  # dmesg
  - job_name: dmesg
    static_configs:
      - targets: [localhost]
        labels:
          job: dmesg
          hostname: node-01
          __path__: /var/log/dmesg
```

**在 Grafana 中查询日志：**

```logql
# 查看所有昇腾驱动日志
{job="ascend-driver"}

# 查看 ERROR 级别日志
{job="ascend-driver"} |= "ERROR"

# 查看特定节点的告警日志
{job="ascend-cann-wf", hostname="compute-01"}

# 查看包含 PCIe 错误的日志
{job="ascend-driver"} |= "pcie" |= "error"

# 关联指标与日志：当温度告警时查看同一时间段的日志
{job="ascend-driver"} |= "thermal" | json
```

### 方案对比

| 维度 | ELK | Loki |
|------|-----|------|
| 资源占用 | 高（Elasticsearch 需要 JVM） | 低（Go 实现） |
| 全文搜索 | 强（倒排索引） | 弱（仅标签索引） |
| 日志量大时 | 性能好 | 更适合日志量适中的场景 |
| 与 Grafana 集成 | 需要插件 | 原生支持 |
| 部署复杂度 | 高 | 中 |
| 存储成本 | 高 | 低 |
| 推荐场景 | 大规模集群、全文检索需求 | 中小规模、与 Grafana 统一 |

---

## 最佳实践

### 日志保留策略

| 日志类型 | 保留时间 | 轮转策略 | 存储位置 |
|----------|----------|----------|----------|
| 驱动日志 | 7 天 | 500M/天，压缩 | 本地 |
| CANN 日志 | 14 天 | 200M/文件，压缩 | 本地 |
| .wf 日志 | 30 天 | 不轮转，压缩 | 本地 |
| dmesg | 7 天 | 系统默认 | 本地 |
| 集中式日志 | 90 天 | 按天索引 | ELK/Loki |

### 日志安全

```bash
# 限制驱动日志目录权限
chmod 750 /var/log/ascend/
chmod 640 /var/log/ascend/driver/*.log

# 确保诊断日志不包含敏感信息
# 收集前检查：
grep -ri "password\|token\|key\|secret" /tmp/ascend_diag_* 2>/dev/null
```

### 故障后的日志保护

```bash
# 发生故障后，立即保护日志不被覆盖
# 1. 立即备份当前日志
cp -r ~/ascend/log ~/ascend/log_backup_$(date '+%Y%m%d_%H%M%S')

# 2. 停止 logrotate
sudo systemctl stop logrotate

# 3. 收集诊断日志
/opt/ascend-monitor/collect_diag.sh

# 4. 分析完成后恢复 logrotate
sudo systemctl start logrotate
```

---

## 常见问题

**Q: CANN 日志目录 `~/ascend/log` 为空？**

A:
1. 确认 CANN 环境变量已设置：`echo $ASCEND_HOME_PATH`
2. 检查日志级别是否过高：`echo $ASCEND_GLOBAL_LOG_LEVEL`（设为 3=ERROR 时只记录错误）
3. 确认有 NPU 任务执行过（日志在任务运行时才产生）

**Q: 日志文件过大撑爆磁盘？**

A: 配置 logrotate（见上方配置），或手动清理：
```bash
# 查看最大的日志文件
find /var/log/ascend ~/ascend/log -name "*.log*" -exec du -h {} \; | sort -rh | head -10

# 清空大文件（保留文件但清空内容）
find /var/log/ascend -name "*.log" -size +500M -exec truncate -s 0 {} \;
```

**Q: 如何在故障发生后找回被覆盖的日志？**

A: 如果启用了集中式日志（ELK/Loki），可以从日志中心查询。如果没有，dmesg 的旧内容可能已丢失。建议配置 `persistent dmesg`：
```bash
# 将 dmesg 持久化到文件
echo 'kernel.dmesg_restrict = 0' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
# 确认 /var/log/dmesg 或 journalctl 可用
journalctl -k --since "1 hour ago"
```

---

::: tip 至此
至此，运维监控体系的全部内容已完成。建议从 [总览](./) 开始通读，然后按顺序搭建采集、存储、展示、告警、巡检和日志管理模块。
:::
