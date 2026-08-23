# Ascend Assistant · 昇腾服务器助手

> **本仓库的亮点功能**：让 AI 直接帮你操作、查询、排障昇腾服务器。
> 与 AscendMate 文档站深度配套 —— 这里是完整手册，[Ascend Assistant](https://github.com/RevolutionLA/ascend-assistant) 负责"遇到问题怎么一步步操作"。

## 这是什么

**Ascend Assistant** 是一个 Agent **Skill**（操作指南），装进你的 AI 助手后，它能安全、准确地帮你：

- 🔍 **环境检测 + 排障**：检测设备/驱动/CANN/框架状态，定位并解释报错
- ⌨️ **命令生成与建议**：生成安装、推理、微调等可直接复制的命令
- 🚀 **部署脚本引导**：从裸机到跑起推理，step-by-step 引导
- ⚡ **性能调优建议**：基于 Profiling 输出给出调优方向

它专门为昇腾智算服务器设计，覆盖用户使用最频繁的两大场景：**模型推理部署** 与 **性能调优**。

## 安装方法（推荐）

```bash
# 方式一：用 skill 命令（推荐）
skills add https://github.com/RevolutionLA/ascend-assistant
# 或
skills install RevolutionLA/ascend-assistant

# 方式二：clone 后放入你的 Agent 技能目录
git clone https://github.com/RevolutionLA/ascend-assistant.git
# 把 ascend-assistant/SKILL.md 放入 .agents/skills/ 或 .claude/skills/ 等目录
```

> 更多安装方式与注意事项见 [ascend-assistant 仓库 README](https://github.com/RevolutionLA/ascend-assistant)。

## 使用示例

对你的 AI 助手说：

| 你会这样问 | 触发的能力 |
| --- | --- |
| "检查这台昇腾服务器环境是否正常" | 环境检测 |
| "torch_npu 报 driver not initialized，帮我看看" | 排障 |
| "在 openEuler + CANN 8.3.RC2 装 torch_npu 的命令" | 命令生成 |
| "按 7 步把裸机昇腾服务器跑起来" | 部署引导 |
| "推理吞吐低，怎么调优" | 性能调优 |

## 能力与 AscendMate 手册的联动

Ascend Assistant 在回答时，会把它能落地的细节联动到本手册的对应章节：

| 能力 | 联动的 AscendMate 章节 |
| --- | --- |
| 环境检测 / 自检 | [环境自检清单](/setup/checklist) |
| 排障 | [/faq/ 问题定位](/faq/) |
| 命令生成 | [训练](/training/) · [推理](/inference/) |
| 部署引导 | [7 步走](/guide/seven-steps) |
| 性能调优 | [性能调优 Profiling](/tools/profiling) |

> 也就是说：**本手册负责"为什么、完整怎么做"；Ascend Assistant 负责"你手头这台机器、现在就帮我做"**——两者互相引用，一起用效率最高。

## 如何贡献 / 反馈

- 想加能力、改进排障规则？去 [ascend-assistant 仓库](https://github.com/RevolutionLA/ascend-assistant) 提 Issue / PR。
- 想给手册补充教程？看本仓库的 [贡献指南](/contributing/)。

> [!NOTE]
> 本 Skill 基于公开资料整理，命令与版本以官方发布为准；涉及驱动升级、重装等高风险操作请谨慎并自行确认环境。
