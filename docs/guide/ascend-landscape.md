# 昇腾软硬件全景

> 快速了解昇腾的硬件形态、软件栈分层与生态组成，帮助你从全局理解后续部署内容的位置与选型关系。

## 昇腾整体定位

昇腾（Ascend）是面向 **AI 计算**打造的芯片与全栈计算产品。它覆盖从**芯片 → 计算产品 → 硬件 → C++/Python 生态 → 应用**的完整栈，对标的是面向 AI 场景的"CPU + GPU 专用计算"。

## 硬件形态速览

| 形态 | 典型产品 | 定位 |
| --- | --- | --- |
| 超节点 / 集群 | Atlas 900 A3 SuperPoD、A2 PoD | 大规模训练 / 推理集群 |
| 训练服务器 | Atlas 800T A2/A3 | 大模型训练 |
| 推理服务器 | Atlas 800I A2/A3 | 高性能推理 |
| AI 推理卡 | Atlas 300I A2/Duo/Pro/V Pro | 板卡形态推理加速 |
| 开发套件 / 模组 | Atlas 200I DK A2 | 边缘、学习、快速原型 |

👉 详细见 [硬件产品全景](https://revolutionla.github.io/AscendMate/hardware/)

## 软件栈分层

昇腾软件栈自底向上大致为：

```text
┌─────────────────────────────────────────────┐
│ 应用层：训练/推理业务、应用平台（Dify等）            │
├─────────────────────────────────────────────┤
│ 框架层：PyTorch+torch_npu / MindSpore         │
├─────────────────────────────────────────────┤
│ 加速层：MindSpeed、LLaMA-Factory、MindIE、    │
│         vLLM-Ascend、SGLang、DeepEP           │
├─────────────────────────────────────────────┤
│ 基础使能：CANN（AscendCL / AscendC / HCCL）     │
├─────────────────────────────────────────────┤
│ 系统层：操作系统 + 固件 + 驱动 + npu-smi         │
└─────────────────────────────────────────────┘
```

## 生态组成速览

用一张表把昇腾生态的关键组成部分和"在哪"说清楚：

| 生态块 | 关键内容 | 归属/入口 |
| --- | --- | --- |
| **AI 框架** | PyTorch + torch_npu、MindSpore | [setup](https://revolutionla.github.io/AscendMate/setup/) |
| **大模型微调** | LLaMA-Factory（支持 NPU） | [training](https://revolutionla.github.io/AscendMate/training/llama-factory) |
| **大模型训练加速库** | MindSpeed（对标 Megatron/DeepSpeed 生态） | [training](https://revolutionla.github.io/AscendMate/training/mindspeed) |
| **推理套件** | MindIE（自研）、vLLM-Ascend、SGLang-Kernel | [inference](https://revolutionla.github.io/AscendMate/inference/) |
| **算子开发** | Ascend C、Triton-Ascend、CATLASS | [ops](https://revolutionla.github.io/AscendMate/ops/) |
| **开发调试工具** | MindStudio、精度调试、Profiling | [tools](https://revolutionla.github.io/AscendMate/tools/) |
| **模型与样例** | ModelZoo、samples、魔乐社区 | [resources](https://revolutionla.github.io/AscendMate/resources/) |
| **软件下载** | CANN / 驱动 / 固件 / 镜像 | [resources/download](https://revolutionla.github.io/AscendMate/resources/download) |

## 昇腾 vs 通用生态对照（帮助理解定位）

| 概念 | GPU 生态（如 CUDA/torch） | 昇腾生态（对应） |
| --- | --- | --- |
| 硬件驱动层 | NVIDIA Driver + CUDA | 固件 + 驱动 + CANN |
| 框架接入 | torch.cuda | torch_npu / Ascend |
| 训练加速 | Megatron / DeepSpeed | MindSpeed |
| 推理引擎 | vLLM / TensorRT | MindIE / vLLM-Ascend / SGLang |
| 微调工具 | LLaMA-Factory | LLaMA-Factory（同样支持） |
| 算子开发 | CUDA kernel / Triton | Ascend C / Triton-Ascend |

> [!NOTE]
> 昇腾通过「对应生态组件」的方式，让原 CUDA 生态的开发者可以用**尽量低的学习成本**迁移过来。

## 选型时常见问题

- **生态是否成熟？** 主流大模型（Qwen、Llama、DeepSeek、GLM 等）与主流框架（LLaMA-Factory、vLLM 等）均已有昇腾适配，见 [资源导航总表](https://revolutionla.github.io/AscendMate/resources/links)。
- **能跑多大模型？** 与硬件规格、显存/内存、并行策略相关，见 [训练全景](https://revolutionla.github.io/AscendMate/training/) 与 [推理全景](https://revolutionla.github.io/AscendMate/inference/)。
- **怎么评估性能？** 可参考官方评测工具 AISBench 与 Profiling，见 [工具链](https://revolutionla.github.io/AscendMate/tools/)。

> [!TIP]
> 想直接看所有链接清单？去 [资源导航总表](https://revolutionla.github.io/AscendMate/resources/links)，一张表收录官方文档、代码仓与下载入口。
