# MindStudio

> **什么时候读**：你想用**一体化 IDE** 来开发、调试、部署昇腾 AI 应用。

[MindStudio](https://www.hiascend.com/document/detail/zh/mindstudio/830/index/index.html) 是面向昇腾 AI 开发者的**全流程开发工具集**，提供图形化的一体化开发环境。

## 一、功能概览

- 工程创建、代码编辑、编译构建。
- 调用 AscendCL、Ascend C 开发算子。
- 模型转换、推理部署。
- 集成了性能分析、精度调试等能力。

## 二、适用人群

- 昇腾应用 / 算子开发者，希望用图形化 IDE 而非纯命令行。
- 需要一站式「编码 → 构建 → 调试 → 性能分析」的团队开发者。

## 三、快速上手

1. 下载并安装 MindStudio（昇腾开发者官网获取）。
2. 配置昇腾 Toolkit 环境。
3. 新建工程，选择应用类型（AscendCL / Ascend C / 推理等）。
4. 编写代码并构建运行。

> 官方「快速入门」文档见 [MindStudio 官方文档](https://www.hiascend.com/document/detail/zh/mindstudio/830/index/index.html)。因版本迭代，界面与步骤以对应版本的官方文档为准。

## 四、MindStudio 与命令行对比

| 方式 | 特点 |
| --- | --- |
| MindStudio | 图形化、集成调试与性能分析、上手直观 |
| 命令行 + 脚本 | 轻量、可脚本化、适合自动化流水线 |

两者可搭配，开发期用 IDE，跑批再用命令行。

## 相关

- [算子开发全景](https://revolutionla.github.io/AscendMate/ops/)
- [精度调试](https://revolutionla.github.io/AscendMate/tools/precision-debug)
- [性能调优（Profiling）](https://revolutionla.github.io/AscendMate/tools/profiling)
