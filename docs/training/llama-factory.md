# LLaMA-Factory 微调实操

> **什么时候读**：你想在昇腾 NPU 上**快速微调大模型**（SFT / LoRA / QLoRA / 全参），且希望有**开箱即用**的方案。

[LLaMA-Factory](https://github.com/hiyouga/LlamaFactory) 支持百余种大模型的微调，提供命令行与 WebUI 两种方式，**原生支持昇腾 NPU**，是昇腾上微调大模型最省事的选择。

## 一、方案概览

- 支持模型：Qwen、Llama、DeepSeek、GLM、Mistral、Gemma 等上百种。
- 支持方法：（增量）预训练、SFT、DPO、PPO、KTO 等。
- 支持精度/方式：全参数、LoRA、QLoRA（需 bitsandbytes-NPU）。
- 界面：`llamafactory-cli` 命令 **或** WebUI（Gradio）零代码。

## 二、硬性前提

- 昇腾环境就绪（见 [环境搭建](/setup/)）。
- Python **3.10+**。
- 已安装 **CANN Toolkit 与 Kernels**。

## 三、推荐：用官方 NPU 镜像（最快）

有 A2 的话：

```bash
docker pull hiyouga/llamafactory:latest-npu-a2
docker pull hiyouga/llamafactory:latest-npu-a3   # A3 系列
```

镜像内已装好 PyTorch + torch_npu + CANN 相关，拉起即可用（注意挂载 NPU 设备，见 [Docker 离线部署](/setup/docker-offline)）。

## 四、源码安装（可控）

```bash
git clone --depth 1 https://github.com/hiyouga/LlamaFactory.git
cd LlamaFactory

# 昇腾 NPU 需安装额外依赖
pip install -e .
pip install -r requirements/npu.txt
```

> 若要在 NPU 上跑 QLoRA（量化微调），需另编译 NPU 版 bitsandbytes，详见官方 NPU 安装文档。

## 五、启动 WebUI（零代码版）

```bash
llamafactory-cli webui
```

浏览器打开即可**图形化**选择模型、数据集、训练方式并一键训练。适合快速验证和不熟命令行的同学。

## 六、命令行快速微调示例

### 1. 准备数据

准备好指令数据集（JSON 格式），并注册到 `data/dataset_info.json`。

### 2. 训练（LoRA SFT）

参考官方示例 yaml（如 `examples/train_lora/qwen3_lora_sft.yaml`），执行：

```bash
llamafactory-cli train examples/train_lora/qwen3_lora_sft.yaml
```

### 3. 对话测试

```bash
llamafactory-cli chat examples/inference/qwen3_lora_sft.yaml
```

### 4. 合并 LoRA 权重（导出）

```bash
llamafactory-cli export examples/merge_lora/qwen3_lora_sft.yaml
```

合并后可交给推理引擎部署。

## 七、把微调模型部署为服务

用 LLaMA-Factory 内置 API 接口即可快速起 OpenAI 风格服务：

```bash
API_PORT=8000 llamafactory-cli api examples/inference/qwen3.yaml \
  infer_backend=vllm vllm_enforce_eager=true
```

> 云镜更常用的做法：导出权重后用 MindIE / vLLM-Ascend 部署，见 [推理全景](/inference/)。

## 八、模型与数据下载

- 模型：魔乐社区（昇腾适配权重）、魔搭、HuggingFace。
- 在 LLaMA-Factory 中设置 `export USE_MODELSCOPE_HUB=1` 可从魔搭下载；`export USE_OPENMIND_HUB=1` 从魔乐下载。

👉 更多见 [资源导航](/resources/)。

## 九、常用排错

- `torch_npu` 相关报错 → [训练类问题](/faq/training-issues)
- 显存不足 → 调并行/用 QLoRA/降序列长度，见 [性能与精度问题](/faq/perf-precision-issues)

> [!TIP]
> 完整示例与多 GPU 微调见 LLaMA-Factory 官方 `examples/README_zh.md`。这里是昇腾场景的实操浓缩。

## 相关

- [MindSpeed 预训练](/training/mindspeed)（大规模训练）
- [推理全景](/inference/)
