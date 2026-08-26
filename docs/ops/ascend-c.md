# Ascend C 算子开发

> **什么时候读**：你需要开发昇腾**高性能底层算子**，追求对硬件的最强控制。

[Ascend C](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/opdevg/Ascendcopdevg/atlas_ascendc_map_10_0002.html) 是昇腾专门为 NPU 设计的算子编程语言/C++ 开发范式，能充分挖掘硬件性能，是写高性能自研算子的主流途径。

## 一、Ascend C 是什么

- 对标"NPU 上的 CUDA-like 开发语言"，贴近硬件（向量、标量、张量计算单元）。
- 开发者可以精确控制计算流水、数据搬运与内存，达成最优性能。
- 依托 **CANN** 提供的 Ascend C 编译与运行环境。

## 二、开发前置

- 昇腾环境就绪（[环境搭建](https://revolutionla.github.io/AscendMate/setup/)），需安装 **CANN Toolkit**（含 Ascend C 相关）。
- 建议配合 **MindStudio** 进行开发调试（见 [MindStudio](https://revolutionla.github.io/AscendMate/tools/mindstudio)）。

## 三、开发一般流程

1. 设计算子：明确输入/输出、shape、精度、计算逻辑。
2. 编码：用 Ascend C 编写 Kernel（如 Matmul、非线性、融合算子）。
3. 编译：通过 CMake / 编译脚本生成可执行算子。
4. 调测：用样例/框架调用，做精度与性能验证。
5. 集成：封装成框架可用的算子（torch/MindSpore 对接）。

> 官方有「入门教程、编程指南、算子实践参考」，见 [官方 Ascend C 文档](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/opdevg/Ascendcopdevg/atlas_ascendc_map_10_0002.html)。

## 四、跟 CUDA 的对应

| CUDA 概念 | Ascend C 对应 |
| --- | --- |
| Kernel / <<< >>> | Kernel + 编译脚本 |
| Thread/Block 网格 | Task / Core 调度 |
| 共享内存 | UB（Unified Buffer）/ 片外内存搬移 |
| CUDA C++ | Ascend C（C++ 语法 + 硬件封装） |

## 五、学习资源

- 官方文档：入门教程、编程指南、算子实践。
- 样例：昇腾 samples（[资源导航](https://revolutionla.github.io/AscendMate/resources/samples-models)）。
- CATLASS 模板库：用现成模板起步（[CATLASS](https://revolutionla.github.io/AscendMate/ops/catlass)）。

> [!TIP]降低门槛
> 若你不需要极致性能、且熟悉 Triton，可用 [Triton-Ascend](https://revolutionla.github.io/AscendMate/ops/triton-ascend) 以更低成本开发，再按需用 Ascend C 优化热点。

## 相关

- [精度调试](https://revolutionla.github.io/AscendMate/tools/precision-debug)
- [性能调优（Profiling）](https://revolutionla.github.io/AscendMate/tools/profiling)
- [算子开发全景](https://revolutionla.github.io/AscendMate/ops/)
