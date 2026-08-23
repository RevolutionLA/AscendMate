# 完整链接导航表

> 昇腾之家（AscendMate）取材自《昇腾部署易用一指禅》整理出的**完整资源链接总表**。按板块分组，点击直达。

## 一、环境搭建

| 名称 | 简介 | 链接 |
| --- | --- | --- |
| 兼容性查询 | 查询当前设备兼容的操作系统 | [打开](https://www.hiascend.com/hardware/compatibility) |
| 系统安装指南 | openEuler 24.03 为例的操作系统安装 | [打开](https://support.huawei.com/enterprise/zh/doc/EDOC1100492838/426cffd9?idPath=23710424\|251366513\|254884019\|261408772\|261457531) |
| 固件驱动安装指南 | 固件+驱动安装 | [打开](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/softwareinst/instg/instg_0005.html?Mode=PmIns&InstallType=netconda&OS=openEuler) |
| CANN 安装指南 | 异构计算架构 CANN 安装 | [打开](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/softwareinst/instg/instg_0093.html?Mode=PmIns&InstallType=netconda&OS=openEuler) |
| PyTorch + torch_npu 安装 | torch_npu 二进制安装指南 | [打开](https://www.hiascend.com/document/detail/zh/Pytorch/730/configandinstg/instg/docs/zh/installation_guide/installation_via_binary_package.md) |
| MindSpore 安装指南 | MindSpore 官方安装 | [打开](https://www.mindspore.cn/install) |

📖 实操见 [环境搭建总览](/setup/)

## 二、昇腾硬件

| 产品 | 简介 | 链接 |
| --- | --- | --- |
| Atlas 900 A3 SuperPoD | 超节点文档：快速入门、安装部署 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-900-a3-superpod-pid-261207247) |
| Atlas 900 A2 PoD | 集群基础单元文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-900-a2-pod-pid-254184911) |
| Atlas 800T A2 训练服务器 | 训练服务器文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800t-a2-pid-254184887) |
| Atlas 800I A2 推理服务器 | 推理服务器文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800i-a2-pid-261457531) |
| Atlas 800I A3 推理服务器 | 推理服务器（A3）文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-800i-a3-pid-264117745) |
| Atlas 300I Pro | 推理卡文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300i-pro-pid-251052354) |
| Atlas 300V Pro | 推理卡文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300v-pro-pid-253542321) |
| Atlas 300I Duo | 推理卡（双芯）文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300i-duo-pid-252823107) |
| Atlas 300I A2 | 推理卡文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/a300i-a2-pid-260323393) |
| Atlas 200I DK A2 | 开发套件文档 | [打开](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-200i-dk-a2-pid-254412173) |

📖 硬件形态梳理见 [硬件产品全景](/hardware/)

## 三、算子开发（CANN 硬件使能）

| 名称 | 简介 | 链接 |
| --- | --- | --- |
| Ascend C 算子开发 | 入门教程、编程指南、算子实践 | [打开](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/opdevg/Ascendcopdevg/atlas_ascendc_map_10_0002.html) |
| Triton 算子开发 | 基于 Triton 的开发/迁移/调试 | [GitCode](https://gitcode.com/Ascend/triton-ascend) |
| catlass | catlass 环境安装、样例编译 | [GitCode](https://gitcode.com/cann/catlass/blob/master/docs/quickstart.md) |

📖 实操见 [算子开发全景](/ops/)

## 四、模型与镜像

| 名称 | 简介 | 链接 |
| --- | --- | --- |
| AscendHub 镜像仓库 | 昇腾软件 Docker 镜像 | [打开](https://www.hiascend.com/developer/ascendhub) |
| 魔乐社区（Modelers） | 昇腾适配模型权重下载社区 | [打开](https://modelers.cn/models?page=1&size=16&hardwares=NPU) |
| 模型查询助手 | 查询昇腾支持的模型 | [打开](https://www.hiascend.com/developer/models) |

## 五、训练相关

| 名称 | 简介 | 链接 |
| --- | --- | --- |
| PyTorch 模型训练源码 | 基于昇腾的训练模型参考 | [打开](https://gitcode.com/ascend/ModelZoo-PyTorch/tree/master/PyTorch) |
| PyTorch 模型迁移 | GPU→NPU 训练迁移指南 | [打开](https://www.hiascend.com/document/detail/zh/Pytorch/730/ptmoddevg/trainingmigrguide/PT_LMTMOG_0013.html) |
| MindSpore 模型迁移适配 | MindSpore 与 PyTorch 差异 / 迁移 | [打开](https://www.mindspore.cn/tutorials/zh-CN/r2.8.0/model_migration/model_migration.html) |
| MindSpeed | 基于昇腾的大模型加速库 | [GitCode](https://gitcode.com/Ascend/MindSpeed) |
| LLaMA-Factory | 大模型微调框架（支持 NPU） | [GitHub](https://github.com/hiyouga/LlamaFactory/blob/main/README_zh.md) |

📖 实操见 [训练全景](/training/)

## 六、推理相关

| 名称 | 简介 | 链接 |
| --- | --- | --- |
| PyTorch 模型推理源码 | 基于昇腾的 ACL 推理参考 | [打开](https://gitcode.com/Ascend/ModelZoo-PyTorch/tree/master/ACL_PyTorch) |
| MindIE 推理引擎参考 | 基于昇腾的推理引擎模型参考 | [打开](https://gitcode.com/Ascend/ModelZoo-PyTorch/tree/master/MindIE) |
| MindIE（自研推理套件） | 昇腾 AI 全场景推理加速套件 | [官方文档](https://www.hiascend.com/document/detail/zh/mindie/230/index/index.html) |
| vLLM-Ascend | 使 vLLM 在昇腾运行的官方插件 | [快速开始](https://docs.vllm.ai/projects/ascend/zh-cn/latest/quick_start.html) |
| SGLang-Kernel-NPU | SGLang 在昇腾的官方内核库 | [GitHub](https://github.com/sgl-project/sgl-kernel-npu) |

📖 实操见 [推理全景](/inference/)

## 七、工具链

| 名称 | 简介 | 链接 |
| --- | --- | --- |
| MindStudio | 全流程开发工具集 | [官方文档](https://www.hiascend.com/document/detail/zh/mindstudio/830/index/index.html) |
| 精度调试工具 | 对比昇腾算子与标杆算子结果 | [官方文档](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/devaids/ModelAccuracyAnalyzer/atlasaccuracy_16_1000.html) |
| Profiling 工具 | 分析各阶段性能指标 | [官方文档](https://www.hiascend.com/document/detail/zh/CANNCommunityEdition/850/devaids/Profiling/atlasprofiling_16_0001.html) |

📖 实操见 [工具链全景](/tools/)

## 八、其他 / 常用

| 名称 | 简介 | 链接 |
| --- | --- | --- |
| samples | 昇腾样例仓（AscendCL 等） | [Gitee](https://gitee.com/ascend/samples/tree/master) |
| ModelZoo | 昇腾开源 AI 模型平台 | [GitCode](https://gitcode.com/ascend/ModelZoo-PyTorch) |
| AISBench | 基于 OpenCompass 的模型评测工具 | [Gitee](https://gitee.com/aisbench/benchmark/tree/master) |
| AICC | 成都智算中心代码仓（910A 适配） | [Gitee](https://gitee.com/Chengdu_Ascend/AICC) |
| 资源下载 | CANN / 驱动 / 固件等软件下载 | [打开](https://www.hiascend.com/developer/download) |

> [!NOTE]在线/离线
> 表中部分资源在线版可直接使用；离线版需在服务器/可联网机器上提前下载，见 [Docker 镜像与离线部署](/setup/docker-offline)。
