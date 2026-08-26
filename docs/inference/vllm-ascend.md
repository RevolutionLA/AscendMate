# vLLM-Ascend 部署

> **什么时候读**：你想用成熟的 **vLLM** 生态，在昇腾 NPU 上快速部署 LLM 推理服务。

[vllm-ascend](https://github.com/vllm-project/vllm-ascend) 是 vLLM 官方的昇腾后端插件，让类 Transformer、MoE、多模态等主流大模型能在昇腾 NPU 上无缝运行，并兼容 OpenAI API。**上手快、教程多，是新手推理首选。**

## 一、支持范围（以官方为准）

- **硬件**：Atlas 800I A2 / A3、800T A2/A3 训练、A300I Duo（实验性）等。
- **软件**：Python 3.10–3.12、配套 CANN / PyTorch / torch_npu。

## 二、版本配套（务必查官方）

vllm-ascend 与 vLLM、CANN、PyTorch/torch_npu **版本强配套**。请到官方文档确认对应关系：

- 快速开始 & 安装：<https://docs.vllm.ai/projects/ascend/zh-cn/latest/quick_start.html>

常见配套示例（某正式版）：

| 组件 | 示例版本 |
| --- | --- |
| CANN | 8.5.0（参考对应版本） |
| PyTorch | 2.9.0 |
| torch_npu | 2.9.0 |
| vLLM / vllm-ascend | 版本一致（如 v0.13.0） |

## 三、安装

```bash
# 安装 vllm-ascend 及其配套（按官方指引）
pip install vllm-ascend
# 具体参数与版本以官方文档为准
```

> 被推荐的方式：使用 vllm-ascend 提供的**安装脚本/容器镜像**，可避免大量手动安装。

## 四、启动推理服务（示例）

```bash
# 启动 OpenAI 兼容服务（示意，参数以官方为准）
vllm serve <模型路径或id> \
  --trust-remote-code \
  --served-model-name <名称>
```

启动后默认监听 `http://0.0.0.0:8000`，即可用 OpenAI 兼容接口请求。

验证：

```bash
curl http://127.0.0.1:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"<模型名>","messages":[{"role":"user","content":"你好"}]}'
```

## 五、针对昇腾的加速与最佳实践

- 官方提供 **EP（专家并行）** 等大数据场景教程，适合 MoE 大模型。
- 可用 `vllm.ascend` 相关后端配置做并发/显存调优。
- 参考官方大规格部署（如 专家并行）文档。

## 六、与 MindIE 对比

选择时见 [推理全景](https://revolutionla.github.io/AscendMate/inference/) 的选型表。简言之：**要开源生态与快速上手选 vLLM-Ascend；要深度优化生产方案选 MindIE。**

## 相关

- 常见问题：[推理类问题](https://revolutionla.github.io/AscendMate/faq/inference-issues)
- 性能调优：[性能调优（Profiling）](https://revolutionla.github.io/AscendMate/tools/profiling)

> [!TIP]
> 想在线快速试、不想自己装环境，vllm-ascend 官方教程通常会提供容器/一键启动方式，可优先采用。
