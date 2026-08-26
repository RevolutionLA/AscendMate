<p align="center">
  <img src="docs/public/ascendmate.svg" width="96" alt="AscendMate" />
</p>

<h1 align="center">AscendMate · 昇腾之家</h1>

<p align="center">
  一站式昇腾智算服务器使用手册 —— <b>环境搭建 · 模型微调 · 推理部署 · 算子开发</b>
</p>

<p align="center">
  <a href="https://github.com/RevolutionLA/AscendMate">GitHub</a> ·
  <b>在线文档站（GitHub Pages 自动部署）</b> ·
  <a href="CONTRIBUTING.md">参与贡献</a>
</p>

---

> 面向昇腾智算服务器部署与开发的手册：环境搭建、模型微调、推理部署、算子开发的落地操作与检索入口。
>
> 针对「昇腾资料分散、社区文档少、生态不易用」的问题，AscendMate 把散落在多个站点的昇腾资料，整理成**按部署场景组织、可全文检索、带实操步骤**的手册。

## 特性

- **🤖 Ascend Assistant（亮点）**：配套的昇腾服务器助手 Skill，可用 AI 直接操作/查询/排障昇腾服务器（环境检测、排障、命令生成、部署引导、性能调优）。
- **🔍 全站可检索**：VitePress 全文搜索，按关键词、报错、型号、版本快速定位。
- **🗂️ 按场景找答案**：从「我要微调大模型」「我要做推理服务」「我要迁移 GPU 模型」等部署目标出发。
- **🧱 从零到可运维**：覆盖交付整机的完整链路 —— 上电 → 系统 → 驱动 → CANN → 框架 → 业务 → 自检。
- **🚀 训推一体化**：LLaMA-Factory 微调、MindSpeed 预训练、MindIE / vLLM-Ascend / SGLang 推理、Dify 平台。
- **💬 持续迭代**：面向部署与运维一线经验持续更新，把高频问题沉淀为可检索 FAQ。

## ⚡ Ascend Assistant（昇腾服务器助手）

**亮点功能**。让 AI 你的得力干将——直接帮你检测环境、定位报错、生成命令、引导部署、给出调优建议。

```bash
skills add https://github.com/RevolutionLA/ascend-assistant
```

覆盖四类能力：**环境检测 + 排障 · 命令生成 · 部署引导 · 性能调优**，并与本手册深度联动。

> 📖 完整说明见站内 [Ascend Assistant](/skill/)；独立仓库为 [ascend-assistant](https://github.com/RevolutionLA/ascend-assistant)。

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

<!-- 小雅网络验证标记 2026-08-26 12:50 -->