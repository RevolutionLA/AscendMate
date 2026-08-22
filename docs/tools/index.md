# 工具链全景

> **什么时候读**：你需要**开发调试、精度对齐、性能调优**，或想用一体化 IDE 提升昇腾开发效率。

昇腾工具链覆盖从开发到调优的全流程。

## 一、工具一览

| 工具 | 用途 | 入口 |
| --- | --- | --- |
| **MindStudio** | 一体化开发调试工具（IDE） | [MindStudio](/tools/mindstudio) |
| **精度调试工具** | 对比算子/模型结果，定位精度问题 | [精度调试](/tools/precision-debug) |
| **性能调优工具（Profiling）** | 分析各阶段性能指标，找性能瓶颈 | [性能调优（Profiling）](/tools/profiling) |
| **仿真器 / msDebug** | 算子开发辅助 | 见 [算子开发](/ops/) 各页 |
| **AISBench** | 模型评测/性能基准 | [资源导航](/resources/samples-models) |

## 二、开发调试链路

```text
编码 (MindStudio 或任意 IDE)
   → 编译 (CANN / Ascend C)
   → 精度对比 (精度调试工具 / CPU对比)
   → 性能分析 (Profiling)
   → 优化迭代
```

## 三、什么时候用什么

- 一体化编码 + 调试 → **MindStudio**。
- 训练/推理结果数值不对 → **精度调试工具**。
- 慢/吞吐低/OOM → **性能调优（Profiling）**。

> [!TIP]
> 新手建议：装 MindStudio 做一体化开发，遇到精度或性能问题再针对性用精度调试与 Profiling 工具。

## 下一步

按需求进入对应工具页。
