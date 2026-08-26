# A2 系列服务器

> **什么时候读**：使用 **Atlas 800T A2 / 800I A2** 等 A2 代际服务器做训练或推理。

## 一、A2 两款服务器

| 产品 | 定位 | 官方文档 |
| --- | --- | --- |
| **Atlas 800T A2 训练服务器** | 面向大模型训练的 A2 服务器 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800t-a2-pid-254184887) |
| **Atlas 800I A2 推理服务器** | 面向推理的 A2 服务器 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800i-a2-pid-261457531) |

## 二、用 A2 服务器能做什么

- **800T A2**：适合大模型**训练 / 微调**。配合 MindSpeed、LLaMA-Factory 使用。
- **800I A2**：适合**推理服务化**。配合 MindIE、vLLM-Ascend、SGLang 使用。

## 三、从交付到使用链路

1. 环境搭建：走 [从零到上手：7 步走](https://revolutionla.github.io/AscendMate/guide/seven-steps)。
2. 验证设备：`npu-smi info` 应识别所有 NPU。
3. 跑业务：训练见 [训练全景](https://revolutionla.github.io/AscendMate/training/)，推理见 [推理全景](https://revolutionla.github.io/AscendMate/inference/)。

## 四、常见问题入口

- 装系统/驱动/CANN 卡住 → [环境搭建类问题](https://revolutionla.github.io/AscendMate/faq/setup-issues)
- 推理显存/性能 → [性能与精度问题](https://revolutionla.github.io/AscendMate/faq/perf-precision-issues)

> [!NOTE]
> 具体硬件规格（NPU 数量、HBM、接口、功耗）以官方用户指南为准。
