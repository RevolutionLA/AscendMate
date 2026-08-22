# MindIE 服务化拉起

> **什么时候读**：你要在昇腾上做**生产级高性能大模型推理服务**。

[MindIE](https://www.hiascend.com/document/detail/zh/mindie/230/index/index.html) 是华为面向 AI 全场景的**推理加速套件**，深度定制于昇腾硬件，性能好、服务化能力强，是昇腾生产推理的主流选择之一。

## 一、MindIE 是什么

- **MindIE（Mind Inference Engine）**：昇腾自研推理引擎，主推高性能、低延迟、高吞吐的 LLM 服务化。
- 提供模型推理、服务化（HTTP）、调度等能力。
- 相比接入通用引擎，对昇腾算子与内存做了深度亲和优化。

## 二、基础流程（服务化拉起）

MindIE 服务化的大致流程：

1. **准备模型权重**（safetensors 等）。
2. **获取 MindIE 及其依赖**（镜像或安装包，见官方发布）。
3. **配置模型与推理参数**（模型路径、显存、max-seq-len、并发等，通常为 JSON/YAML 配置或启动参数）。
4. **启动推理服务**（加载模型 → 监听端口）。
5. **发起推理请求**（OpenAI 兼容 / MindIE 原生接口）。
6. **监控与压测**。

> 详细步骤以 MindIE 官方文档与离线「MindIE 服务化拉起流程」文档为准。不同 MindIE 版本配置差异较大，务必对照对应版本手册。

## 三、前置环境

- 昇腾环境就绪（[环境搭建](/setup/)）。
- 驱动/CANN/torch 版本与 MindIE 版本**配套**（查 MindIE 发布说明）。
- 通常建议用官方 MindIE **Docker 镜像**（[AscendHub](/setup/docker-offline)），避免环境坑。

## 四、常见配置关注点

- **模型格式**：MindIE 支持多种加载方式，注意权重与 tokenizer 准备。
- **bs / seq_len**：max-batch、max-seq 关系显存占用。
- **KV Cache**：显存分配策略影响可并发与吞吐。
- **调度**：连续批处理（continuous batching）可提升吞吐。

## 五、验证

- 服务启动后，CPU/内存/NPU 有加载模型占用。
- 用 curl / 客户端发请求，能返回推理结果，即拉起成功。

```bash
# 示意：向推理服务发请求（以实际接口为准）
curl -X POST http://127.0.0.1:<port>/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"...","messages":[{"role":"user","content":"你好"}]}'
```

## 六、与 vLLM-Ascend 如何选

| 维度 | MindIE | vLLM-Ascend |
| --- | --- | --- |
| 定位 | 华为自研、深度优化 | vLLM 官方插件、生态开放 |
| 上手 | 配置较专 | 上手快、教程多 |
| 适用 | 生产高性能、对昇腾深度优化 | 通用、开源生态、快速迭代 |

两者可并存，视项目对性能/生态的侧重选择。

## 相关

- 参考模型代码：ModelZoo 的 MindIE 子目录，见 [资源导航](/resources/samples-models)。
- 性能调优：[性能调优（Profiling）](/tools/profiling)
- 常见问题：[推理类问题](/faq/inference-issues)

> [!NOTE]
> MindIE 不同大版本（如 2.x）配置与命令差异明显，遇到问题时先确认**版本对应手册**。
