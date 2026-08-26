# 推理类问题

> 昇腾上**模型推理服务**阶段的常见报错与排查。

## 一、服务起不来 / 加载失败

| 现象 | 排查 |
| --- | --- |
| 模型权重加载失败 | 确认模型路径/格式正确，tokenizer 与权重匹配 |
| 显存不足无法加载 | 模型过大超出单卡 HBM，考虑多卡 / KV Cache 策略 |
| 引擎模块报错 | 确认推理引擎与 CANN/torch 版本配套（见各引擎页） |

**通用排查**：

1. `npu-smi info` 确认设备与可用显存。
2. 看服务日志开头几行，往往直接点名缺什么（权重、配置、依赖）。
3. 先加载小模型/小显存验证引擎本身 OK。

## 二、请求错误 / 返回异常

- 模型名是否与服务配置一致（OpenAI 兼容接口常见）。
- 输入格式（messages/多模态）是否符合模型要求。
- 用 curl 直接测 vs 应用层调用分离定位。

## 三、并发 / 显存 / 请求太多

- **OOM / 请求失败**：降低 max-batch / 并发，或调 KV Cache 分配。
- **吞吐低**：启用连续批处理，增大 bs / 并发。
- 详见 [性能与精度问题](https://revolutionla.github.io/AscendMate/faq/perf-precision-issues)。

## 四、延迟高 / 服务卡顿

- 用 **Profiling** 定位（prefill/decode 阶段瓶颈）。
- 检查是否被其他任务占用设备（`npu-smi info` 看占用率）。

## 五、不同引擎的专项

| 引擎 | 常见坑 |
| --- | --- |
| **MindIE** | 版本配置差异大，务必用对应版本手册（见 [MindIE](https://revolutionla.github.io/AscendMate/inference/mindie)） |
| **vLLM-Ascend** | 版本配套严格，查官方快速开始（见 [vLLM](https://revolutionla.github.io/AscendMate/inference/vllm-ascend)） |
| **SGLang** | MoE/EP 通信配置，见 [SGLang](https://revolutionla.github.io/AscendMate/inference/sglang) |

> [!TIP]
> 推理问题先确认「引擎版本配套 + 模型能加载 + 接口地址正确」，再谈性能。
