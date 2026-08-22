# 硬件产品全景

> **什么时候读**：需要了解昇腾硬件有哪些形态、如何选型，或查找某型号的官方文档。

## 一、昇腾硬件金字塔

```text
                      ┌─────────────────────────┐
   超节点/集群         │ Atlas 900 A3 SuperPoD    │  超大规模训练/推理
                      │ Atlas 900 A2 PoD         │
                      ├─────────────────────────┤
   服务器             │ Atlas 800T A2 (训练)      │
                      │ Atlas 800I A2/A3 (推理)   │  整机交付主体
                      ├─────────────────────────┤
   板卡/推理卡        │ Atlas 300I Pro / V Pro    │
                      │ Atlas 300I A2 / Duo       │  板卡形态加速
                      ├─────────────────────────┤
   开发套件/模组       │ Atlas 200I DK A2          │  学习 / 边缘
                      └─────────────────────────┘
```

## 二、按形态选型速查

| 形态 | 典型配置 | 适用场景 | 文档 |
| --- | --- | --- | --- |
| **超节点 / 集群** | 900 A3 SuperPoD、900 A2 PoD | 大模型预训练、多卡并行 | [集群形态](/hardware/cluster) |
| **A2 训练服务器** | 800T A2 | 中大型训练 | [A2 服务器](/hardware/a2-server) |
| **A2 推理服务器** | 800I A2 | 推理部署 | [A2 服务器](/hardware/a2-server) |
| **A3 服务器** | 800I/800T A3 | 新一代训练/推理 | [A3 服务器](/hardware/a3-server) |
| **AI 推理卡** | 300I Pro / V Pro / 300I A2 / Duo | 板卡级加速 | [AI 推理卡](/hardware/inference-card) |
| **开发套件 / 模组** | 200I DK A2 | 学习、边缘、原型 | [开发套件与模组](/hardware/devkit-module) |

## 三、怎么选（选型考虑）

1. **要跑多大模型、训练还是推理？** 训练看算力和 HBM（HBM 容量决定能装多大模型+并行策略），推理看吞吐与延迟。
2. **单机还是集群？** 模型超过单机能力时上超节点/集群（并配套 HCCS/RDMA 网络）。
3. **交付形态？** 整机交付 vs 板卡集成到自有服务器。
4. **算力与配套？** 与算力规模、存储、网络整体规划。

> [!NOTE]
> 硬件参数、功耗、接口等**以官方用户指南为准**。本仓库给出导航与关系梳理，不替代官方规格书。

## 四、所有型号官方文档入口（链接表）

| 产品 | 官方文档链接 |
| --- | --- |
| Atlas 900 A3 SuperPoD | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-900-a3-superpod-pid-261207247) |
| Atlas 900 A2 PoD | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-900-a2-pod-pid-254184911) |
| Atlas 800T A2 训练服务器 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800t-a2-pid-254184887) |
| Atlas 800I A2 推理服务器 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800i-a2-pid-261457531) |
| Atlas 800I A3 推理服务器 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800i-a3-pid-264117745) |
| Atlas 300I Pro | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300i-pro-pid-251052354) |
| Atlas 300V Pro | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300v-pro-pid-253542321) |
| Atlas 300I Duo | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300i-duo-pid-252823107) |
| Atlas 300I A2 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/a300i-a2-pid-260323393) |
| Atlas 200I DK A2 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-200i-dk-a2-pid-254412173) |

> 完整链接也收录在 [资源导航总表](/resources/links)。

## 下一步

按你的硬件形态进入对应子页，或直接到 [训练](/training/) / [推理](/inference/) 把硬件用起来。
