<h1 align="center">AscendMate · 昇腾之家</h1>

<p align="center">
  一站式昇腾智算服务器使用手册 —— <b>环境搭建 · 模型微调 · 推理部署 · 算子开发</b>
</p>

<p align="center">
  <a href="https://github.com/RevolutionLA/AscendMate">GitHub</a> ·
  <a href="https://revolutionla.github.io/AscendMate/">在线文档站</a> ·
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
- **🎓 学习路径（全新专题）**：面向AI行业新人的六阶段体系化学习路径，从零到昇腾AI工程师（已补充AI通识扩展内容）。
- **📊 运维监控**：Prometheus + Grafana 搭建NPU监控大屏、告警规则、巡检SOP、日志管理。
- **💼 场景价值发现**：金融/医疗/政务/制造行业AI场景库，快速POC指南，帮业务人员把算力变成价值。
- **📈 算力运营管理**：利用率监控优化、多团队调度、成本核算，让每一张卡都发挥价值。
- **📦 交付验收与批量部署**：到货验收Checklist、Ansible批量部署方案。

## ⚡ Ascend Assistant（昇腾服务器助手）

**亮点功能**。让 AI 你的得力干将——直接帮你检测环境、定位报错、生成命令、引导部署、给出调优建议。

```bash
skills add https://github.com/RevolutionLA/ascend-assistant
```

覆盖四类能力：**环境检测 + 排障 · 命令生成 · 部署引导 · 性能调优**，并与本手册深度联动。

> 📖 完整说明见站内 [Ascend Assistant](https://revolutionla.github.io/AscendMate/skill/)；独立仓库为 [ascend-assistant](https://github.com/RevolutionLA/ascend-assistant)。

## 🚀 快速开始

| 我想… | 去看 |
| --- | --- |
| 从零配好一台昇腾机器 | [环境搭建 · 7 步走](docs/setup/index.md) |
| 微调一个大模型 | [LLaMA-Factory 微调实操](docs/training/llama-factory.md) |
| 部署推理服务 | [MindIE](docs/inference/mindie.md) / [vLLM-Ascend](docs/inference/vllm-ascend.md) |
| 把 GPU 模型迁到昇腾 | [PyTorch 模型迁移](docs/training/pytorch-migration.md) |
| 遇到报错 | [问题定位 FAQ](docs/faq/index.md) |
| 找所有官方链接 | [资源导航总表](docs/resources/links.md) |
| 我想从零学AI | → [学习路径](docs/learning/index.md) |
| 我想搭建NPU监控 | → [运维监控](docs/monitoring/index.md) |
| 我想找行业场景 | → [场景价值](docs/scenes/index.md) |
| 我想管理算力利用率 | → [运营管理](docs/operations/index.md) |
| 我要验收新到设备 | → [交付验收](docs/setup/delivery-acceptance.md) |

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
│   ├── learning/            # 学习路径（六阶段入行AI，含AI通识补充）
│   ├── monitoring/          # 运维监控（Prometheus/Grafana/告警/巡检/日志）
│   ├── scenes/              # 场景价值发现（行业方案/POC指南）
│   ├── operations/          # 算力运营管理（利用率/调度/成本）
│   └── contributing/      # 贡献指南
```

## 🛠 本地开发

```bash
npm install
npm run docs:dev     # 本地开发预览
npm run docs:build   # 构建静态站点
```

## 📚 文档导航

- [环境搭建](https://revolutionla.github.io/AscendMate/setup/) · [昇腾硬件](https://revolutionla.github.io/AscendMate/hardware/) · [大模型训练](https://revolutionla.github.io/AscendMate/training/) · [模型推理](https://revolutionla.github.io/AscendMate/inference/) · [算子开发](https://revolutionla.github.io/AscendMate/ops/) · [工具链](https://revolutionla.github.io/AscendMate/tools/) · [资源导航](https://revolutionla.github.io/AscendMate/resources/) · [问题定位 FAQ](https://revolutionla.github.io/AscendMate/faq/) · [学习路径](https://revolutionla.github.io/AscendMate/learning/) · [运维监控](https://revolutionla.github.io/AscendMate/monitoring/) · [场景价值](https://revolutionla.github.io/AscendMate/scenes/) · [运营管理](https://revolutionla.github.io/AscendMate/operations/) · [交付验收](https://revolutionla.github.io/AscendMate/setup/delivery-acceptance)

## 🤝 参与贡献

欢迎修正错漏、补充教程、整理 FAQ、优化导航。详见 [贡献指南](CONTRIBUTING.md)。

## ⚖️ 说明与免责

- 本仓库为**开源整理项目**，内容基于公开的昇腾官方文档与开源项目整理，链接指向官方与开源项目，遵循各自许可证。
- 代码/命令请以官方最新版本与配套为准；内容会持续更新，以 GitHub 仓库最新版本为准。
