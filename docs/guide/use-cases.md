# 昇腾还能怎么玩：应用玩法与场景

> **什么时候读**：你想了解昇腾**除了"跑大模型"之外还能做什么**，或在选型时想给客户讲清昇腾的价值点。

昇腾不只是"跑大模型"。它覆盖 AI 的**训、推、边、端**多个环节。这里整理了一些真实、可落地的"玩法"，帮你理解昇腾的能力边界，也方便你向客户讲解。

## 一、四大方向速览

| 方向 | 能做什么 | 典型玩法 | 对应板块 |
| --- | --- | --- | --- |
| **大模型训推** | 微调、预训练、推理服务 | 行业大模型、私有化 LLM 服务 | [训练](/training/) · [推理](/inference/) |
| **推理加速与板卡** | 板卡级推理、边缘推理 | 给现有服务器插卡提速 | [推理](/inference/) · [硬件](/hardware/) |
| **算子与高性能计算** | 自研算子、融合优化 | 把 GPU/CUDA 算子迁到昇腾 | [算子开发](/ops/) |
| **AI 应用平台搭建** | 工作流、RAG、Agent | 用 Dify 搭 LLM 应用平台 | [Dify 部署](/inference/dify) |

## 二、热门玩法详解

### 玩法 1：在昇腾上微调行业大模型 🔥
用 [LLaMA-Factory](/training/llama-factory) 快速微调 Qwen / Llama / DeepSeek 等，打造**行业/私有化**大模型（金融、政务、制造……）。
- 路径：环境搭建 → 微调 → 导出权重
- 落地：离线私有大模型，满足数据不出域需求。

### 玩法 2：部署 OpenAI 兼容的推理服务
用 [vLLM-Ascend](/inference/vllm-ascend) 或 [MindIE](/inference/mindie) 拉一个 `/v1` 推理服务，**无缝接入现有应用**。
- 能直接对接 LLaMA-Factory、LangChain、Dify 等生态。
- 适合把现有基于 OpenAI API 的应用迁移到昇腾。

### 玩法 3：搭建整套 LLM 应用平台（RAG / 工作流 / Agent）
用 [Dify](/inference/dify) 在昇腾基础上搭可视化 Low-code 平台：
- 上传企业知识库 → RAG 问答
- 可视化编排工作流 / 智能体（Agent）
- 一套交付给客户就能用的 LLM 应用底座。

### 玩法 4：给现有服务器插卡做推理加速
在客户已有的 x86/Arm 服务器上插 **Atlas 300I** 系列推理卡，配合 [MindIE](/inference/mindie) 或 vLLM-Ascend 做推理加速。
- 成本友好，复用现有服务器。
- 见 [AI 推理卡](/hardware/inference-card)。

### 玩法 5：把 GPU 模型/算子平滑迁移到昇腾
- 模型层：[PyTorch 模型迁移](/training/pytorch-migration)（cuda→npu，改动小）。
- 算子层：[Triton-Ascend](/ops/triton-ascend)（Python 化）或 [Ascend C](/ops/ascend-c)。
- 适合有存量 CUDA 资产的团队，降低迁移门槛。

### 玩法 6：边缘计算与快速原型
用 [Atlas 200I DK A2](/hardware/devkit-module) 开发套件做边缘推理、算法验证、原型开发，成本低、上手快。

## 三、给客户讲价值时的一页话

> "昇腾不是只有大模型。它可以：
> - **训**：微调 / 预训练行业大模型（数据不出域）
> - **推**：通过标准 OpenAI 兼容接口对接现有应用
> - **搭**：基于 Dify 快速搭起 RAG / 工作流 / Agent 平台
> - **迁**：把已有 GPU 模型与算子平滑迁移过来
> - **边**：用推理卡 / 开发套件做边缘与原型
> 而且每一步都有现成工具链（MindSpeed、LLaMA-Factory、MindIE、vLLM-Ascend、Triton-Ascend、MindStudio），照着 [AscendMate](/guide/) 就能落地。"

## 相关

- [昇腾软硬件全景](/guide/ascend-landscape)
- [如何选择使用路径](/guide/choose-your-path)
