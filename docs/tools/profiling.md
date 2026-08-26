# 性能调优（Profiling）

> **什么时候读**：要分析昇腾上 AI 任务的**性能瓶颈**（耗时、吞吐、显存），或用数据驱动地调优。

昇腾 **Profiling 工具**可以分析运行在昇腾 AI 处理器上的任务**各个运行阶段的关键性能指标**，找出瓶颈并指导优化。

## 一、为什么用 Profiling

性能问题不能靠猜。Profiling 帮你回答：

- 时间都花在哪（算子 / 通信 / 数据 / 调度）？
- 显存/HBM 利用率有多高？
- 通信（HCCL）占比多大？
- 哪个算子最慢？

## 二、官方工具

- **性能调优工具（Profiling）**：官方文档见 [CANN Profiling](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/devaids/Profiling/atlasprofiling_16_0001.html)。
- 常配合 MindStudio / 命令行使用，可采集算子、通信、内存等指标。

## 三、典型调优步骤

```text
1. 采集 Profiling 数据
2. 分析热点（算子耗时占比 / 通信占比）
3. 对症优化：
   - 算子慢 → 用融合算子 / Ascend C 自研
   - 通信占比高 → 调并行策略 / HCCL
   - 显存/OOM → 显存优化
4. 复测验证
```

## 四、常见优化点（速查）

| 现象 | 可能的优化方向 |
| --- | --- |
| 单个算子慢 | 换融合算子、优化 Tile、思路见 [算子开发](https://revolutionla.github.io/AscendMate/ops/) |
| 通信占比较高 | 调张量/流水并行、减小通信频次（MindSpeed 特性） |
| 显存不足/OOM | 减 batch、重计算、优化器状态切分、KV Cache 管理 |
| 吞吐低 | 连续批处理（推理）、增大并发/bs |
| 数据加载慢 | 数据预处理异步、加大 num_workers |

更多性能问题定位见 [性能与精度问题](https://revolutionla.github.io/AscendMate/faq/perf-precision-issues)。

## 相关

- [工具链全景](https://revolutionla.github.io/AscendMate/tools/)
- [精度调试](https://revolutionla.github.io/AscendMate/tools/precision-debug)
- [MindStudio](https://revolutionla.github.io/AscendMate/tools/mindstudio)
