---
layout: doc
title: 告警规则与通知
description: 配置 AlertManager 和 Prometheus 告警规则，实现 NPU 温度过高、掉卡、显存满载、HCCS 链路异常、ECC 错误等关键故障的自动告警与多渠道通知。
---

# 告警规则与通知

> 告警是监控体系的最后一公里——采集到的异常必须及时通知到人，否则监控就只是"事后诸葛亮"。本章配置完整的告警规则与通知链路。

---

## AlertManager 安装与配置

### 安装 AlertManager

```bash
cd /opt
wget https://github.com/prometheus/alertmanager/releases/download/v0.26.0/alertmanager-0.26.0.linux-amd64.tar.gz
tar -xzf alertmanager-0.26.0.linux-amd64.tar.gz
mv alertmanager-0.26.0.linux-amd64 alertmanager

mkdir -p /data/alertmanager
useradd --no-create-home --shell /bin/false alertmanager 2>/dev/null || true
chown -R alertmanager:alertmanager /opt/alertmanager /data/alertmanager
```

### systemd 服务

```ini
# /etc/systemd/system/alertmanager.service
[Unit]
Description=Prometheus AlertManager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/opt/alertmanager/alertmanager \
  --config.file=/opt/alertmanager/alertmanager.yml \
  --storage.path=/data/alertmanager \
  --web.listen-address=0.0.0.0:9093
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

# 验证：浏览器访问 http://<server-ip>:9093
```

### AlertManager 配置文件

```yaml
# /opt/alertmanager/alertmanager.yml
# AlertManager 配置 - 昇腾 NPU 监控告警

global:
  # 邮件 SMTP 配置
  smtp_smarthost: 'smtp.example.com:25'
  smtp_from: 'ascend-alert@example.com'
  smtp_auth_username: 'ascend-alert@example.com'
  smtp_auth_password: 'your-smtp-password'
  smtp_require_tls: false

# 告警模板
templates:
  - '/opt/alertmanager/templates/*.tmpl'

# 告警分组与路由
route:
  # 按告警名称和级别分组
  group_by: ['alertname', 'severity', 'hostname']
  # 首次告警等待时间（同组告警合并发送）
  group_wait: 10s
  # 同组告警发送间隔
  group_interval: 5m
  # 重复告警间隔
  repeat_interval: 4h
  # 默认接收者
  receiver: 'default-email'

  routes:
    # P0 级别告警：立即通知所有渠道
    - matchers:
        - severity = "P0"
      receiver: 'p0-all-channels'
      group_wait: 0s
      repeat_interval: 30m

    # P1 级别告警：通知邮件+企业微信
    - matchers:
        - severity = "P1"
      receiver: 'p1-email-wecom'
      repeat_interval: 1h

    # P2 级别告警：仅通知邮件
    - matchers:
        - severity = "P2"
      receiver: 'p2-email'
      repeat_interval: 4h

# 告警抑制规则
inhibit_rules:
  # 如果 NPU 故障（Fault）已告警，则抑制同设备的 Warning 告警
  - source_matchers:
      - alertname = "NPUCriticalFault"
    target_matchers:
      - alertname = "NPUHealthWarning"
    equal: ['hostname', 'npu_id']

  # 如果 NPU 掉卡已告警，则抑制该设备的其他告警
  - source_matchers:
      - alertname = "NPULost"
    target_matchers:
      - severity =~ "P1|P2"
    equal: ['hostname', 'npu_id']

  # 如果温度超过 95°C（P0），则抑制 85°C（P1）告警
  - source_matchers:
      - alertname = "NPUTemperatureCritical"
    target_matchers:
      - alertname = "NPUTemperatureHigh"
    equal: ['hostname', 'npu_id']

# 接收者配置
receivers:
  # 默认邮件接收
  - name: 'default-email'
    email_configs:
      - to: 'ascend-ops@example.com'
        send_resolved: true

  # P0：所有渠道
  - name: 'p0-all-channels'
    email_configs:
      - to: 'ascend-ops@example.com,ascend-leader@example.com'
        send_resolved: true
    webhook_configs:
      - url: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=YOUR_WECOM_KEY'
        send_resolved: true
    webhook_configs:
      - url: 'https://open.feishu.cn/open-apis/bot/v2/hook/YOUR_FEISHU_TOKEN'
        send_resolved: true

  # P1：邮件 + 企业微信
  - name: 'p1-email-wecom'
    email_configs:
      - to: 'ascend-ops@example.com'
        send_resolved: true
    webhook_configs:
      - url: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=YOUR_WECOM_KEY'
        send_resolved: true

  # P2：仅邮件
  - name: 'p2-email'
    email_configs:
      - to: 'ascend-ops@example.com'
        send_resolved: true
```

### 热加载配置

```bash
# 检查配置语法
/opt/alertmanager/amtool check-config /opt/alertmanager/alertmanager.yml

# 热加载
curl -X POST http://localhost:9093/-/reload
```

---

## 告警规则模板

### Prometheus 告警规则文件

```yaml
# /opt/prometheus/rules/ascend_alerts.yml
# 昇腾 NPU 监控告警规则

groups:
  # ============ 设备健康告警 ============
  - name: npu_health_alerts
    interval: 15s
    rules:
      # NPU 掉卡告警（设备消失）
      - alert: NPULost
        expr: |
          (ascend_npu_count by (hostname)) < 8
          or
          absent(ascend_npu_health{hostname="compute-01"})
        for: 1m
        labels:
          severity: P0
          category: device
        annotations:
          summary: "NPU 掉卡告警 - {{ $labels.hostname }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU 数量异常，
            当前在线 NPU 数量可能少于预期。
            请立即登录该节点执行 `npu-smi info` 检查。
          runbook: "参见巡检与应急SOP > NPU掉卡处理流程"

      # NPU 健康状态异常（Warning）
      - alert: NPUHealthWarning
        expr: ascend_npu_health == 1
        for: 2m
        labels:
          severity: P1
          category: device
        annotations:
          summary: "NPU 健康状态警告 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            健康状态为 Warning（{{ $value }}）。
            请执行 `npu-smi info -t health -i {{ $labels.npu_id }}` 查看详情。

      # NPU 健康状态严重（Critical/Fault）
      - alert: NPUCriticalFault
        expr: ascend_npu_health >= 2
        for: 30s
        labels:
          severity: P0
          category: device
        annotations:
          summary: "NPU 严重故障 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            健康状态为 Critical/Fault（值={{ $value }}）。
            该设备可能已不可用，请立即处理！

  # ============ 温度告警 ============
  - name: npu_temperature_alerts
    interval: 15s
    rules:
      # 温度过高告警（>85°C）
      - alert: NPUTemperatureHigh
        expr: ascend_npu_temperature_celsius > 85
        for: 2m
        labels:
          severity: P1
          category: temperature
        annotations:
          summary: "NPU 温度过高 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            温度持续超过 85°C（当前: {{ $value }}°C）。
            请检查机房散热环境和风扇状态。

      # 温度严重过高（>95°C）
      - alert: NPUTemperatureCritical
        expr: ascend_npu_temperature_celsius > 95
        for: 30s
        labels:
          severity: P0
          category: temperature
        annotations:
          summary: "NPU 温度严重过高 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            温度超过 95°C（当前: {{ $value }}°C）！
            立即执行降频或停机，防止硬件损坏！

  # ============ 显存告警 ============
  - name: npu_memory_alerts
    interval: 15s
    rules:
      # 显存利用率持续 100%
      - alert: NPUMemoryFull
        expr: |
          (ascend_npu_memory_used_bytes / ascend_npu_memory_total_bytes * 100) >= 100
        for: 5m
        labels:
          severity: P1
          category: memory
        annotations:
          summary: "NPU 显存满载 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            显存持续 100% 占用超过 5 分钟。
            可能存在显存泄漏或任务未正常释放资源。

      # 显存利用率异常偏高（>95% 持续 15 分钟）
      - alert: NPUMemoryNearFull
        expr: |
          (ascend_npu_memory_used_bytes / ascend_npu_memory_total_bytes * 100) > 95
        for: 15m
        labels:
          severity: P2
          category: memory
        annotations:
          summary: "NPU 显存利用率偏高 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            显存利用率超过 95% 持续 15 分钟（当前: {{ printf "%.1f" $value }}%）。

  # ============ HCCS 链路告警 ============
  - name: npu_hccs_alerts
    interval: 15s
    rules:
      # HCCS 链路断开
      - alert: HCCSLinkDown
        expr: ascend_npu_hccs_link_status == 0
        for: 1m
        labels:
          severity: P0
          category: hccs
        annotations:
          summary: "HCCS 链路断开 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            HCCS 端口 {{ $labels.port }} 链路状态为 DOWN。
            多卡训练任务将受严重影响，请立即检查！

      # HCCS 链路降速
      - alert: HCCSLinkDegraded
        expr: ascend_npu_hccs_link_status == 2
        for: 2m
        labels:
          severity: P1
          category: hccs
        annotations:
          summary: "HCCS 链路降速 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            HCCS 端口 {{ $labels.port }} 链路处于 DEGRADED 状态。
            请执行 `npu-smi info -t topo` 检查拓扑。

  # ============ ECC 错误告警 ============
  - name: npu_ecc_alerts
    interval: 30s
    rules:
      # 不可纠正 ECC 错误
      - alert: NPUEccUncorrectable
        expr: ascend_npu_ecc_uncorrectable_errors_total > 0
        for: 30s
        labels:
          severity: P0
          category: ecc
        annotations:
          summary: "NPU 不可纠正 ECC 错误 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            检测到 {{ $value }} 个不可纠正 ECC 错误。
            显存可能已损坏，建议尽快更换硬件！

      # 可纠正 ECC 错误激增（1小时内增量 > 100）
      - alert: NPUEccCorrectableSpike
        expr: |
          increase(ascend_npu_ecc_correctable_errors_total[1h]) > 100
        for: 1m
        labels:
          severity: P1
          category: ecc
        annotations:
          summary: "NPU ECC 错误激增 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            过去1小时新增 {{ printf "%.0f" $value }} 个可纠正 ECC 错误。
            硬件可能正在老化，建议关注并安排检修。

  # ============ 功耗告警 ============
  - name: npu_power_alerts
    interval: 15s
    rules:
      # 功耗超限
      - alert: NPUPowerExceed
        expr: ascend_npu_power_watts > 385
        for: 2m
        labels:
          severity: P1
          category: power
        annotations:
          summary: "NPU 功耗超限 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            功耗持续超过 385W（当前: {{ printf "%.1f" $value }}W，TDP: 350W）。
            请检查是否有异常高负载任务。

  # ============ 驱动服务告警 ============
  - name: npu_driver_alerts
    interval: 30s
    rules:
      # 驱动服务异常
      - alert: NPUDriverServiceDown
        expr: node_systemd_unit_state{name="npu-driver.service", state="active"} == 0
        for: 1m
        labels:
          severity: P0
          category: driver
        annotations:
          summary: "NPU 驱动服务异常 - {{ $labels.hostname }}"
          description: >
            节点 {{ $labels.hostname }} 的 npu-driver 服务未运行。
            请立即执行 `sudo systemctl restart npu-driver` 并检查日志。

      # Exporter 采集失败
      - alert: NPUExporterDown
        expr: up{job="ascend-npu"} == 0
        for: 2m
        labels:
          severity: P1
          category: exporter
        annotations:
          summary: "NPU Exporter 不可达 - {{ $labels.hostname }}"
          description: >
            节点 {{ $labels.hostname }} 的 ascend-exporter 已 2 分钟无响应。
            可能是 Exporter 进程退出或网络中断。

  # ============ 算力利用率告警 ============
  - name: npu_utilization_alerts
    interval: 30s
    rules:
      # 算力利用率持续为 0（可能有任务卡死）
      - alert: NPUIdleButAllocated
        expr: |
          ascend_npu_aicore_utilization_percent == 0
          and on(hostname, npu_id)
          (ascend_npu_memory_used_bytes / ascend_npu_memory_total_bytes > 0.1)
        for: 30m
        labels:
          severity: P2
          category: utilization
        annotations:
          summary: "NPU 算力空闲但显存已分配 - {{ $labels.hostname }} NPU-{{ $labels.npu_id }}"
          description: >
            节点 {{ $labels.hostname }} 的 NPU {{ $labels.npu_id }}
            AI Core 利用率为 0% 但显存占用超过 10%，持续 30 分钟。
            可能有任务卡死未释放资源，请检查进程状态。
```

### 验证告警规则

```bash
# 检查规则语法
/opt/prometheus/promtool check rules /opt/prometheus/rules/ascend_alerts.yml

# 热加载 Prometheus 配置
curl -X POST http://localhost:9090/-/reload

# 在 Prometheus Web UI 查看已加载的规则
# 浏览器访问 http://<prometheus-ip>:9090/rules

# 查看当前活跃的告警
# 浏览器访问 http://<prometheus-ip>:9090/alerts
```

---

## 告警通知渠道配置

### 企业微信 Webhook

```yaml
# AlertManager 中的企业微信 webhook 配置
receivers:
  - name: 'wecom-webhook'
    webhook_configs:
      - url: 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=YOUR_WEBHOOK_KEY'
        send_resolved: true
        max_alerts: 20
```

**企业微信告警模板：**

```yaml
# /opt/alertmanager/templates/wecom.tmpl
{{ define "wecom.text" }}
{{ if eq .Status "firing" }}
昇腾集群告警通知
告警级别：{{ .Labels.severity }}
告警名称：{{ .Labels.alertname }}
故障节点：{{ .Labels.hostname }}
{{ range .Alerts }}
告警详情：{{ .Annotations.description }}
触发时间：{{ .StartsAt.Format "2006-01-02 15:04:05" }}
{{ end }}
{{ else }}
告警已恢复
告警名称：{{ .Labels.alertname }}
故障节点：{{ .Labels.hostname }}
恢复时间：{{ .EndsAt.Format "2006-01-02 15:04:05" }}
{{ end }}
{{ end }}
```

### 飞书 Webhook

```yaml
# AlertManager 中的飞书 webhook 配置
receivers:
  - name: 'feishu-webhook'
    webhook_configs:
      - url: 'https://open.feishu.cn/open-apis/bot/v2/hook/YOUR_BOT_TOKEN'
        send_resolved: true
```

**飞书告警需要中间层转发（AlertManager 原生不兼容飞书格式），推荐使用 PrometheusAlert：**

```bash
# 部署 PrometheusAlert（告警转发网关）
docker run -d --name prometheusalert \
  -p 8080:8080 \
  -e FEISHU_WEBHOOK_URL="https://open.feishu.cn/open-apis/bot/v2/hook/YOUR_BOT_TOKEN" \
  feiyu586/prometheusalert:latest

# AlertManager 配置指向 PrometheusAlert
receivers:
  - name: 'feishu-webhook'
    webhook_configs:
      - url: 'http://localhost:8080/prometheusalert?type=feishu&tpltype=dingding'
        send_resolved: true
```

### 邮件告警

```yaml
receivers:
  - name: 'email-notification'
    email_configs:
      - to: 'ascend-ops@example.com'
        from: 'ascend-alert@example.com'
        smarthost: 'smtp.example.com:25'
        auth_username: 'ascend-alert@example.com'
        auth_password: 'your-password'
        headers:
          Subject: '【{{ .Status }}】昇腾告警 - {{ .CommonLabels.alertname }} - {{ .CommonLabels.hostname }}'
        html: '{{ template "email.html" . }}'
        send_resolved: true
```

**邮件告警模板：**

```yaml
# /opt/alertmanager/templates/email.tmpl
{{ define "email.html" }}
{{ if eq .Status "firing" }}
<h2 style="color: red;">昇腾集群告警 - {{ .CommonLabels.severity }}</h2>
{{ else }}
<h2 style="color: green;">告警已恢复</h2>
{{ end }}
<table border="1" cellpadding="5" style="border-collapse: collapse;">
<tr><td>告警状态</td><td>{{ .Status }}</td></tr>
<tr><td>告警名称</td><td>{{ .CommonLabels.alertname }}</td></tr>
<tr><td>告警级别</td><td>{{ .CommonLabels.severity }}</td></tr>
<tr><td>故障节点</td><td>{{ .CommonLabels.hostname }}</td></tr>
<tr><td>告警数量</td><td>{{ .Alerts | len }}</td></tr>
</table>
<h3>告警详情：</h3>
{{ range .Alerts }}
<hr>
<p><strong>{{ .Labels.alertname }}</strong></p>
<p>节点: {{ .Labels.hostname }} | NPU: {{ .Labels.npu_id }}</p>
<p>{{ .Annotations.description }}</p>
<p>触发时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }}</p>
{{ end }}
{{ end }}
```

---

## 告警分级标准

| 级别 | 含义 | 响应时效 | 通知方式 | 典型场景 |
|------|------|----------|----------|----------|
| **P0** | 紧急 — 服务中断或硬件损坏风险 | **立即处理**（5分钟内响应） | 邮件 + 企业微信 + 飞书 + 电话 | NPU 掉卡、HCCS 断链、UE 错误、温度 >95°C、驱动服务停 |
| **P1** | 重要 — 性能受损或有故障风险 | **1 小时内**处理 | 邮件 + 企业微信 | 温度 >85°C、CE 错误激增、HCCS 降速、显存满载 |
| **P2** | 一般 — 需关注但不紧急 | **当天**处理 | 邮件 | 显存偏高、算力空闲异常、功耗偏高 |

### 告警级别分配原则

```
硬件损坏 / 服务中断 → P0
性能降级 / 趋势异常 → P1
容量预警 / 潜在风险 → P2
```

---

## 告警收敛与降噪策略

### 问题：告警风暴

在机房温度异常或网络抖动时，可能同时触发数十甚至上百条告警，导致告警疲劳。

### 策略一：分组（Grouping）

```yaml
route:
  # 按 告警名 + 级别 + 节点 分组
  group_by: ['alertname', 'severity', 'hostname']
  group_wait: 10s        # 同组告警合并等待 10s
  group_interval: 5m     # 同组后续告警每 5 分钟发一次
```

### 策略二：抑制（Inhibition）

```yaml
inhibit_rules:
  # P0 告警抑制同设备 P1/P2 告警
  - source_matchers:
      - severity = "P0"
    target_matchers:
      - severity =~ "P1|P2"
    equal: ['hostname', 'npu_id']

  # 掉卡告警抑制该设备所有其他告警
  - source_matchers:
      - alertname = "NPULost"
    target_matchers:
      - severity =~ "P1|P2"
    equal: ['hostname']

  # 严重温度告警抑制普通温度告警
  - source_matchers:
      - alertname = "NPUTemperatureCritical"
    target_matchers:
      - alertname = "NPUTemperatureHigh"
    equal: ['hostname', 'npu_id']
```

### 策略三：持续时间（For）

所有告警都设置 `for` 持续时间，避免瞬时抖动误报：

```yaml
# 瞬时值异常，至少持续 2 分钟才告警
- alert: NPUTemperatureHigh
  expr: ascend_npu_temperature_celsius > 85
  for: 2m

# 严重故障，30 秒即告警
- alert: NPUCriticalFault
  expr: ascend_npu_health >= 2
  for: 30s

# 趋势类告警，持续更长时间
- alert: NPUMemoryFull
  expr: (mem_used / mem_total * 100) >= 100
  for: 5m
```

### 策略四：重复间隔（Repeat Interval）

```yaml
route:
  repeat_interval: 4h    # 默认 4 小时重复一次
  routes:
    - matchers: ['severity = "P0"']
      repeat_interval: 30m   # P0 告警 30 分钟重复一次
    - matchers: ['severity = "P1"']
      repeat_interval: 1h    # P1 告警 1 小时重复一次
```

### 策略五：静默（Silence）

计划维护期间临时静默告警：

```bash
# 创建 2 小时静默规则（所有告警）
/opt/alertmanager/amtool silence add \
  --comment="计划维护：驱动升级" \
  --duration=2h \
  --alertmanager.url=http://localhost:9093

# 创建针对特定节点的静默
/opt/alertmanager/amtool silence add \
  hostname="compute-03" \
  --comment="compute-03 维护" \
  --duration=1h \
  --alertmanager.url=http://localhost:9093

# 查看活跃的静默规则
/opt/alertmanager/amtool silence query \
  --alertmanager.url=http://localhost:9093

# 取消静默
/opt/alertmanager/amtool silence expire <silence-id> \
  --alertmanager.url=http://localhost:9093
```

也可以通过 AlertManager Web UI 创建静默：`http://<alertmanager-ip>:9093/#/silences`

---

## 告警自愈（可选）

对于部分可自动恢复的告警，可以通过 AlertManager Webhook 触发自动修复脚本：

```yaml
# AlertManager 配置
receivers:
  - name: 'auto-remediation'
    webhook_configs:
      - url: 'http://localhost:5000/remediate'
        send_resolved: false
```

**自动修复 API 示例（Python Flask）：**

```python
#!/usr/bin/env python3
# /opt/ascend-monitor/remediation_api.py
# 告警自愈 API

from flask import Flask, request, jsonify
import subprocess
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)

@app.route('/remediate', methods=['POST'])
def remediate():
    alert = request.json
    for item in alert.get('alerts', []):
        alertname = item['labels'].get('alertname', '')
        hostname = item['labels'].get('hostname', '')
        severity = item['labels'].get('severity', '')

        # 仅处理 P1 及以下级别的自动修复
        if severity == 'P0':
            logging.warning(f"P0 告警不自动修复: {alertname} on {hostname}")
            continue

        if alertname == 'NPUTemperatureHigh':
            # 温度过高：尝试降低功耗限制
            npu_id = item['labels'].get('npu_id', '0')
            logging.info(f"自动降频: {hostname} NPU-{npu_id}")
            # subprocess.run(['ssh', hostname, f'npu-smi set -i {npu_id} -c 0 -t power -d 280'])

        elif alertname == 'NPUExporterDown':
            # Exporter 挂了：尝试重启
            logging.info(f"重启 Exporter: {hostname}")
            # subprocess.run(['ssh', hostname, 'systemctl restart ascend-exporter'])

        elif alertname == 'NPUIdleButAllocated':
            # 任务卡死：发送通知而非自动清理
            logging.info(f"检测到卡死任务: {hostname}")

    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

---

## 常见问题

**Q: 告警规则已配置但不触发？**

A: 排查步骤：
1. 访问 `http://<prometheus-ip>:9090/rules` 确认规则已加载
2. 访问 `http://<prometheus-ip>:9090/alerts` 查看告警状态（`pending` / `firing`）
3. 在 Prometheus 查询页面手动执行告警表达式，确认有数据
4. 检查 `for` 持续时间是否还没到

**Q: AlertManager 收到告警但不发通知？**

A:
1. 访问 `http://<alertmanager-ip>:9093` 查看告警是否到达
2. 检查 receiver 配置中的 URL / 邮箱地址是否正确
3. 检查是否被 inhibit 规则抑制
4. 检查是否被 silence 规则静默
5. 查看 AlertManager 日志：`journalctl -u alertmanager -f`

**Q: 企业微信/飞书收不到告警？**

A: 确认 Webhook URL 有效、网络可达、消息格式正确。可以手动测试：
```bash
curl -X POST 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=YOUR_KEY' \
  -H 'Content-Type: application/json' \
  -d '{"msgtype":"text","text":{"content":"测试告警消息"}}'
```

---

::: tip 下一步
告警体系搭建完成后，请建立日常 [巡检与应急 SOP](./inspection) 流程，让运维工作规范化、流程化。
:::
