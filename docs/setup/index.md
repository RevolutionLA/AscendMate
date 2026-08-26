# 环境搭建总览

> **什么时候读**：你刚拿到一台昇腾智算服务器，需要从裸机交付到可用的业务环境。

环境搭建是昇腾落地的**第一道坎**，也是客户抱怨最多的环节之一。本仓库把整个流程拆成有序的步骤，并在每一步中都给出**为什么这么做**和**怎么验证**。

## 推荐的装机顺序

```text
上电与规划 → 操作系统 → 固件与驱动 → CANN → AI框架 → 业务接入 → 自检
```

| 步骤 | 内容 | 难度 | 关键产出 |
| --- | --- | --- | --- |
| [01 服务器上电与规划](https://revolutionla.github.io/AscendMate/setup/server-onboarding) | 硬件识别、版本配套规划 | ★ | 版本配套表 |
| [02 操作系统选择与安装](https://revolutionla.github.io/AscendMate/setup/os-install) | 选 OS、装系统（openEuler 例） | ★★ | 可用系统 |
| [03 固件与驱动安装](https://revolutionla.github.io/AscendMate/setup/firmware-driver) | Firmware + Driver | ★★ | npu-smi 可识别设备 |
| [04 CANN 安装](https://revolutionla.github.io/AscendMate/setup/cann-install) | CANN Toolkit + Kernels | ★★ | 算力使能 |
| [05 PyTorch + torch_npu 安装](https://revolutionla.github.io/AscendMate/setup/torch-npu-install) | 主流 AI 框架 | ★★ | 可跑 torch |
| [06 MindSpore 安装](https://revolutionla.github.io/AscendMate/setup/mindspore-install) | 自研框架 | ★★ | 可跑 mindspore |
| [07 Docker 镜像与离线部署](https://revolutionla.github.io/AscendMate/setup/docker-offline) | 容器化、离线包 | ★★ | 一键可用环境 |
| [08 环境自检清单](https://revolutionla.github.io/AscendMate/setup/checklist) | 全链路验证 | ★ | 通过的环境 |

## 版本配套是第一关键

昇腾版本「配套」关系很强，**CANN 版本 × AI 框架版本 × 驱动固件版本 × 操作系统**需要互相匹配。装不上、跑不起来，八成是版本不配套。

- 官方兼容性查询：<https://www.hiascend.com/hardware/compatibility>
- CANN 软件下载：<https://www.hiascend.com/developer/download>
- 各组件配套表会在对应步骤中给出（如 [CANN](https://revolutionla.github.io/AscendMate/setup/cann-install)、[torch_npu](https://revolutionla.github.io/AscendMate/setup/torch-npu-install)）

> [!WARNING]
> **不要在没查配套表的情况下乱装版本。** 装驱动前先确认固件和驱动配套；装 CANN 前确认驱动已 OK；装框架前确认 CANN 已 OK。

## 云端/测试环境提示

如果你暂时没有裸机，或想快速体验，可以：

- 使用官方 **Docker 镜像**（AscendHub），见 [Docker](https://revolutionla.github.io/AscendMate/setup/docker-offline)。
- 使用昇腾**开发者云/ModelArts** 等云服务快速起验证环境。

## 下一步

- 没看过总体流程？先看 [从零到上手：7 步走](https://revolutionla.github.io/AscendMate/guide/seven-steps)。
- 直接开始？→ [01 服务器上电与规划](https://revolutionla.github.io/AscendMate/setup/server-onboarding)
