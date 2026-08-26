---
layout: doc
title: 巡检与应急 SOP
description: 昇腾智算服务器日常巡检清单、自动化巡检脚本、故障应急处理标准操作流程（SOP），以及故障复盘与巡检报告模板。
---

# 巡检与应急 SOP

> 监控告警解决的是"被动发现"问题，巡检则是"主动预防"。本章提供完整的巡检清单、自动化脚本和故障应急流程，让运维工作有章可循。

---

## 日常巡检 Checklist

### 每日巡检（建议每天 9:00 执行）

| 序号 | 巡检项 | 检查方法 | 正常标准 | 异常处理 |
|------|--------|----------|----------|----------|
| 1 | NPU 在线数量 | `npu-smi info` | 所有 NPU 可见 | 按"掉卡 SOP"处理 |
| 2 | NPU 健康状态 | `npu-smi info -t health` | 全部为 OK | 按"健康异常 SOP"处理 |
| 3 | NPU 温度 | `npu-smi info` | 所有卡 < 80°C | 检查散热、降频 |
| 4 | ECC 错误 | `npu-smi info -t ecc` | UE=0，CE 无激增 | UE>0 需更换硬件 |
| 5 | HCCS 拓扑 | `npu-smi info -t topo` | 全部 HCCS 互联 | 检查链路、重启驱动 |
| 6 | 驱动服务 | `systemctl status npu-driver` | active (running) | 重启驱动服务 |
| 7 | 监控组件 | `systemctl status ascend-exporter` | active (running) | 重启 Exporter |
| 8 | Prometheus 采集 | `http://prom:9090/targets` | 所有 Target UP | 检查网络/Exporter |
| 9 | 活跃告警 | AlertManager Web UI | 无 P0/P1 告警 | 处理未恢复告警 |
| 10 | 磁盘空间 | `df -h` | 使用率 < 80% | 清理日志/临时文件 |
| 11 | 系统日志错误 | `dmesg \| tail -50` | 无 NPU 相关报错 | 按错误信息排查 |

### 每周巡检（建议每周一执行）

| 序号 | 巡检项 | 检查方法 | 正常标准 | 异常处理 |
|------|--------|----------|----------|----------|
| 1 | 固件版本一致性 | `npu-smi info -t board` | 所有节点版本一致 | 安排版本统一升级 |
| 2 | NPU 功耗趋势 | Grafana 功耗面板 | 无异常尖峰 | 检查负载任务 |
| 3 | 显存利用率趋势 | Grafana 显存面板 | 无持续 100% | 排查显存泄漏 |
| 4 | 算力利用率趋势 | Grafana 算力面板 | 负载合理分布 | 排查空闲资源 |
| 5 | ECC 错误趋势 | Grafana ECC 面板 | CE 增长平稳 | 安排硬件检修 |
| 6 | 日志文件大小 | `du -sh /var/log/ascend/` | < 10GB | 执行日志清理 |
| 7 | 告警历史回顾 | AlertManager Web UI | 无反复告警 | 优化告警规则 |
| 8 | BMC/IPMI 事件 | `ipmitool sel list` | 无硬件告警事件 | 处理硬件告警 |

### 每月巡检（建议每月初执行）

| 序号 | 巡检项 | 检查方法 | 正常标准 | 异常处理 |
|------|--------|----------|----------|----------|
| 1 | 驱动/固件版本检查 | 对比官方最新版本 | 不落后大版本 | 安排升级计划 |
| 2 | Prometheus 数据保留 | `du -sh /data/prometheus/` | < 容量 80% | 调整保留策略 |
| 3 | Grafana 仪表盘审查 | 检查面板可用性 | 所有面板有数据 | 修复失效面板 |
| 4 | 告警规则审查 | 评估告警有效性 | 无误报/漏报 | 调整阈值/规则 |
| 5 | 巡检脚本可用性 | 执行巡检脚本 | 脚本正常输出 | 修复脚本 |
| 6 | 备份配置文件 | 检查备份完整性 | 配置已备份 | 执行备份 |
| 7 | 运维知识库更新 | 更新故障案例 | 新案例已记录 | 补充记录 |
| 8 | 容量规划评估 | 评估资源使用率 | 有扩容余量 | 提交扩容申请 |

---

## 自动巡检脚本

### 一键巡检脚本

```bash
#!/bin/bash
# /opt/ascend-monitor/auto_inspection.sh
# 昇腾集群自动巡检脚本
# 用法: ./auto_inspection.sh [节点列表文件]
# 示例: ./auto_inspection.sh /opt/ascend-monitor/nodes.txt

set -euo pipefail

# ============ 配置 ============
NODES_FILE="${1:-/opt/ascend-monitor/nodes.txt}"
REPORT_DIR="/var/log/ascend-monitor/inspection"
REPORT_DATE=$(date '+%Y%m%d_%H%M%S')
REPORT_FILE="$REPORT_DIR/inspection_${REPORT_DATE}.md"
SUMMARY_FILE="$REPORT_DIR/inspection_${REPORT_DATE}.summary"
PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

mkdir -p "$REPORT_DIR"

# 读取节点列表
if [ ! -f "$NODES_FILE" ]; then
    echo "节点列表文件不存在: $NODES_FILE"
    echo "请创建文件，每行一个节点IP，例如:"
    echo "10.10.1.101"
    echo "10.10.1.102"
    exit 1
fi

NODES=$(grep -v '^#' "$NODES_FILE" | grep -v '^$')

# ============ 报告头 ============
cat > "$REPORT_FILE" << 'EOF'
# 昇腾集群巡检报告

EOF
echo "| 项目 | 内容 |" >> "$REPORT_FILE"
echo "|------|------|" >> "$REPORT_FILE"
echo "| 巡检时间 | $(date '+%Y-%m-%d %H:%M:%S') |" >> "$REPORT_FILE"
echo "| 巡检节点数 | $(echo "$NODES" | wc -l) |" >> "$REPORT_FILE"
echo "| 巡检人 | 自动巡检脚本 |" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# ============ 巡检函数 ============

check_node() {
    local node=$1
    echo "" >> "$REPORT_FILE"
    echo "## 节点: $node" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"

    # --- 检查 SSH 连通性 ---
    if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$node" "echo ok" >/dev/null 2>&1; then
        echo "| 检查项 | 结果 | 状态 | 详情 |" >> "$REPORT_FILE"
        echo "|------|------|------|------|" >> "$REPORT_FILE"
        echo "| SSH 连通性 | 失败 | FAIL | 节点不可达 |" >> "$REPORT_FILE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        return
    fi
    echo "| 检查项 | 结果 | 状态 | 详情 |" >> "$REPORT_FILE"
    echo "|------|------|------|------|" >> "$REPORT_FILE"
    echo "| SSH 连通性 | 成功 | PASS | - |" >> "$REPORT_FILE"
    PASS_COUNT=$((PASS_COUNT + 1))

    # --- 检查 NPU 数量 ---
    local npu_count
    npu_count=$(ssh -o ConnectTimeout=5 "$node" "npu-smi info -l 2>/dev/null | grep 'Total Count' | awk '{print \$3}'" 2>/dev/null || echo "0")
    if [ "$npu_count" -ge 1 ] 2>/dev/null; then
        echo "| NPU 在线数量 | $npu_count | PASS | - |" >> "$REPORT_FILE"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "| NPU 在线数量 | $npu_count | FAIL | NPU 不可见，可能驱动异常 |" >> "$REPORT_FILE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    # --- 检查健康状态 ---
    local unhealthy
    unhealthy=$(ssh -o ConnectTimeout=5 "$node" "npu-smi info -t health 2>/dev/null | grep -v 'OK' | grep -c 'Warning\|Critical\|Fault'" 2>/dev/null || echo "0")
    if [ "$unhealthy" -eq 0 ]; then
        echo "| NPU 健康状态 | 全部OK | PASS | - |" >> "$REPORT_FILE"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "| NPU 健康状态 | $unhealthy 张异常 | WARN | 存在非OK状态设备 |" >> "$REPORT_FILE"
        WARN_COUNT=$((WARN_COUNT + 1))
    fi

    # --- 检查温度 ---
    local high_temp
    high_temp=$(ssh -o ConnectTimeout=5 "$node" "npu-smi info 2>/dev/null | awk -F'|' '/^\| [0-9]/ {print \$4}' | awk '{if (\$2+0 > 80) print \$2}' | wc -l" 2>/dev/null || echo "0")
    if [ "$high_temp" -eq 0 ]; then
        echo "| NPU 温度 | 正常 | PASS | 所有卡 < 80°C |" >> "$REPORT_FILE"
        PASS_COUNT=$((PASS_COUNT + 1))
    elif [ "$high_temp" -le 2 ]; then
        echo "| NPU 温度 | $high_temp 张高温 | WARN | 超过 80°C |" >> "$REPORT_FILE"
        WARN_COUNT=$((WARN_COUNT + 1))
    else
        echo "| NPU 温度 | $high_temp 张高温 | FAIL | 多卡超过 80°C |" >> "$REPORT_FILE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    # --- 检查 ECC 错误 ---
    local ue_count
    ue_count=$(ssh -o ConnectTimeout=5 "$node" "npu-smi info -t ecc 2>/dev/null | grep 'UE Count' | awk '{sum+=\$3} END{print sum+0}'" 2>/dev/null || echo "0")
    if [ "$ue_count" -eq 0 ]; then
        echo "| ECC 不可纠正错误 | 0 | PASS | - |" >> "$REPORT_FILE"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "| ECC 不可纠正错误 | $ue_count | FAIL | 存在 UE 错误，需更换硬件 |" >> "$REPORT_FILE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    # --- 检查驱动服务 ---
    local driver_status
    driver_status=$(ssh -o ConnectTimeout=5 "$node" "systemctl is-active npu-driver 2>/dev/null || echo unknown" 2>/dev/null || echo "unknown")
    if [ "$driver_status" = "active" ]; then
        echo "| 驱动服务状态 | active | PASS | - |" >> "$REPORT_FILE"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "| 驱动服务状态 | $driver_status | FAIL | 驱动服务未运行 |" >> "$REPORT_FILE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    # --- 检查 Exporter 服务 ---
    local exporter_status
    exporter_status=$(ssh -o ConnectTimeout=5 "$node" "systemctl is-active ascend-exporter 2>/dev/null || echo unknown" 2>/dev/null || echo "unknown")
    if [ "$exporter_status" = "active" ]; then
        echo "| Exporter 服务状态 | active | PASS | - |" >> "$REPORT_FILE"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "| Exporter 服务状态 | $exporter_status | WARN | Exporter 未运行 |" >> "$REPORT_FILE"
        WARN_COUNT=$((WARN_COUNT + 1))
    fi

    # --- 检查磁盘空间 ---
    local disk_usage
    disk_usage=$(ssh -o ConnectTimeout=5 "$node" "df -h / | tail -1 | awk '{print \$5}' | tr -d '%'" 2>/dev/null || echo "100")
    if [ "$disk_usage" -lt 80 ]; then
        echo "| 磁盘空间 | ${disk_usage}% | PASS | - |" >> "$REPORT_FILE"
        PASS_COUNT=$((PASS_COUNT + 1))
    elif [ "$disk_usage" -lt 90 ]; then
        echo "| 磁盘空间 | ${disk_usage}% | WARN | 使用率超 80% |" >> "$REPORT_FILE"
        WARN_COUNT=$((WARN_COUNT + 1))
    else
        echo "| 磁盘空间 | ${disk_usage}% | FAIL | 使用率超 90% |" >> "$REPORT_FILE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    # --- 检查 dmesg 错误 ---
    local dmesg_errors
    dmesg_errors=$(ssh -o ConnectTimeout=5 "$node" "dmesg 2>/dev/null | grep -i 'davinci\|npu\|ascend' | grep -i 'error\|fail\|fault' | tail -5 | wc -l" 2>/dev/null || echo "0")
    if [ "$dmesg_errors" -eq 0 ]; then
        echo "| dmesg NPU 错误 | 无 | PASS | - |" >> "$REPORT_FILE"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "| dmesg NPU 错误 | ${dmesg_errors}条 | WARN | 存在内核日志错误 |" >> "$REPORT_FILE"
        WARN_COUNT=$((WARN_COUNT + 1))
    fi

    echo "" >> "$REPORT_FILE"
}

# ============ 执行巡检 ============
echo "开始巡检，共 $(echo "$NODES" | wc -l) 个节点..."
echo ""

for node in $NODES; do
    echo "正在巡检: $node"
    check_node "$node"
done

# ============ 汇总 ============
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## 巡检汇总" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 统计项 | 数量 |" >> "$REPORT_FILE"
echo "|--------|------|" >> "$REPORT_FILE"
echo "| 检查通过 (PASS) | $PASS_COUNT |" >> "$REPORT_FILE"
echo "| 警告 (WARN) | $WARN_COUNT |" >> "$REPORT_FILE"
echo "| 失败 (FAIL) | $FAIL_COUNT |" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "## 需立即处理的问题" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "有 $FAIL_COUNT 项检查失败，请立即处理！" >> "$REPORT_FILE"
elif [ "$WARN_COUNT" -gt 0 ]; then
    echo "## 需关注的问题" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "有 $WARN_COUNT 项警告，请在当天内处理。" >> "$REPORT_FILE"
else
    echo "## 巡检结论" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    echo "所有检查项均通过，集群运行正常。" >> "$REPORT_FILE"
fi

# ============ 输出摘要 ============
echo "巡检完成！" | tee "$SUMMARY_FILE"
echo "通过: $PASS_COUNT | 警告: $WARN_COUNT | 失败: $FAIL_COUNT" | tee -a "$SUMMARY_FILE"
echo "详细报告: $REPORT_FILE" | tee -a "$SUMMARY_FILE"

# 如果有失败项，返回非零退出码
if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
```

### 配置定时巡检

```bash
# 赋予执行权限
chmod +x /opt/ascend-monitor/auto_inspection.sh

# 创建节点列表文件
cat > /opt/ascend-monitor/nodes.txt << 'EOF'
# 计算节点IP列表，每行一个
10.10.1.101
10.10.1.102
10.10.2.101
10.10.2.102
EOF

# 配置 crontab：每天 9:00 自动巡检
echo "0 9 * * * /opt/ascend-monitor/auto_inspection.sh >> /var/log/ascend-monitor/inspection/cron.log 2>&1" | sudo tee -a /etc/crontab
```

---

## 故障应急 SOP

### SOP 1：NPU 掉卡处理流程

```
触发条件：npu-smi info 中某张 NPU 消失 / Prometheus 告警 NPULost
```

| 步骤 | 操作 | 命令 | 预期结果 |
|------|------|------|----------|
| 1 | 确认掉卡现象 | `npu-smi info` | 确认哪张卡消失 |
| 2 | 检查驱动服务 | `systemctl status npu-driver` | 服务是否 running |
| 3 | 检查 dmesg 日志 | `dmesg \| grep -i davinci \| tail -20` | 查看是否有 PCIe 错误 |
| 4 | 检查 PCIe 设备 | `lspci \| grep -i d500` | NPU PCIe 设备是否存在 |
| 5a | PCIe 设备存在 → 重启驱动 | `sudo systemctl restart npu-driver` | 驱动重启后 NPU 恢复 |
| 5b | PCIe 设备不存在 → 硬件问题 | 联系硬件运维 | 需要 reseat 或更换 |
| 6 | 重启驱动后验证 | `npu-smi info` | NPU 是否恢复 |
| 7 | 仍未恢复 → 重新加载驱动 | `sudo rmmod drv_pcie_host && sudo modprobe drv_pcie_host` | - |
| 8 | 仍未恢复 → 重启服务器 | `sudo reboot` | 最后手段 |
| 9 | 重启后仍未恢复 | 联系硬件厂商 | 需要更换 NPU 卡 |

```bash
# 快速处理脚本
#!/bin/bash
# NPU 掉卡应急处理
echo "=== NPU 掉卡处理流程 ==="
echo "1. 检查 NPU 状态..."
npu-smi info
echo ""
echo "2. 检查驱动服务..."
systemctl status npu-driver --no-pager
echo ""
echo "3. 检查 dmesg..."
dmesg | grep -i "davinci\|d500\|npu" | tail -20
echo ""
echo "4. 检查 PCIe..."
lspci | grep -i "d500\|huawei"
echo ""
echo "请根据以上信息判断："
echo "  - 如果 PCIe 设备存在 -> 尝试: sudo systemctl restart npu-driver"
echo "  - 如果 PCIe 设备不存在 -> 硬件问题，联系运维"
echo "  - 重启驱动后仍未恢复 -> 尝试: sudo reboot"
```

### SOP 2：驱动异常重启流程

```
触发条件：npu-smi 报错 / 驱动服务挂掉 / 任务报 NPU 相关错误
```

| 步骤 | 操作 | 命令 |
|------|------|------|
| 1 | 通知正在运行的任务方 | 通知用户暂停/保存任务 |
| 2 | 收集故障日志 | `bash /opt/ascend-monitor/collect_diag.sh` |
| 3 | 停止使用 NPU 的进程 | `ps aux \| grep -i python` → 确认无任务占用 |
| 4 | 停止驱动服务 | `sudo systemctl stop npu-driver` |
| 5 | 等待 10 秒 | `sleep 10` |
| 6 | 启动驱动服务 | `sudo systemctl start npu-driver` |
| 7 | 验证驱动状态 | `systemctl status npu-driver && npu-smi info` |
| 8 | 检查 NPU 健康 | `npu-smi info -t health` |
| 9 | 检查 HCCS 拓扑 | `npu-smi info -t topo` |
| 10 | 恢复任务 | 通知用户可恢复运行 |

::: warning 注意
重启驱动会导致该节点所有 NPU 上的任务中断！操作前务必通知相关用户。
:::

### SOP 3：温度过高降级流程

```
触发条件：NPU 温度 > 85°C 告警
```

| 步骤 | 操作 | 命令 |
|------|------|------|
| 1 | 确认温度 | `npu-smi info` 查看具体哪张卡温度高 |
| 2 | 检查机房环境 | 查看机房空调温度、服务器风扇转速 |
| 3 | 降低功耗限制 | `npu-smi set -i <id> -c 0 -t power -d 280`（从 350W 降至 280W） |
| 4 | 监控温度变化 | `watch -n 5 npu-smi info` |
| 5a | 温度下降至 75°C 以下 | 恢复功耗限制，保持观察 |
| 5b | 温度未下降 | 降低任务负载或暂停任务 |
| 6 | 温度仍 > 90°C | 停止该卡上的所有任务 |
| 7 | 记录并上报 | 记录事件，联系设施团队检查散热 |

```bash
# 温度过高快速处理
#!/bin/bash
NPU_ID=$1
if [ -z "$NPU_ID" ]; then
    echo "用法: $0 <npu_id>"
    exit 1
fi

echo "当前温度:"
npu-smi info -i $NPU_ID | grep -A1 "^| $NPU_ID"

echo "降低功耗限制至 280W..."
npu-smi set -i $NPU_ID -c 0 -t power -d 280

echo "等待 60 秒后检查温度..."
sleep 60
npu-smi info -i $NPU_ID
```

### SOP 4：显存泄漏处理流程

```
触发条件：显存利用率持续 100% 但无任务运行 / 任务结束后显存未释放
```

| 步骤 | 操作 | 命令 |
|------|------|------|
| 1 | 确认显存状态 | `npu-smi info` 查看哪张卡显存满 |
| 2 | 检查进程占用 | `lsof /dev/davinci<id>` 或 `fuser /dev/davinci<id>` |
| 3a | 有残留进程 | `kill -9 <pid>` 清理进程 |
| 3b | 无残留进程 | 显存可能泄漏，需重启驱动 |
| 4 | 清理后验证 | `npu-smi info` 确认显存已释放 |
| 5 | 仍未释放 | `sudo systemctl restart npu-driver` |
| 6 | 记录泄漏场景 | 记录触发条件，提交 issue |

```bash
# 显存泄漏排查
#!/bin/bash
NPU_ID=$1
echo "=== 显存泄漏排查 (NPU $NPU_ID) ==="
echo "当前显存状态:"
npu-smi info -i $NPU_ID
echo ""
echo "占用 NPU $NPU_ID 的进程:"
fuser /dev/davinci${NPU_ID} 2>/dev/null || echo "无进程占用"
echo ""
echo "相关进程详情:"
ps aux | grep -v grep | grep -E "python|train|inference" | head -10
```

---

## 故障复盘模板

```markdown
# 故障复盘报告

## 基本信息

| 项目 | 内容 |
|------|------|
| 故障编号 | INC-YYYYMMDD-XXX |
| 故障级别 | P0 / P1 / P2 |
| 故障时间 | YYYY-MM-DD HH:MM:SS ~ YYYY-MM-DD HH:MM:SS |
| 持续时长 | X 小时 X 分钟 |
| 影响范围 | 受影响的节点、NPU、任务 |
| 故障发现方式 | 告警 / 巡检 / 用户反馈 |

## 故障经过

### 时间线

| 时间 | 事件 |
|------|------|
| HH:MM | 告警触发：XXX |
| HH:MM | 运维人员收到通知 |
| HH:MM | 开始排查 |
| HH:MM | 定位根因 |
| HH:MM | 执行修复 |
| HH:MM | 验证恢复 |
| HH:MM | 故障关闭 |

## 根因分析

### 直接原因
（描述导致故障发生的直接技术原因）

### 根本原因
（分析导致直接原因的深层因素：流程缺陷、监控缺失、配置不当等）

## 影响评估

| 维度 | 影响 |
|------|------|
| 业务影响 | 训练任务中断 X 个，损失算力 X GPU·小时 |
| 数据影响 | 是否有数据丢失或损坏 |
| 用户影响 | 影响 X 个用户/团队 |

## 处理过程

（描述故障处理的完整过程，包含排查步骤、尝试的方案、最终解决方案）

## 经验教训

### 做得好的
1. ...
2. ...

### 做得不好的
1. ...
2. ...

## 改进措施

| 序号 | 改进项 | 负责人 | 截止日期 | 状态 |
|------|--------|--------|----------|------|
| 1 | 新增 XXX 告警规则 | XXX | YYYY-MM-DD | 待办 |
| 2 | 更新 SOP 文档 | XXX | YYYY-MM-DD | 待办 |
| 3 | 增加巡检项 | XXX | YYYY-MM-DD | 待办 |

## 附件

- 故障期间监控截图
- 日志收集文件
- 相关配置文件
```

---

## 巡检报告模板

```markdown
# 昇腾集群巡检报告

## 巡检概要

| 项目 | 内容 |
|------|------|
| 巡检日期 | YYYY-MM-DD |
| 巡检人 | XXX |
| 巡检范围 | X 个节点，X 张 NPU |
| 巡检类型 | 日常巡检 / 周巡检 / 月巡检 |

## 巡检结论

- 检查通过: X 项
- 警告: X 项
- 失败: X 项
- 总体评价: 正常 / 需关注 / 需立即处理

## 详情

### 1. NPU 设备状态

| 节点 | NPU 数量 | 健康状态 | 温度范围 | 备注 |
|------|----------|----------|----------|------|
| compute-01 | 8/8 | 全部OK | 42~68°C | - |
| compute-02 | 8/8 | 1张Warning | 45~85°C | NPU-2 温度偏高 |

### 2. HCCS 链路状态

| 节点 | 拓扑状态 | 异常链路 | 备注 |
|------|----------|----------|------|
| compute-01 | 全互联 | 无 | - |
| compute-02 | 全互联 | 无 | - |

### 3. ECC 错误统计

| 节点 | CE 错误 | UE 错误 | 趋势 | 备注 |
|------|---------|---------|------|------|
| compute-01 | 12 | 0 | 平稳 | - |
| compute-02 | 156 | 0 | 增长 | NPU-2 CE 增长较快 |

### 4. 服务状态

| 节点 | 驱动服务 | Exporter | Prometheus Target | 备注 |
|------|----------|----------|-------------------|------|
| compute-01 | active | active | UP | - |
| compute-02 | active | active | UP | - |

### 5. 资源使用

| 节点 | 磁盘使用率 | 内存使用率 | 日志大小 | 备注 |
|------|-----------|-----------|----------|------|
| compute-01 | 45% | 60% | 2.3GB | - |
| compute-02 | 82% | 70% | 8.5GB | 磁盘需清理 |

## 需处理问题

| 序号 | 问题描述 | 级别 | 负责人 | 截止日期 |
|------|----------|------|--------|----------|
| 1 | compute-02 NPU-2 温度 85°C | WARN | XXX | 当天 |
| 2 | compute-02 磁盘使用率 82% | WARN | XXX | 当天 |
| 3 | compute-02 NPU-2 CE 错误增长 | WARN | XXX | 本周 |

## 巡检签字

- 巡检人: ____________  日期: ____________
- 审核人: ____________  日期: ____________
```

---

::: tip 下一步
巡检过程中收集的日志是故障分析的关键证据，请参阅 [日志管理](./log-management) 了解昇腾日志的目录结构、收集方法与分析技巧。
:::
