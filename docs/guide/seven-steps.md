# 从零到上手：7 步走

> 面向**环境交付工程师**和**第一次使用昇腾智算服务器**的同学。
> 照着这 7 步走完，你就能在这台机器上跑起你的第一行 PyTorch / MindSpore，并拥有一个可用的业务环境。

```mermaid
flowchart LR
    A[第1步 上电与规划] --> B[第2步 操作系统]
    B --> C[第3步 固件与驱动]
    C --> D[第4步 CANN]
    D --> E[第5步 AI框架]
    E --> F[第6步 业务接入]
    F --> G[第7步 自检]
```

## 第 1 步：服务器上电与环境规划

- 确认硬件型号（区分 A2 / A3 系列、服务器 vs 板卡），记录配置。
- 规划操作系统、CANN 版本、AI 框架版本的**配套组合**。
- 准备好带外管理（BMC/iBMC）、电源、网线、存储。

👉 [01 服务器上电与规划](https://revolutionla.github.io/AscendMate/setup/server-onboarding)

## 第 2 步：安装操作系统

- 昇腾支持的 OS 范围以 [官方兼容性查询](https://www.hiascend.com/hardware/compatibility) 为准。
- 本仓库默认以 **openEuler 24.03 LTS SP1（Arm）** 为例，给出完整安装步骤。

👉 [02 操作系统选择与安装](https://revolutionla.github.io/AscendMate/setup/os-install)

## 第 3 步：安装固件与驱动

- 固件（Firmware）与驱动（Driver）是让 NPU 被系统识别的基础。
- 安装后用 `npu-smi info` 验证是否识别到设备。

👉 [03 固件与驱动安装](https://revolutionla.github.io/AscendMate/setup/firmware-driver)

## 第 4 步：安装 CANN

- CANN（异构计算架构）是昇腾上层的算力使能平台。
- 选择**社区版 / 商用版**中合适的一个，并装上配套 kernels。

👉 [04 CANN 安装](https://revolutionla.github.io/AscendMate/setup/cann-install)

## 第 5 步：安装 AI 框架

- **PyTorch + torch_npu**：最主流，生态最全，推荐首选。
- **MindSpore**：开源框架，与昇腾深度协同。

👉 [05 PyTorch + torch_npu 安装](https://revolutionla.github.io/AscendMate/setup/torch-npu-install) · [06 MindSpore 安装](https://revolutionla.github.io/AscendMate/setup/mindspore-install)

## 第 6 步：接入业务

- 跑起一个**验证脚本**确认环境 OK。
- 然后根据你的目标进入 [训练](https://revolutionla.github.io/AscendMate/training/) 或 [推理](https://revolutionla.github.io/AscendMate/inference/)。

## 第 7 步：环境自检

- 用一份**自检清单**逐项确认：设备识别、驱动状态、框架可用性、性能基线。

👉 [08 环境自检清单](https://revolutionla.github.io/AscendMate/setup/checklist)

---

## 一条命令环境自检（快速）

```bash
# 1. 查看 NPU 设备
npu-smi info

# 2. 确认 CANN 环境变量
echo $ASCEND_HOME

# 3. PyTorch + torch_npu 是否能调用
python -c "import torch; import torch_npu; print('NPU count:', torch.npu.device_count())"

# 4. MindSpore 是否能调用
python -c "import mindspore; mindspore.set_device('Ascend'); mindspore.run_check()"
```

> [!TIP]
> 想跳过繁琐手动安装？很多场景可以直接用官方 **Docker 镜像**，一步拿到可用环境，见 [Docker 镜像与离线部署](https://revolutionla.github.io/AscendMate/setup/docker-offline)。
