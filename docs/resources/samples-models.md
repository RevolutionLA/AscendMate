# 样例代码与模型

> 收集昇腾相关的**样例代码仓**与**模型资源**，方便你找参考实现和可用权重。

## 一、样例代码

| 仓库 | 内容 | 链接 |
| --- | --- | --- |
| **samples** | 昇腾官方样例仓（AscendCL 推理应用开发与部署等场景） | [Gitee](https://gitee.com/ascend/samples/tree/master) |
| **ModelZoo-PyTorch** | 昇腾开源 AI 模型平台，涵盖 LLM/CV 等模型与实操案例 | [GitCode](https://gitcode.com/ascend/ModelZoo-PyTorch) |
| AICC | 成都智算中心代码仓（910A 适配情况） | [Gitee](https://gitee.com/Chengdu_Ascend/AICC) |
| AISBench | 基于 OpenCompass 的模型评测工具 | [Gitee](https://gitee.com/aisbench/benchmark/tree/master) |

## 二、ModelZoo 分区速查

ModelZoo-PyTorch 内通常按用途分区：

| 目录 | 用途 |
| --- | --- |
| `PyTorch` | PyTorch 模型训练源码（基于昇腾） |
| `ACL_PyTorch` | PyTorch 模型推理（ACL）参考 |
| `MindIE` | MindIE 推理引擎模型参考 |

## 三、模型权重 / 社区

| 资源 | 说明 | 链接 |
| --- | --- | --- |
| **魔乐社区** | 昇腾适配的模型权重下载社区 | [打开](https://modelers.cn/models?page=1&size=16&hardwares=NPU) |
| 模型查询助手 | 查询昇腾支持的模型 | [打开](https://www.hiascend.com/developer/models) |

> [!TIP]
> 找参考实现先看 samples / ModelZoo；找现成权重去魔乐社区或魔搭/ HuggingFace（注意昇腾适配标注）。
