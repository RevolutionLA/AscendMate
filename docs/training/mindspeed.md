# MindSpeed 预训练

> **什么时候读**：你需要进行**大规模大模型预训练 / 训练加速**，尤其是超过单机能力、需要并行策略（张量/流水/数据并行、长序列、MoE）的场景。

[MindSpeed](https://gitcode.com/Ascend/MindSpeed) 是华为面向昇腾的大模型**训练加速库**，对标 Megatron/DeepSpeed 生态，让 Megatron-LM 能在昇腾上开箱运行，并补上昇腾亲和的高性能特性。

## 一、关键价值

- **一行接入**：在 Megatron-LM 脚本里加一行 `import mindspeed.megatron_adaptor` 即可在昇腾上训练。
- **覆盖主流模型**：大语言模型（MindSpeed LLM）、多模态（MindSpeed MM）、强化学习（MindSpeed RL）。
- **进阶特性**：长序列（Ulysses/Ring Attention）、MoE、重计算、优化器状态切分、HCCL 通信优化等。

## 二、组件构成

| 组件 | 用途 |
| --- | --- |
| **MindSpeed Core** | 核心加速库（本页重点） |
| MindSpeed LLM | 大语言模型套件 |
| MindSpeed MM | 多模态模型库 |
| MindSpeed RL | 强化学习加速库 |

## 三、版本配套（重要）

以 MindSpeed 2.x Core 为例，配套要求较严格：

| 软件 | 示例版本 |
| --- | --- |
| CANN | 8.3.RC1 等（与你的发布配套） |
| PyTorch | 2.1.0 / 2.6.0 / 2.7.1 |
| torch_npu | 7.3.RC1（对应版本） |
| Python | 3.10.x |
| Megatron-LM | 指定 core 版本（如 core_v0.12.1） |

> 请务必查看你使用版本的**官方配套表**，见离线文档 / 仓库 `docs/user-guide/installation.md`。

## 四、安装 MindSpeed（源码）

```bash
# clone 源码
git clone https://gitcode.com/Ascend/MindSpeed.git
cd MindSpeed

# pip 安装
pip install -e .

# 准备 Megatron-LM（切到配套 core 版本）
git clone https://github.com/NVIDIA/Megatron-LM.git
cd Megatron-LM
git checkout core_v0.12.1
```

## 五、快速上手（一行接入训练）

以 GPT 模型为例，修改 Megatron-LM 下的 `pretrain_gpt.py`，在 `import torch` 后加一行：

```python
import torch
import mindspeed.megatron_adaptor   # 新增这一行
from functools import partial
...
```

然后用 Megatron 的方式启动训练即可。

## 六、加速层级说明

通过 `--optimization-level {0|1|2}` 控制优化层级：

| 层级 | 说明 |
| --- | --- |
| 0 | 基础功能兼容（Megatron 框架在 NPU 跑通） |
| 1 | 亲和性增强（融合算子 + 昇腾亲和改写） |
| 2 | 加速特性使能（默认值，更丰富加速） |

## 七、常见加速特性

- **长序列并行**：Ulysses、Ring Attention、混合长序列并行。
- **MoE 加速**：GMM、Alltoall/Allgather Dispatcher 优化、EP 拓展。
- **内存优化**：激活重计算、优化器状态切分、BF16 参数复用、Swap 机制。

在启动脚本中按需加特性参数即可，详见仓库 `docs/features/`。

## 八、快速参考：基于 MindSpeed 预训练 Qwen2.5

仓库/社区提供**基于 MindSpeed 预训练 Qwen2.5 的快速开始脚本**，可参考并按其指引运行（涉及数据准备、并行策略配置、启动命令）。

> 详细步骤以官方 quick start 为准，见离线文档「基于MindSpeed预训练Qwen2.5_quick_start」。

## 九、常见问题

- 数据预处理出错 / Torch extensions 编译卡住 → 查仓库 `docs/faq/`。
- `Gloo 建链失败` → 配置 HCCL 替代，见仓库 `hccl-replace-gloo` 特性。
- 训练遇精度/性能问题 → [性能与精度问题](/faq/perf-precision-issues)

## 相关

- 微调不走大规模预训练？→ [LLaMA-Factory 微调实操](/training/llama-factory)
- [训练全景](/training/)

> [!NOTE]
> MindSpeed 与 Megatron-LM 等第三方开源软件相互依存，第三方问题修复依赖上游社区；详见仓库安全声明。
