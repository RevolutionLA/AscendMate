<p align="center">
  <img src="docs/public/ascendmate.svg" width="96" alt="AscendMate" />
</p>

<h1 align="center">AscendMate · 昇腾部署易用一指禅</h1>

<p align="center">
  一站式昇腾智算服务器使用手册 —— <b>环境搭建 · 模型微调 · 推理部署 · 算子开发</b>
</p>

<p align="center">
  <a href="https://github.com/&lt;你的用户名&gt;/ascendmate">GitHub</a> ·
  <b>在线文档站（GitHub Pages 自动部署）</b> ·
  <a href="CONTRIBUTING.md">参与贡献</a>
</p>

---

> **采购昇腾智算服务器之后，只看这一个仓库就够了。**
>
> 针对「昇腾资料分散、社区文档少、生态不易用」的痛点，AscendMate 把散落在多个站点的昇腾资料，整理成**按真实场景组织、可全文检索、带实操步骤**的一站式手册。

## ✨ 特性

- **🔍 全站可检索**：VitePress 全文搜索，按关键词、报错、型号、版本快速定位。
- **🗺️ 按场景找答案**：从「我要微调大模型」「我要做推理服务」「我要迁移 GPU 模型」等真实诉求出发。
- **🧱 从零到实战**：覆盖交付整机的完整链路 —— 上电 → 系统 → 驱动 → CANN → 框架 → 业务 → 自检。
- **🚀 训推一体化**：LLaMA-Factory 微调、MindSpeed 预训练、MindIE / vLLM-Ascend / SGLang 推理、Dify 平台。
- **💬 持续沉淀**：面向售前/售后一线经验持续更新，把高频问题沉淀为可检索 FAQ。

## 🚀 快速开始

| 我想… | 去看 |
| --- | --- |
| 从零配好一台昇腾机器 | [环境搭建 · 7 步走](docs/setup/index.md) |
| 微调一个大模型 | [LLaMA-Factory 微调实操](docs/training/llama-factory.md) |
| 部署推理服务 | [MindIE](docs/inference/mindie.md) / [vLLM-Ascend](docs/inference/vllm-ascend.md) |
| 把 GPU 模型迁到昇腾 | [PyTorch 模型迁移](docs/training/pytorch-migration.md) |
| 遇到报错 | [问题定位 FAQ](docs/faq/index.md) |
| 找所有官方链接 | [资源导航总表](docs/resources/links.md) |

## 📂 目录结构

```
AscendMate/
├── README.md
├── docs/                  # VitePress 文档站
│   ├── index.md           # 首页
│   ├── guide/             # 快速开始（选路径 / 7 步走 / 全景）
│   ├── setup/             # 环境搭建（系统/驱动/CANN/框架/Docker）
│   ├── hardware/          # 昇腾硬件（集群/服务器/推理卡/开发套件）
│   ├── training/          # 大模型训练（微调/预训练/迁移）
│   ├── inference/         # 模型推理（MindIE/vLLM/SGLang/Dify）
│   ├── ops/               # 算子开发（Ascend C/Triton/CATLASS）
│   ├── tools/             # 工具链（MindStudio/精度/性能）
│   ├── resources/         # 资源导航（完整链接/模型/下载）
│   ├── faq/               # 问题定位（环境/训练/推理/性能精度）
│   └── contributing/      # 贡献指南
```

## 🛠 本地开发

```bash
npm install
npm run docs:dev     # 本地开发预览
npm run docs:build   # 构建静态站点
```

## 📚 文档导航

- [环境搭建](/docs/setup/) · [昇腾硬件](/docs/hardware/) · [大模型训练](/docs/training/) · [模型推理](/docs/inference/) · [算子开发](/docs/ops/) · [工具链](/docs/tools/) · [资源导航](/docs/resources/) · [问题定位 FAQ](/docs/faq/)

## 🤝 参与贡献

欢迎修正错漏、补充教程、整理 FAQ、优化导航。详见 [贡献指南](CONTRIBUTING.md)。

## ⚖️ 说明与免责

- 本仓库为**开源整理项目**，内容基于公开的昇腾官方文档与开源项目整理，链接指向官方与开源项目，遵循各自许可证。
- 代码/命令请以官方最新版本与配套为准；内容会持续更新，以 GitHub 仓库最新版本为准。
