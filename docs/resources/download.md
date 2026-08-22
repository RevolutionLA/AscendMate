# 镜像与软件下载

> 集中收集 **CANN / 驱动 / 固件 / Docker 镜像**等软件资源下载入口。

## 一、软件包下载

| 资源 | 说明 | 链接 |
| --- | --- | --- |
| **资源下载中心** | CANN、固件、驱动等软件包下载 | [打开](https://www.hiascend.com/developer/download) |
| 社区版 CANN 下载 | CANN 社区版下载（含 Toolkit/Kernels） | [打开](https://www.hiascend.com/developer/download) |

## 二、镜像资源

| 资源 | 说明 | 链接 |
| --- | --- | --- |
| **AscendHub** | 昇腾软件 Docker 镜像 | [打开](https://www.hiascend.com/developer/ascendhub) |
| LLaMA-Factory NPU 镜像 | 微调镜像（npu-a2 / npu-a3） | [Docker Hub](https://hub.docker.com/r/hiyouga/llamafactory) |

## 三、离线部署提示

隔离内网环境下，需要**提前下载**好下面几类东西，再导入内网：

1. Docker 镜像：`docker pull` → `docker save` → 内网 `docker load`。
2. CANN/驱动 run 包：在联网机下载 → 内网 `--install`。
3. pip 依赖：`pip download` → 内网离线安装。

📖 完整步骤见 [Docker 镜像与离线部署](/setup/docker-offline)。

## 四、配套查询

- 操作系统兼容性：<https://www.hiascend.com/hardware/compatibility>
- 模型支持查询：<https://www.hiascend.com/developer/models>

> [!NOTE]
> 请始终选择与你的**硬件型号 + 操作系统 + 目标框架版本**配套的包。这是昇腾最容易踩坑的地方。
