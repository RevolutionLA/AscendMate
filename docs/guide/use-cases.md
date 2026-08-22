# 典型部署场景

> **什么时候读**：你想确认昇腾能做哪些事、对应用什么技术栈，据此判断当前的部署目标该走哪条实施路径。

昇腾覆盖 AI 的**训练、推理、边缘、算子开发**四类场景。本节按**部署目标**列出对应的技术选型与实施入口，帮助你直接对照自己的需求定位。

## 一、场景与技术选型总览

| 部署目标 | 关键技术栈 | 对应板块 |
| --- | --- | --- |
| 大模型微调 / 预训练 | LLaMA-Factory、MindSpeed | [训练](/training/) |
| LLM 推理服务（服务化） | MindIE、vLLM-Ascend、SGLang | [推理](/inference/) |
| LLM 应用平台（RAG / 工作流 / Agent） | Dify + 昇腾推理后端 | [Dify 部署](/inference/dify) |
| 存量服务器推理加速 | Atlas 300I 推理卡 + 推理引擎 | [推理卡](/hardware/inference-card) |
| GPU 模型/算子迁移 | torch_npu、Triton-Ascend、Ascend C | [迁移](/training/pytorch-migration) · [算子](/ops/) |
| 边缘计算 / 算法验证 | Atlas 200I DK A2 开发套件 | [开发套件](/hardware/devkit-module) |

## 二、场景明细与实施入口

### 场景 A：在昇腾上微调 / 预训练大模型

- 适用：需要私有化 / 行业大模型，数据不出域。
- 技术栈：[LLaMA-Factory](/training/llama-factory)（微调）、[MindSpeed](/training/mindspeed)（大规模预训练）。
- 实施路径：环境搭建 → 微调/训练 → 权重导出 → 部署推理。
- 前置条件：[环境搭建](/setup/) 全链路跑通。

### 场景 B：部署 LLM 推理服务

- 适用：把已训练/微调模型做成可线上调用的推理服务。
- 技术栈三选一：
  - [MindIE](/inference/mindie)：华为自研，生产级高性能。
  - [vLLM-Ascend](/inference/vllm-ascend)：vLLM 官方插件，生态开放、上手快。
  - [SGLang-Kernel-NPU](/inference/sglang)：MoE / 专家并行大模型。
- 出口统一为 **OpenAI 兼容 API**，可直接对接现有应用。

### 场景 C：搭建 LLM 应用平台（RAG / 工作流 / Agent）

- 适用：给业务方提供可视化、低代码的 LLM 应用底座。
- 技术栈：[Dify](/inference/dify)。
- 关键点：先跑通一个昇腾推理后端，再把其 OpenAI 兼容地址接入 Dify。

### 场景 D：存量服务器推理加速（插卡）

- 适用：复用现有服务器，通过插 **Atlas 300I 系列推理卡**提升推理能力。
- 技术栈：推理卡 + [MindIE](/inference/mindie) 或 vLLM-Ascend。
- 关键点：板卡的物理安装、PCIe 枚举、驱动/CANN 配套，见 [推理卡](/hardware/inference-card)。

### 场景 E：GPU 模型 / 算子迁移

- 适用：已有 CUDA 资产，需迁移到昇腾。
- 模型层：[PyTorch 模型迁移](/training/pytorch-migration)（cuda→npu，改动小）。
- 算子层：[Triton-Ascend](/ops/triton-ascend)、[Ascend C](/ops/ascend-c)。

### 场景 F：边缘计算 / 算法验证

- 适用：边缘推理、算法原型验证。
- 技术栈：[Atlas 200I DK A2](/hardware/devkit-module) 开发套件。

## 三、回到主线

无论走哪个场景，环境搭建都是统一前置。若你刚开始，先按 [从零到上手：7 步走](/guide/seven-steps) 打完环境，再进入具体场景。

## 相关

- [昇腾软硬件全景](/guide/ascend-landscape)
- [如何选择使用路径](/guide/choose-your-path)
