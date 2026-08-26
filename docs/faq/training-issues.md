# 训练类问题

> 昇腾上**模型训练/微调**阶段的常见报错与排查。

## 一、torch_npu 相关报错

| 报错/现象 | 排查 |
| --- | --- |
| `import torch_npu` 失败 | 检查 torch 与 torch_npu **版本配套**（见 [安装页](https://revolutionla.github.io/AscendMate/setup/torch-npu-install)） |
| 设备不可用 / `not initialized` | 确认 `npu-smi` 正常、环境变量 source 正确 |
| 算子不支持的报错 | 用 npu 支持的算子/API，或查看 [算子开发](https://revolutionla.github.io/AscendMate/ops/) |

## 二、显存 / 内存不足（OOM）

**现象**：`out of memory` / 卡死 / 训练被打断。

**对策**：

- 减小 batch size / 序列长度。
- 使用 LoRA / QLoRA 减少显存（[LLaMA-Factory](https://revolutionla.github.io/AscendMate/training/llama-factory)）。
- 开启重计算、优化器状态切分等（[MindSpeed](https://revolutionla.github.io/AscendMate/training/mindspeed) 内存优化特性）。
- 多卡并行分担。

## 三、Loss 异常（NaN / 不收敛）

- 先排除混合精度 / 数值格式问题（bf16/fp32）。
- 检查数据预处理与学习率。
- 固定随机种子保证可复现。
- 用 [精度调试](https://revolutionla.github.io/AscendMate/tools/precision-debug) 定位。

## 四、分布式 / 并行训练失败

| 现象 | 排查 |
| --- | --- |
| 多卡通信报错 | 检查 HCCL / 网络拓扑，用 `npu-smi info` 确认 N 卡都在 |
| `Gloo` / 建链失败 | 配置 HCCL 替代 Gloo（MindSpeed `hccl-replace-gloo`） |
| 并行策略不兼容 | 校验张量/流水/数据并行参数，见 [MindSpeed](https://revolutionla.github.io/AscendMate/training/mindspeed) |

## 五、训练速度慢

- 用 **Profiling** 找瓶颈（算子 vs 通信 vs 数据），见 [性能调优](https://revolutionla.github.io/AscendMate/tools/profiling)。
- 关键算子是 CPU 算子 → 优化为 NPU 算子。
- 数据加载慢 → 增加 num_workers / 异步预处理。

## 六、内存（Host）不足

大模型权重/优化器常驻内存，超单机时用**并行策略**或 MindSpeed 的切分/swap 特性（[MindSpeed](https://revolutionla.github.io/AscendMate/training/mindspeed)）。

> [!TIP]
> 训练问题多源于**版本、显存策略、算子兼容**三方面。先跑最小复现定位问题在哪一层。
