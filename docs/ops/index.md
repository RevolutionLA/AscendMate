# 算子开发全景

> **什么时候读**：标准算子满足不了需求，你需要**开发自定义算子**，或把 GPU 上写的 CUDA/Triton 算子迁移到昇腾 NPU。

昇腾的算子开发主要有两条路径，各有适用场景。

## 一、两条主路

| 路径 | 上手 | 适用 | 入口 |
| --- | --- | --- | --- |
| **Ascend C** | 较专业（类 C++/CUDA） | 高性能、自定义底层算子 | [Ascend C 算子开发](/ops/ascend-c) |
| **Triton-Ascend** | 低（Python 化） | 用 Triton 语法写算子，开发者友好 | [Triton-Ascend](/ops/triton-ascend) |
| **CATLASS 模板库** | 中 | 矩阵乘等算子开发的模板与基础组件 | [CATLASS 快速开始](/ops/catlass) |

## 二、什么时候需要写算子

- 标准算子库缺少你需要的算子/融合。
- 现有算子性能不达标，需要融合或底层优化。
- 迁移其他平台写的自定义算子（CUDA/Triton kernel）。

## 三、开发→调试→优化闭环

```text
算子开发 (Ascend C / Triton) → 精度调试 → 性能调优 (Profiling)
```

- 精度：对比算子结果与标杆算子/CPU 结果，见 [精度调试](/tools/precision-debug)。
- 性能：用 Profiling 看算子耗时，见 [性能调优](/tools/profiling)。

## 四、开发者工具

- **MindStudio**：一体化开发调试工具，见 [MindStudio](/tools/mindstudio)。
- 仿真器、msDebug、Profiling 等辅助手段。

> [!TIP]新手选择
> 不熟悉底层 C++/CUDA 的开发者，强烈推荐 **Triton-Ascend**——用接近 Python 的 Triton 语法即可开发昇腾算子，学习成本显著低于 Ascend C。
