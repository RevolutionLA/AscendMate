---
layout: doc
title: 运维监控 · 让昇腾集群7×24稳定运行
description: 昇腾智算服务器运维监控体系总览，涵盖NPU健康状态采集、Prometheus存储、Grafana可视化展示与AlertManager告警通知全链路。
---

# 运维监控 · 让昇腾集群 7×24 稳定运行

> 运维监控是昇腾集群稳定运行的生命线。本章将带您从零搭建一套覆盖 **采集 → 存储 → 展示 → 告警** 的完整监控体系，让每一块 NPU 的心跳都在掌控之中。

---

## 为什么需要运维监控

昇腾智算服务器承载着大规模 AI 训练与推理任务，单台服务器通常配备 4~8 张昇腾 NPU（如 Ascend 910B/310P）。在 7×24 小时高负载运行环境下，硬件故障、温度异常、链路降级等问题随时可能发生。如果没有完善的监控体系：

- **故障发现滞后**：训练任务跑了几小时才发现 NPU 掉卡，浪费大量算力与时间
- **问题定位困难**：HCCS 链路降速、ECC 错误累积等隐性问题难以肉眼发现
- **缺乏历史数据**：出事后无法回溯，难以做根因分析和趋势预测
- **人工巡检成本高**：几十台甚至上百台服务器，逐台 `npu-smi info` 不现实

一套成熟的运维监控体系，能让你：

| 能力 | 说明 |
|------|------|
| **实时感知** | 秒级掌握所有 NPU 的健康状态、温度、功耗、利用率 |
| **提前预警** | 在故障真正发生前，通过温度趋势、ECC 错误增长等信号提前告警 |
| **快速定位** | 告警直接指向具体设备、具体指标，减少排查时间 |
| **历史回溯** | 存储长期指标数据，支持容量规划与趋势分析 |
| **自动巡检** | 定时自动采集与检查，降低人工成本 |

---

## 监控体系架构

昇腾 NPU 运维监控采用业界成熟的 **Prometheus + Grafana + AlertManager** 技术栈，数据采集层使用 `npu-smi` 和 `prometheus-ascend-exporter`。

```
┌─────────────────────────────────────────────────────────────────┐
│                        昇腾智算服务器集群                          │
│                                                                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │ Server 1  │  │ Server 2  │  │ Server 3  │  │ Server N  │        │
│  │ NPU 0~7   │  │ NPU 0~7   │  │ NPU 0~7   │  │ NPU 0~7   │        │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘         │
│        │             │             │             │               │
│   ┌────┴─────────────┴─────────────┴─────────────┴────┐         │
│   │           npu-smi / prometheus-ascend-exporter      │         │
│   │              (指标采集层 - 每台服务器部署)            │         │
│   └───────────────────────┬───────────────────────────┘         │
└───────────────────────────┼─────────────────────────────────────┘
                             │ HTTP /metrics (pull 模式)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Prometheus Server                           │
│                                                                   │
│   • 按 scrape_interval (15s) 拉取各节点指标                       │
│   • 时序数据存储 (TSDB)                                           │
│   • 告警规则评估 (recording & alerting rules)                     │
│   • 数据保留策略 (retention: 30d)                                 │
└──────────┬──────────────────────────┬───────────────────────────┘
           │                          │
           ▼                          ▼
┌─────────────────────┐    ┌──────────────────────────┐
│      Grafana        │    │     AlertManager          │
│                     │    │                           │
│  • NPU 监控仪表盘    │    │  • 告警路由与分组          │
│  • 实时数据可视化    │    │  • 告警抑制 (inhibit)     │
│  • 历史趋势分析      │    │  • 多渠道通知推送          │
│  • 告警面板         │    │                           │
└─────────────────────┘    └─────────────┬────────────┘
                                         │
                    ┌────────────────────┼────────────────────┐
                    │                    │                    │
                    ▼                    ▼                    ▼
              ┌──────────┐        ┌──────────┐        ┌──────────┐
              │   邮件    │        │ 企业微信  │        │   飞书    │
              │  Email   │        │  WeCom   │        │  Feishu  │
              └──────────┘        └──────────┘        └──────────┘
```

### 数据流向说明

| 阶段 | 组件 | 说明 |
|------|------|------|
| **采集** | `npu-smi` + `ascend-exporter` | 部署在每台服务器上，采集 NPU 温度、功耗、显存、算力利用率、HCCS 链路、ECC 错误等指标，以 Prometheus 格式暴露 `/metrics` 端点 |
| **存储** | Prometheus | 按 15s 间隔主动拉取（pull）各节点 `/metrics`，存入 TSDB 时序数据库，默认保留 30 天 |
| **展示** | Grafana | 以 Prometheus 为数据源，构建多维度监控仪表盘，支持实时刷新与历史查询 |
| **告警** | AlertManager | Prometheus 评估告警规则，命中后推送到 AlertManager，由其负责路由分组与多渠道通知 |

---

## 监控指标全景

以下指标覆盖昇腾 NPU 运维的核心维度，每个指标在后续章节中均有详细说明。

### 1. 设备健康状态

| 指标 | 来源 | 说明 |
|------|------|------|
| NPU 在线数量 | `npu-smi info` | 集群中实际在线的 NPU 数量，用于检测掉卡 |
| 设备健康状态 | `npu-smi info -t health` | `OK` / `Warning` / `Critical` / `Fault` |
| 驱动服务状态 | systemd | `npu-driver` / `ascend-dmi` 服务运行状态 |
| 固件版本 | `npu-smi info -t board` | 检查固件版本一致性 |

### 2. 温度与功耗

| 指标 | 来源 | 说明 |
|------|------|------|
| NPU 温度 (°C) | `npu-smi info` | 芯片结温，正常 < 80°C，告警阈值 85°C |
| NPU 功耗 (W) | `npu-smi info` | 实时功耗，910B TDP 约 350W |
| 风扇转速 | BMC / IPMI | 服务器风扇转速，间接反映散热状况 |
| 进出风口温度 | BMC / IPMI | 机房环境温度监控 |

### 3. 显存利用率

| 指标 | 来源 | 说明 |
|------|------|------|
| 显存已用 | `npu-smi info` | 已分配显存大小 |
| 显存总量 | `npu-smi info` | 910B: 64GB HBM，310P: 24GB |
| 显存利用率 (%) | 计算 | 已用 / 总量 × 100%，持续 100% 需告警 |

### 4. 算力利用率

| 指标 | 来源 | 说明 |
|------|------|------|
| AI Core 利用率 (%) | `npu-smi info` | 昇腾 AI Core 计算单元利用率 |
| AI CPU 利用率 (%) | `npu-smi info` | AI CPU 使用率 |
| 控制芯片利用率 | `npu-smi info` | 系统控制芯片负载 |

### 5. HCCS 链路状态

| 指标 | 来源 | 说明 |
|------|------|------|
| HCCS 链路速率 | `npu-smi info -t topo` | 预期 100GB/s，降速需告警 |
| HCCS 链路状态 | `npu-smi info -t hccs` | `UP` / `DOWN` / `DEGRADED` |
| 链路误码率 | `npu-smi info -t port` | HCCS 端口误码统计 |

### 6. ECC 错误

| 指标 | 来源 | 说明 |
|------|------|------|
| 可纠正 ECC 错误数 | `npu-smi info -t ecc` | 单比特错误，可纠正但需监控增长趋势 |
| 不可纠正 ECC 错误数 | `npu-smi info -t ecc` | 多比特错误，通常需更换硬件 |
| ECC 错误增长率 | 计算 | 单位时间新增错误数，突增需告警 |

---

## 快速导航

| 文档 | 内容 | 适用场景 |
|------|------|----------|
| [NPU 指标采集](./npu-exporter) | `npu-smi` 命令详解、定时采集、Exporter 部署 | 搭建采集层 |
| [Prometheus + Grafana](./prometheus-grafana) | 存储与可视化搭建、仪表盘配置 | 搭建展示层 |
| [告警规则与通知](./alerting) | AlertManager 配置、告警规则、通知渠道 | 搭建告警层 |
| [巡检与应急 SOP](./inspection) | 日常巡检清单、自动化巡检脚本、故障处理流程 | 日常运维 |
| [日志管理](./log-management) | 日志目录、收集脚本、分析技巧、ELK 对接 | 日志分析 |

---

## 前置条件

在开始搭建监控体系前，请确保：

1. **环境搭建**：昇腾驱动、固件、CANN 工具包已正确安装，参见 [环境搭建](https://revolutionla.github.io/AscendMate/setup/)
2. **`npu-smi` 可用**：在服务器上执行 `npu-smi info` 能正常输出 NPU 信息
3. **网络互通**：Prometheus Server 能访问各计算节点的 9100 端口（Exporter 默认端口）
4. **权限准备**：具备 root 或 sudo 权限，用于安装软件包和配置 systemd 服务

---

## 最佳实践

### 分层部署

```
计算节点 (每台服务器)
  └── ascend-exporter (9100端口)
  └── node-exporter (9101端口)  ← 可选，监控CPU/内存/磁盘

监控节点 (1~2台管理服务器)
  └── prometheus (9090端口)
  └── grafana (3000端口)
  └── alertmanager (9093端口)
```

### 监控覆盖建议

| 集群规模 | 建议架构 | Prometheus 实例 |
|----------|----------|-----------------|
| < 20 台 | 单 Prometheus | 1 实例 + 本地存储 |
| 20~100 台 | Prometheus + 远程存储 | 1~2 实例 + Thanos/VictoriaMetrics |
| > 100 台 | 联邦集群 | 多 Prometheus + 联邦查询 |

### 数据保留策略

```yaml
# 小集群：本地存储 30 天
retention: 30d
storage.tsdb.path: /data/prometheus

# 大集群：本地 7 天 + 远程长期存储
retention: 7d
remote_write:
  - url: http://thanos-receive:19291/api/v1/receive
```

---

## 常见问题

**Q: Prometheus 拉不到 NPU 指标怎么办？**

A: 按以下顺序排查：
1. 在计算节点上执行 `curl http://localhost:9100/metrics` 确认 Exporter 正常工作
2. 检查 `npu-smi info` 是否正常输出（驱动是否正常加载）
3. 检查防火墙规则：`sudo iptables -L -n | grep 9100`
4. 检查 Prometheus 的 `targets` 页面：`http://<prometheus-ip>:9090/targets`

**Q: Grafana 仪表盘空白怎么办？**

A: 确认数据源配置正确、Prometheus 有数据、时间范围选择正确。更多排查参见 [问题定位](https://revolutionla.github.io/AscendMate/faq/)。

**Q: 告警一直不触发怎么办？**

A: 检查 Prometheus Rules 页面（`http://<prometheus-ip>:9090/rules`）确认规则已加载，检查 AlertManager 状态页面（`http://<alertmanager-ip>:9093`）确认告警已到达。

**Q: 告警太多，如何降噪？**

A: 参见 [告警规则与通知](./alerting) 中的"告警收敛与降噪策略"章节，通过分组（grouping）、抑制（inhibition）、持续时间（for）和静默（silence）四重策略减少无效告警。

**Q: 集群规模扩大后 Prometheus 性能不够怎么办？**

A: 考虑以下方案：
1. 使用 Thanos 或 VictoriaMetrics 做远程长期存储，Prometheus 本地只保留短期数据
2. 使用 Prometheus 联邦（Federation）分片采集
3. 降低 `scrape_interval`（如 15s → 30s），并使用 Recording Rules 预计算

---

## 监控体系搭建路线图

按以下顺序逐步搭建，每一步验证通过后再进行下一步：

```
Phase 1: 单节点验证（1~2 天）
├── 在单台计算节点上安装 ascend-exporter
├── 验证 /metrics 端点能正常输出 NPU 指标
└── 确认 npu-smi info 命令正常工作

Phase 2: 监控基础设施（2~3 天）
├── 在管理节点上安装 Prometheus + Grafana + AlertManager
├── 配置 Prometheus 采集单节点 NPU 指标
├── 在 Grafana 中创建基础仪表盘
└── 验证数据采集与展示链路通畅

Phase 3: 全集群部署（3~5 天）
├── 在所有计算节点上部署 ascend-exporter
├── 更新 Prometheus 配置，纳入全部节点
├── 完善 Grafana 仪表盘（添加变量、多面板）
└── 配置告警规则与通知渠道

Phase 4: 持续优化（持续进行）
├── 根据实际运行情况调整告警阈值
├── 建立日常巡检流程与 SOP
├── 配置日志收集与分析体系
└── 定期审查监控覆盖率与告警有效性
```

---

## 关键术语速查

| 术语 | 全称 | 说明 |
|------|------|------|
| NPU | Neural Processing Unit | 神经网络处理器，昇腾系列 AI 芯片 |
| HCCS | Cache Coherent System | 高速缓存一致性互联架构，用于 NPU 间通信 |
| HBM | High Bandwidth Memory | 高带宽显存，NPU 的片上存储 |
| ECC | Error Correction Code | 错误纠正码，用于检测和纠正显存错误 |
| CE | Correctable Error | 可纠正错误（单比特），硬件可自动修复 |
| UE | Uncorrectable Error | 不可纠正错误（多比特），通常需要更换硬件 |
| AI Core | - | 昇腾 NPU 的核心计算单元（Da Vinci 架构） |
| CANN | Compute Architecture for Neural Networks | 昇腾计算架构，包含驱动、运行时和算子库 |
| TSDB | Time Series Database | 时序数据库，Prometheus 的底层存储引擎 |
| BMC | Baseboard Management Controller | 基板管理控制器，用于服务器硬件级监控 |

---

::: tip 下一步
建议从 [NPU 指标采集](./npu-exporter) 开始，先在单台服务器上跑通采集，再逐步扩展到全集群。
:::
