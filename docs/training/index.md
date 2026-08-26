# 大模型训练全景

> **什么时候读**：你需要在昇腾上**训练 / 微调大模型**，或把现有模型迁移到昇腾训练。

## 一、训练三条路径

根据你的需求，选一条路：

| 目标 | 推荐方案 | 入口 |
| --- | --- | --- |
| **快速微调大模型**（SFT/LoRA/QLoRA 等） | **LLaMA-Factory** | [LLaMA-Factory 微调实操](https://revolutionla.github.io/AscendMate/training/llama-factory) |
| **大规模预训练 / 大模型加速** | **MindSpeed** | [MindSpeed 预训练](https://revolutionla.github.io/AscendMate/training/mindspeed) |
| **把 GPU 模型/脚本迁到昇腾** | torch_npu + 迁移指南 | [PyTorch 模型迁移](https://revolutionla.github.io/AscendMate/training/pytorch-migration) |
| **在 MindSpore 上训练** | MindSpore | [MindSpore 模型迁移](https://revolutionla.github.io/AscendMate/training/mindspore-migration) |

## 二、训练前必备环境

- [ ] [环境搭建](https://revolutionla.github.io/AscendMate/setup/) 全链路打通过（驱动 → CANN → 框架）。
- [ ] `npu-smi info` 正常，版本配套确认（见 [环境自检清单](https://revolutionla.github.io/AscendMate/setup/checklist)）。
- [ ] 模型权重 / 数据集准备（魔乐社区、魔搭等，见 [资源导航](https://revolutionla.github.io/AscendMate/resources/)）。

## 三、微调方案速览

- **LLaMA-Factory**：上千 Star 的微调框架，**命令行 + WebUI 零代码**，支持 LoRA / QLoRA / 全参微调，天然支持昇腾 NPU。➡ 新人首选。
- **MindSpeed**：对标 Megatron/DeepSpeed 的训练加速库，支持张量/流水/数据并行、长序列、MoE 等高级特性，适合**大模型规模化训练**。➡ 大模型进阶。

## 四、训练常用的调参关注点

- **精度**：大模型训练主用 bf16；混合精度设置影响显存与精度。
- **显存/内存**：超单机时用并行策略（张量/流水/数据并行），超大模型用 MindSpeed（重计算、优化器状态切分等）。
- **性能**：用 Profiling 找瓶颈，见 [性能调优](https://revolutionla.github.io/AscendMate/tools/profiling)。

## 五、训练到推理的衔接

模型训练/微调完成后，通常要**导出**并部署为推理服务：

1. 用 LLaMA-Factory `export` 合并 LoRA 权重。
2. 用 MindIE / vLLM-Ascend 拉起推理服务。

👉 [推理全景](https://revolutionla.github.io/AscendMate/inference/)

> [!TIP]
> 完全不想看复杂原理、只想快速微调？直接进入 [LLaMA-Factory 微调实操](https://revolutionla.github.io/AscendMate/training/llama-factory)，跟着命令做。
