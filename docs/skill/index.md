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

## 混合模式：何时联动官方 agent-skills

本 Skill 采用混合模式：
- **通用请求**：由 Ascend Assistant 内建完成。
- **专项请求**：路由到昇腾官方 [Ascend/agent-skills](https://github.com/Ascend/agent-skills) 里更成熟的专项 skill（如复杂 Profiling → `ascend-profiling-anomaly`、NPU 驱动自动装 → `ascend-npu-driver-install`、vLLM-Ascend 部署 → `vllm-ascend-deploy`、算子开发 → `ascendc-operator-*` 等）。

> 既吸收了官方成熟能力，又避免重复造轮子。官方仓库有 60+ 个专业 skill，可按需选用。

## 如何用 AI 提问昇腾（FAQ）

想让 AI 助手给你最有效的回答，提问前带上**必要上下文**；下面是一些提问套路。

**Q1：环境检测怎么问？**
> "帮我检查这台昇腾服务器环境是否正常。我跑一下 `npu-smi info` 把输出贴给你。"

**Q2：报错怎么问最有效？**
> "`torch_npu` 报 `driver not initialized`。我的机型是 Atlas 800I A3，CANN 8.3.RC2，torch 2.6。完整报错如下：……"

**Q3：要命令时怎么说才准？**
> "在 openEuler 24.03 + CANN 8.3.RC2 下，给我装 torch_npu 的命令（先确认配套）。"

**Q4：部署引导怎么启动？**
> "按 7 步带我把这台裸机 Atlas 800I A3 跑起来，目标是能跑 Qwen 推理。"

**Q5：性能调优怎么问？**
> "推理吞吐低。我跑了 Profiling，输出在 /path。帮我分析哪慢。"

**Q6：版本配套不确定？**
先问类："我要在这台 Atlas 800T A2 上装 torch，帮我确认配套的 CANN / torch_npu 版本。"（配套是昇腾最坑的部分，先确认再动手。）

> 核心心法：**给 AI"机型 + 系统 + 版本 + 报错原文 + 目标"**，它就能基于这套 Skill + 手册给你可照做的步骤。

## 常见报错速查

先跑一版 [ascend-assistant](https://github.com/RevolutionLA/ascend-assistant) 的只读诊断脚本，快速定位（下载后本地运行，`curl -O` 脚本到 scripts/ 下）：

```bash
# 环境一键检测
bash scripts/check_env.sh
# 常见问题快速诊断（✗ 项即问题点）
bash scripts/quick_troubleshoot.sh
```

| 现象 / 报错 | 优先排查 | 手册章节 |
| --- | --- | --- |
| `npu-smi: command not found` | 驱动未装 / PATH | [固件驱动](/setup/firmware-driver) |
| `driver not initialized` | 驱动 vs 内核 / 是否重启 | [环境搭建类](/faq/setup-issues) |
| `import torch_npu` 失败 | torch 与 torch_npu 配套 | [torch_npu 安装](/setup/torch-npu-install) |
| CANN `set_env.sh` 找不到 | 路径 `ascend-toolkit` vs `ascend_toolkit` | [CANN 安装](/setup/cann-install) |
| 推理 OOM / 起不来 | batch / seq / KV 显存 | [推理类问题](/faq/inference-issues) |
| loss NaN / 精度不对 | 混合精度 / 种子 | [性能与精度](/faq/perf-precision-issues) |

> 完整报错映射见 [ascend-assistant references/troubleshooting-map.md](https://github.com/RevolutionLA/ascend-assistant/blob/master/references/troubleshooting-map.md)。

## 如何贡献 / 反馈

- 想加能力、改进排障规则？去 [ascend-assistant 仓库](https://github.com/RevolutionLA/ascend-assistant) 提 Issue / PR。
- 想给手册补充教程？看本仓库的 [贡献指南](/contributing/)。

> [!NOTE]
> 本 Skill 基于公开资料整理，命令与版本以官方发布为准；涉及驱动升级、重装等高风险操作请谨慎并自行确认环境。
