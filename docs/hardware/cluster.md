# 集群形态

> **什么时候读**：要交付/使用昇腾**超节点或集群**（多机共享算力的大规模场景）。

## 一、代表产品

| 产品 | 定位 | 官方文档 |
| --- | --- | --- |
| **Atlas 900 A3 SuperPoD 超节点** | 面向超大模型训练/推理的整柜超节点，A3 代际 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-900-a3-superpod-pid-261207247) |
| **Atlas 900 A2 PoD 集群基础单元** | A2 代际的集群基础单元，规模化训练 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-900-a2-pod-pid-254184911) |

## 二、何时需要集群

- 单个模型**显存需求超出单机**（如超大参数模型、长序列、MoE 大模型）。
- 需要**大规模并行训练 / 推理**，单机吞吐不够。
- 组网（HCCS 片内 / 机间 RDMA 等）为高带宽低延迟设计。

## 三、软件协同

集群形态通常配合：

- **MindSpeed**：并行策略（张量/流水/数据并行等）训练。见 [MindSpeed 预训练](/training/mindspeed)。
- **vLLM-Ascend / MindIE**：专家并行（EP）、多卡推理。见 [推理全景](/inference/)。
- **HCCL**：昇腾集合通信库。

## 四、部署要点

- 集群的**组网规划**（管理网 + 业务网 + 高性能网/存储网）很关键，参考文献与售前方案。
- 版本配套在集群规模下更要一致，无法逐机试错。
- 使用前建议先确认 **supernode 识别、NPU 拓扑、HCCL 测试**通过。

> [!NOTE]
> 超节点的完整安装、配置与调优请以官方用户指南为准，此处仅作导航。

## 相关内容

- [MindSpeed 预训练](/training/mindspeed)
- [性能与精度问题](/faq/perf-precision-issues)
