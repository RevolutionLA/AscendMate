---
layout: home

hero:
  name: "AscendMate"
  text: "昇腾部署易用一指禅"
  tagline: "面向昇腾智算服务器的部署与开发手册：环境搭建、模型微调、推理部署、算子开发的落地操作与检索入口。"
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
    details: 从「我要跑大模型」「我要做推理服务」「我要迁移 GPU 模型」等实际部署目标出发，定位到对应教程与操作步骤。
  - icon: 🔍
    title: 全站可检索
    details: 内置全文搜索，按关键词、报错信息、硬件型号、软件版本定位到对应教程与 FAQ。
  - icon: 🗂️
    title: 统一导航
    details: 把分散在多个站点、多种格式的昇腾资料，整理成目录导航，每个环节都能找到官方文档、样例代码与实操步骤。
  - icon: 🧱
    title: 从零到可运维
    details: 从服务器上电、操作系统、固件驱动、CANN，到 PyTorch / MindSpore，再到训练与推理全链路，覆盖可交付、可运维的流程。
  - icon: 🛠️
    title: 训推一体化
    details: 覆盖 LLaMA-Factory 微调、MindSpeed 预训练、MindIE / vLLM / SGLang 推理、Dify 平台等主流方案。
  - icon: 💬
    title: 持续迭代
    details: 面向部署与运维一线经验持续更新，把高频问题沉淀为 FAQ，欢迎贡献。
---

## 适合谁

| 岗位 | 关注点 | 对应章节 |
| --- | --- | --- |
| **环境交付 / 运维工程师** | 从装系统、驱动、CANN 到搭建可用环境 | [环境搭建](/setup/) 按 7 步走 |
| **算法 / 模型工程师** | 在昇腾上微调、训练、部署推理 | [LLaMA-Factory 微调](/training/llama-factory)、[推理](/inference/mindie) |
| **算子 / 移植工程师** | 自定义算子、GPU 算子迁移 | [算子开发](/ops/)、[PyTorch 迁移](/training/pytorch-migration) |
| **应用 / 集成工程师** | 推理服务、RAG 平台、接入业务 | [推理](/inference/)、[Dify](/inference/dify) |
| **性能 / 调优工程师** | 报错排查、性能提升、精度对齐 | [问题定位 FAQ](/faq/) · [工具链](/tools/) |

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
