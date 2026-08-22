# Triton-Ascend

> **什么时候读**：你熟悉 **Triton**（Python 化 GPU 算子开发），想把算子迁移到昇腾，或想用低门槛方式开发昇腾算子。

[Triton-Ascend](https://gitcode.com/Ascend/triton-ascend) 把 **Triton 编译栈适配到昇腾 NPU**，让用 Triton 语法写的算子能在昇腾高效运行。对熟悉 Triton 的开发者，学习成本大幅降低。

## 一、核心价值

- **Python 化开发**：只需关注 Tile/Block 切分与运算逻辑，编译器自动处理内存分配、数据搬运与流水。
- **生态打通**：vLLM、SGLang 等仓库中的重点 Triton 算子已在昇腾适配。
- **加速比接近 Ascend C**：在 FA、MM、Softmax 等关键算子上，Triton-Ascend 性能逼近 Ascend C。

## 二、版本配套（以官方为准）

| 版本（示例） | CANN 版本 |
| --- | --- |
| Triton-Ascend 3.2.0 | CANN 8.5.0（商用/社区） |
| 3.2.0rc4 | CANN 8.3.RC2 / 8.3.RC1 |

- **Python API 支持度**持续提升（当前较高版本支持 85%+ Triton Python API，详见官方）。
- 支持访存（连续访存）、部分非连续访存等。

## 三、硬件支持范围

| 系列 | 产品 |
| --- | --- |
| A3 训练 | Atlas 800T A3 超节点、900 A3 SuperPoD 等 |
| A3 推理 | Atlas 800I A3 超节点等 |
| A2 训练 | Atlas 800T A2、900 A2 PoD 等 |
| A2 推理 | Atlas 800I A2、300I A2 等 |

> 支持的操作系统与 CANN 一致，选包时参考 CANN 支持范围。

## 四、安装

```bash
# 安装 Triton-Ascend（以 PyPI 为例）
pip install triton-ascend
```

> 具体安装与配套以 [官方 README（中文）](https://gitcode.com/Ascend/triton-ascend) 为准。

## 五、开始开发

1. 用 Triton 语法写 Kernel（`@triton.jit`）。
2. 在昇腾上用 Triton-Ascend 编译运行。
3. 精度对比：用 `msDebug` / 与 CPU 或 Ascend C 结果对比（见 [精度调试](/tools/precision-debug)）。
4. 性能调优：用 Profiling 定位（见 [性能调优](/tools/profiling)）。

> 官方提供「快速开始」「算子开发指南」「算子迁移指南（从 GPU）」「算子调试指南」「性能调优指南」等文档，在仓库 `docs/zh/` 目录下。

## 六、从 GPU Triton 迁移到昇腾

- 迁移指南见官方 `docs/zh/migration_guide/migrate_from_gpu.md`。
- 注意算子 API 支持度、访存方式与数据类型的差异。

## 七、与 Ascend C 的选择

| | Triton-Ascend | Ascend C |
| --- | --- | --- |
| 学习成本 | 低（Python） | 高（C++） |
| 性能上限 | 高（逼近 Ascend C） | 最高（可极致调优） |
| 适用 | 快速开发、生态迁移 | 核心热点算子、极致性能 |

> [!TIP]
> 建议先用 **Triton-Ascend 快速跑通**，再用 **Ascend C** 优化真正热点的算子。

## 相关

- [算子开发全景](/ops/)
- [CATLASS 快速开始](/ops/catlass)
- [Triton 官方](https://triton-lang.org)

> [!NOTE]许可证
> Triton-Ascend 采用 MIT 许可证；使用与二次开发请遵守其许可证与安全声明。
