# Dify 平台部署

> **什么时候读**：你想在昇腾基础上搭建一套**可用的 LLM 应用开发/交付平台**（可视化工作流、RAG、Agent、对话应用）。

[Dify](https://github.com/langgenius/dify) 是开源 LLM 应用开发平台，支持可视化编排、RAG、Agent 等功能。配合昇腾的推理后端，可以搭建一套**国资/企业可落地的 LLM 应用平台**。

## 一、总体思路

```
用户应用界面 (Dify Web)
        │
    Dify 后端 (API / Workflow / RAG)
        │
    LLM 推理引擎 (昇腾后端)
        │  OpenAI 兼容接口
    MindIE / vLLM-Ascend / Ollama-Ascend 等
        │
    昇腾 NPU (CANN + torch_npu)
```

Dify 通过标准的 **OpenAI 兼容 API** 接入模型。所以在昇腾上，你**先把一个支持 OpenAI 兼容接口的推理引擎跑起来**（如 [vLLM-Ascend](https://revolutionla.github.io/AscendMate/inference/vllm-ascend) 或 [MindIE](https://revolutionla.github.io/AscendMate/inference/mindie)），再把它的地址填进 Dify 即可。

## 二、前置环境

- 昇腾环境就绪（[环境搭建](https://revolutionla.github.io/AscendMate/setup/)）。
- 已跑通一个推理引擎，拿到一个 `http://<ip>:<port>/v1` 的地址。
- 有 Docker（Dify 一般用 Docker Compose 部署）。

## 三、部署 Dify（标准方式）

Dify 官方提供 Docker Compose 一键部署：

```bash
git clone https://github.com/langgenius/dify.git
cd dify/docker
cp .env.example .env
docker compose up -d
```

> 依赖 OpenAI 的镜像拉取/国内加速，请视网络情况配置镜像源。具体以 Dify 官方文档为准。

## 四、把昇腾模型接入 Dify

1. 打开 Dify Web 控制台，进入「设置 → 模型供应商」。
2. 添加一个 **OpenAI-API-compatible** 供应商：
   - **Base URL**：填你的昇腾推理服务地址（如 `http://<ip>:<port>/v1`）。
   - **API Key**：本地推理服务可不校验，可填任意占位。
   - **模型名**：填推理服务里配置的模型名。
3. 保存并测试，能返回模型名即接入成功。
4. 之后即可在工作流/RAG/对话应用里使用该「昇腾模型」。

## 五、落地关注点

- **多用户**：Dify 面向多用户/多应用，注意资源（显存/并发）规划。
- **RAG 嵌入模型**：Dify 的向量化也可接入昇腾本地模型，或使用内置/第三方嵌入。
- **离线内网**：需提前离线部署 Docker 镜像与模型权重（[Docker 离线部署](https://revolutionla.github.io/AscendMate/setup/docker-offline)）。
- **权限与安全**：企业版/开源自建需关注账号与访问控制。

## 六、验证

- Dify 控制台正常，工作流能调用昇腾模型并返回结果 → 部署成功。

## 相关

- 选择一个推理后端：[推理全景](https://revolutionla.github.io/AscendMate/inference/)
- 离线部署：[Docker 镜像与离线部署](https://revolutionla.github.io/AscendMate/setup/docker-offline)

> [!NOTE]以官方为准
> Dify 版本迭代快，部署细节（Compose 文件、环境变量、供应商配置）请以 Dify 官方文档为准。本页给出的是昇腾接入的整体方法。
