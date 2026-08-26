# AI 推理卡

> **什么时候读**：使用或集成 **Atlas 300I / 300V** 系列**板卡形态**推理卡。

## 一、代表产品

| 产品 | 定位 | 官方文档 |
| --- | --- | --- |
| **Atlas 300I Pro** | 推理卡（Pro 级） | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300i-pro-pid-251052354) |
| **Atlas 300V Pro** | 推理卡（V 系列） | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300v-pro-pid-253542321) |
| **Atlas 300I Duo** | 推理卡（Duo 双芯） | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-300i-duo-pid-252823107) |
| **Atlas 300I A2** | 推理卡（A2 代际） | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/a300i-a2-pid-260323393) |

> [!NOTE]
> 板卡形态通常集成到客户自有服务器/整机，或用昇腾整机。安装与适配请以该卡的**用户指南**为准。

## 二、使用场景

- 对现有 x86/Arm 服务器做**推理加速**（推理卡直插）。
- 边缘 / 专用设备中的 AI 推理。
- Duo 系列常用于特定高性能推理需求。

## 三、涉及链路

- 集成到整机后，环境搭建仍走 [7 步走](https://revolutionla.github.io/AscendMate/guide/seven-steps)。
- 想跑推理 → [推理全景](https://revolutionla.github.io/AscendMate/inference/)。
- 板卡相关的驱动/CANN 配套请查该卡用户指南与兼容性。

## 四、常见问题

- 装卡后 `npu-smi` 不识别 → [环境搭建类问题](https://revolutionla.github.io/AscendMate/faq/setup-issues)（检查物理插槽、PCIe 枚举、驱动）。
