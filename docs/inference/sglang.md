# SGLang-Kernel-NPU

> **什么时候读**：你想在昇腾上用 **SGLang** 生态做 LLM 推理，尤其是 **MoE / 专家并行**大模型（如 DeepSeek 系列）。

[SGLang-Kernel-NPU](https://github.com/sgl-project/sgl-kernel-npu) 是 **SGLang 框架在昇腾 NPU 的官方内核库**，提供高性能、可上生产环境的推理原语，并内含 **DeepEP-Ascend**（针对 MoE 专家并行通信的优化内核）。

## 一、两大组成

| 组件 | 作用 |
| --- | --- |
| **DeepEP-Ascend** | DeepEP 的昇腾实现，优化 MoE 的 Expert Parallelism 通信（dispatch/combine） |
| **SGLang-Kernel-NPU** | 推理内核集合：Attention（MLA/GQA）、RMSNorm、SwiGLU、LoRA、MLA 预处理等 |

## 二、能获得什么

- **Decode 低延迟**：支持低延迟模式（如 128 token/batch，sub-150us 量级）。
- **高吞吐**：normal 模式支持大 token/batch（A3 最高 65536）。
- **MoE 能力**：token dispatch/combine 自动负载均衡、INT8/FP8/BF16 量化节省带宽。

## 三、快速开始

- DeepEP-Ascend：见仓库内 `python/deep_ep/README.md`
- SGLang-Kernel-NPU：见仓库内 `python/sgl_kernel_npu/README.md`

```bash
# 按各组件 README 安装并跑示例（以官方为准）
```

## 四、适用场景

- **MoE 大模型**（如 DeepSeek-V3/R1 等）的专家并行推理。
- 需要**低延迟、高吞吐**并重的生产 LLM 推理。
- 与 SGLang 框架深度结合的项目。

## 五、硬件/平台

- 支持 A2（Intranode HCCS + 机间 RDMA）与 A3（full-mesh HCCS）等平台。
- 具体支持范围以仓库 README 为准。

## 选择建议

- 通用/快速上手的推理 → [vLLM-Ascend](/inference/vllm-ascend) 或 [MindIE](/inference/mindie)。
- **MoE / 大规模专家并行**、要 DeepEP 同级能力 → SGLang-Kernel-NPU。

## 相关

- [推理全景](/inference/)
- [推理类问题](/faq/inference-issues)

> [!NOTE]许可证
> SGLang-Kernel-NPU 为开源项目，遵循其自身许可证，使用前请查阅。
