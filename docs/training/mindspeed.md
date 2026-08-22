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

## 九、Qwen2.5 预训练完整流程

> 来自官方《基于 MindSpeed 预训练 Qwen2.5 快速开始》。以 **Qwen2.5-7B + MindSpeed-LLM（PyTorch 后端）** 为例，走完「环境 → 权重 → 数据 → 启动」全流程。

### 9.1 基础要求

- 具备基础 PyTorch 使用经验，对 Megatron-LM 有概略了解。
- MindSpeed-LLM 环境已搭好（见仓库安装指导）。

### 9.2 开源权重获取（HF）

```shell
mkdir -p ./model_from_hf/qwen2.5-7b-hf
cd ./model_from_hf/qwen2.5-7b-hf
# HuggingFace 下载（ModelScope 同样可用）
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/config.json
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/model-00001-of-00004.safetensors
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/model-00002-of-00004.safetensors
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/model-00003-of-00004.safetensors
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/model-00004-of-00004.safetensors
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/model.safetensors.index.json
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/tokenizer.json
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/tokenizer_config.json
wget https://huggingface.co/Qwen/Qwen2.5-7B/resolve/main/vocab.json
# 用 sha256sum 校验权重完整性（与模型页面公布的 sha256 对比）
sha256sum model-00001-of-00004.safetensors
```

> 国内环境建议从 **ModelScope** 下载，URL 前缀替换为 `https://www.modelscope.cn/models/Qwen/Qwen2.5-7B/resolve/master/`。

### 9.3 hf → Megatron-Mcore 权重转换

MindSpeed-LLM 使用 **Megatron-Mcore** 格式权重，需把 HF 权重转换并切分：

```shell
cd MindSpeed-LLM
# 编辑脚本后执行（Qwen2.5 建议切分为 tp1pp4）
bash examples/mcore/qwen25/ckpt_convert_qwen25_hf2mcore.sh
```

核心转换命令（关键参数）：

```shell
source /usr/local/Ascend/cann/set_env.sh   # 换成实际 Toolkit 路径
python convert_ckpt.py \
  --use-mcore-models --model-type GPT \
  --load-model-type hf --save-model-type mg \
  --target-tensor-parallel-size 1 \
  --target-pipeline-parallel-size 4 \
  --add-qkv-bias \
  --load-dir ./model_from_hf/qwen2.5-7b-hf/ \
  --save-dir ./model_weights/qwen2.5_mcore/ \
  --tokenizer-model ./model_from_hf/qwen2.5-7b-hf/tokenizer.json \
  --model-type-hf llama2 --params-dtype bf16
```

### 9.4 预训练数据预处理

统一把数据预处理为 `.bin` `.idx` 文件，避免反复解析。以 alpaca 为例：

```shell
mkdir dataset && cd dataset/
wget https://huggingface.co/datasets/tatsu-lab/alpaca/resolve/main/data/train-00000-of-00001-a09b74b3ef9c3b56.parquet
cd ..
bash examples/mcore/qwen25/data_convert_qwen25_pretrain.sh
```

### 9.5 启动单机预训练

配置 `examples/mcore/qwen25/pretrain_qwen25_7b_32k_ptd.sh`：

```shell
NPUS_PER_NODE=8           # 单节点 8 卡
MASTER_ADDR=localhost
MASTER_PORT=6000
NNODES=1
NODE_RANK=0
WORLD_SIZE=$(($NPUS_PER_NODE * $NNODES))

CKPT_LOAD_DIR="./model_weights/qwen2.5_mcore/"
CKPT_SAVE_DIR="./ckpt/qwen25-7b"
DATA_PATH="./dataset/alpaca_text_document"
TOKENIZER_PATH="./model_from_hf/qwen2.5-7b-hf/"
TP=1
PP=4
SEQ_LEN=4096
MBS=1
GBS=64
```

启动：

```shell
source /usr/local/Ascend/cann/set_env.sh
source /usr/local/Ascend/nnal/atb/set_env.sh
bash examples/mcore/qwen25/pretrain_qwen25_7b_32k_ptd.sh
```

### 9.6 常见问题（预训练）

- **`Checkpoint path not found`** → 检查 `CKPT_LOAD_DIR` 是否正确指向权重转换产物目录。
- **数据加载 `out of range`** → 检查 `DATA_PATH` 是否符合规范（含 `.text_document` 后缀）。
- **脚本拉起失败** → 确认是否 source 了 CANN 环境变量、有无残留训练进程。
- **无运行日志** → 自行创建 `logs/` 目录。

## 十、常见问题

- 数据预处理出错 / Torch extensions 编译卡住 → 查仓库 `docs/faq/`。
- `Gloo 建链失败` → 配置 HCCL 替代，见仓库 `hccl-replace-gloo` 特性。
- 训练遇精度/性能问题 → [性能与精度问题](/faq/perf-precision-issues)

## 相关

- 微调不走大规模预训练？→ [LLaMA-Factory 微调实操](/training/llama-factory)
- [训练全景](/training/)

> [!NOTE]
> MindSpeed 与 Megatron-LM 等第三方开源软件相互依存，第三方问题修复依赖上游社区；详见仓库安全声明。
