# 模型推理全景

> **什么时候读**：你需要把训练/微调好的大模型在昇腾上**部署为推理服务**（在线/离线推理）。

## 一、推理引擎选型

昇腾推理有几个主要选择，按你的需求挑：

| 引擎 | 特点 | 适用 | 上手难度 |
| --- | --- | --- | --- |
| **MindIE**（自研） | 昇腾 AI 全场景推理加速套件，性能好 | 生产级高性能推理 | 中 |
| **vLLM-Ascend** | vLLM 官方昇腾插件，生态好、教程多 | 通用 LLM 推理、与 OpenAI 兼容 | 低 |
| **SGLang-Kernel-NPU** | SGLang 官方内核库，含 DeepEP（MoE/EP） | 高级推理、MoE 大模型 | 中 |
| **LLaMA-Factory API** | 内嵌推理接口 | 微调后快速测试 | 最低 |

## 二、推荐路径

- **想最快跑起一个推理服务（新手）** → [vLLM-Ascend 部署](/inference/vllm-ascend)（生态教程最全）。
- **追求自研高性能生产方案** → [MindIE 服务化拉起](/inference/mindie)。
- **做 MoE / 专家并行大模型推理** → [SGLang-Kernel-NPU](/inference/sglang)。
- **微调后马上测** → [LLaMA-Factory 微调实操](/training/llama-factory) 里的 API 章节。
- **要一套完整 RAG / 应用平台** → [Dify 平台部署](/inference/dify)。

## 三、推理部署通用步骤

1. **导出模型权重**：safetensors / GGUF 等（从微调或开源仓库获得）。
2. **准备环境**：CANN + torch_npu（+ 对应推理引擎）。
3. **拉起服务**：配置模型路径、显存、并发 → 启动 HTTP 服务。
4. **接入应用**：用 OpenAI 兼容 API 接入你的业务。
5. **压测调优**：评估吞吐/延迟（见 [性能与精度问题](/faq/perf-precision-issues)）。

## 四、模型从哪来

- 开源权重：魔乐社区（昇腾适配）、魔搭、HuggingFace。
- 微调产出：用 LLaMA-Factory export，见 [LLaMA-Factory](/training/llama-factory)。
- 参考代码：ModelZoo，见 [资源导航](/resources/samples-models)。

> [!NOTE]在线/离线
> 各推理引擎多为在线（需联网拉依赖/权重）或离线（内网已预置）两种用法，详见各页与 [Docker 离线部署](/setup/docker-offline)。

## 下一步

按你的选型进入对应页面，或先去 [推理类问题](/faq/inference-issues) 看常见坑、避免走弯路。
