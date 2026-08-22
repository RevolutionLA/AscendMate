---
layout: home

hero:
  name: "AscendMate"
  text: "昇腾部署易用一指禅"
  tagline: "采购昇腾智算服务器后，只看这一个仓库就够了。一站式搞定环境搭建、模型微调、推理部署与算子开发。"
  image:
    src: /ascendmate.svg
    alt: AscendMate
  actions:
    - theme: brand
      text: 快速开始
      link: /guide/
    - theme: alt
      text: 完整资源导航
      link: /resources/
    - theme: alt
      text: 问题定位 FAQ
      link: /faq/

features:
  - icon: 🚀
    title: 按场景找答案
    details: 从「我要跑大模型」「我要做推理服务」「我要迁移 GPU 模型」等真实场景出发，一步步带你走到目标，而不是淹没在文档海洋里。
  - icon: 🔍
    title: 全站可检索
    details: 内置全文搜索，按关键词、报错信息、硬件型号、软件版本快速定位到对应教程与 FAQ，几秒钟找到解决办法。
  - icon: 🗺️
    title: 一图看懂全景
    details: 把散落在多个站点、多种格式的昇腾资料，整理成清晰的目录导航，每个环节都能找到对应的官方文档、样例代码与实操步骤。
  - icon: 🧱
    title: 从零到实战
    details: 从服务器上电、操作系统、固件驱动、CANN，到 PyTorch / MindSpore，再到训练与推理全链路，覆盖真实交付场景。
  - icon: 🛠️
    title: 训推一体化
    details: 覆盖 LLaMA-Factory 微调、MindSpeed 预训练、MindIE / vLLM / SGLang 推理、Dify 平台等主流方案。
  - icon: 💬
    title: 持续沉淀
    details: 面向售前与售后一线经验持续更新，把客户高频问题整理为 FAQ，贡献即共建，欢迎 PR。
---

## 谁在使用 AscendMate

| 角色 | 遇到的问题 | AscendMate 帮到你什么 |
| --- | --- | --- |
| **采购/项目决策者** | 昇腾到底能做什么、硬件怎么选、生态行不行 | 看 [昇腾硬件全景](/hardware/) 与 [昇腾全景](/guide/ascend-landscape) |
| **环境交付工程师** | 服务器买回来不知道怎么装系统、装驱动、装 CANN | 从 [快速开始](/guide/seven-steps) 按 7 步一路做下去 |
| **算法/模型工程师** | 模型怎么在昇腾上微调、训练、部署推理 | 看 [LLaMA-Factory 微调](/training/llama-factory)、[推理](/inference/mindie) |
| **运维/调优工程师** | 报错了怎么排查、性能怎么提升、精度怎么对齐 | 看 [问题定位 FAQ](/faq/) 与 [工具链](/tools/) |

## 三步上手

1. **选路径**：在 [快速开始](/guide/choose-your-path) 里找到你所属的角色和场景。
2. **做环境**：顺着 [7 步走](/guide/seven-steps) 完成从裸机到可跑第一行 PyTorch。
3. **跑业务**：进入 [训练](/training/) 或 [推理](/inference/)，用现成方案跑起你的模型。

> [!TIP]
> 想看一份完整链接清单？直接去 [资源导航总表](/resources/links)，所有官方文档、代码仓、下载入口都在一张表里。

## 站点导航速览

- **环境搭建** `/setup/`：操作系统 · 固件驱动 · CANN · PyTorch · MindSpore · Docker
- **昇腾硬件** `/hardware/`：集群 · A2/A3 服务器 · 推理卡 · 开发套件
- **大模型训练** `/training/`：LLaMA-Factory · MindSpeed · 模型迁移
- **模型推理** `/inference/`：MindIE · vLLM-Ascend · SGLang · Dify
- **算子开发** `/ops/`：Ascend C · Triton-Ascend · CATLASS
- **工具链** `/tools/`：MindStudio · 精度调试 · 性能调优
- **资源导航** `/resources/`：完整链接总表 · 样例代码 · 软件下载
- **问题定位** `/faq/`：环境 · 训练 · 推理 · 性能精度

> [!NOTE]
> 本仓库为开源整理项目，链接指向昇腾官方与各开源项目，遵循各自许可证。内容会持续更新，欢迎 [贡献](/contributing/)。
