# 如何选择使用路径

> 按**你现在的角色**和**你想达到的目标**，对号入座，直接跳到对应章节。

## 按角色选择

| 你的角色 | 常见诉求 | 直接看这里 |
| --- | --- | --- |
| **采购 / 项目决策者** | 昇腾能做什么？硬件怎么选？生态成不成熟？ | [昇腾全景](/guide/ascend-landscape) · [硬件产品全景](/hardware/) · [资源导航](/resources/) |
| **环境交付工程师** | 服务器买回来，从装系统到能跑通环境 | [从零到上手：7 步走](/guide/seven-steps) · [环境搭建总览](/setup/) |
| **算法 / 模型工程师** | 在昇腾上微调、训练、部署模型 | [训练全景](/training/) · [推理全景](/inference/) · [模型迁移](/training/pytorch-migration) |
| **算子开发工程师** | 写自定义算子、迁移 GPU 算子 | [算子开发全景](/ops/) |
| **运维 / 调优工程师** | 报错排查、性能优化、精度对齐 | [问题定位 FAQ](/faq/) · [工具链](/tools/) |
| **集成 / 部署伙伴** | 把昇腾集成到自己的产品或平台 | [Dify 平台部署](/inference/dify) · [Docker 离线部署](/setup/docker-offline) |

## 按目标场景选择

你要做的，通常属于下面几类之一。点进去就能看到完整路径：

::: tip 场景一：我要在昇腾上跑大模型微调
路径：环境搭建 → LLaMA-Factory / MindSpeed → 推理上线
入口：[环境搭建总览](/setup/) → [LLaMA-Factory 微调实操](/training/llama-factory)
:::

::: tip 场景二：我要把 GPU 上训练/推理的模型迁到昇腾
路径：PyTorch 迁移 → torch_npu → 训/推
入口：[PyTorch 模型迁移](/training/pytorch-migration) → [推理全景](/inference/)
:::

::: tip 场景三：我要把训练好的模型做成推理服务
路径：MindIE / vLLM-Ascend / SGLang → 服务化
入口：[MindIE 服务化拉起](/inference/mindie) · [vLLM-Ascend 部署](/inference/vllm-ascend)
:::

::: tip 场景四：我要给客户交付一整台智算服务器
路径：上电 → 系统 → 驱动 → CANN → 框架 → 业务 → 自检
入口：[从零到上手：7 步走](/guide/seven-steps)
:::

::: tip 场景五：我要写昇腾自定义算子
路径：Ascend C / Triton-Ascend → 调试调优
入口：[算子开发全景](/ops/)
:::

## 不知道自己属于哪种？

如果你刚接触昇腾，还不清楚自己要走哪条路，**从 [从零到上手：7 步走](/guide/seven-steps) 开始**是最稳妥的选择。它会带你走完最通用的完整链路，让你对昇腾有一个整体认识。

> [!NOTE]
> 每个分类页都有一句话"什么时候读这节"，帮你判断是否需要这一节的内容。

## 关键词速查

| 你想找 | 去哪个页面 |
| --- | --- |
| npu-smi、查看设备 | [环境自检清单](/setup/checklist) |
| torch_npu 怎么装 | [PyTorch + torch_npu 安装](/setup/torch-npu-install) |
| 报 "driver not initialized" | [环境搭建类问题](/faq/setup-issues) |
| 怎么跑 DeepSeek / Qwen | [LLaMA-Factory 微调实操](/training/llama-factory) |
| CANN 装哪个版本 | [CANN 安装](/setup/cann-install) |
| 推理太慢/显存爆了 | [性能与精度问题](/faq/perf-precision-issues) |
| 模型和镜像去哪下 | [资源导航总表](/resources/links) |
