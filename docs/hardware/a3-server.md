# A3 系列服务器

> **什么时候读**：使用 **Atlas 800I A3** 等 A3 代际服务器做推理或训练。

## 一、A3 服务器

| 产品 | 定位 | 官方文档 |
| --- | --- | --- |
| **Atlas 800I A3 推理服务器** | 面向推理的 A3 服务器（新一代） | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800i-a3-pid-264117745) |
| **Atlas 800T A3 训练服务器** | 面向训练的 A3 服务器（若有） | 见昇腾官方产品页 |

## 二、A3 相比 A2 的关注点

- **代际新**，算力/能效或有提升，软件适配也在推进中。
- 安装 **torch_npu / CANN / 推理引擎**时，务必选择**支持 A3 的版本**。
- Triton-Ascend 等组件会明确列出对 A3 的自持（见 [Triton-Ascend](https://revolutionla.github.io/AscendMate/ops/triton-ascend)）。

## 三、用 A3 服务器做什么

- 推理：MindIE、vLLM-Ascend、SGLang-Kernel-NPU（注意配合支持 A3 的版本）。
- 训练：MindSpeed、LLaMA-Factory。

## 四、链路

1. [从零到上手：7 步走](https://revolutionla.github.io/AscendMate/guide/seven-steps)
2. `npu-smi info` 验证设备
3. 进入 [训练全景](https://revolutionla.github.io/AscendMate/training/) / [推理全景](https://revolutionla.github.io/AscendMate/inference/)
