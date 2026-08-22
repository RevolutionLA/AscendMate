# 07 Docker 镜像与离线部署

> **什么时候读**：想快速拿到可用环境，或部署在隔离内网（无外网），需要离线安装。

使用官方 **Docker 镜像**能极大简化环境搭建，也是解决"易用性"痛点的首选方式之一；若客户在隔离内网，则需要提前离线下载镜像与软件包。

## 一、AscendHub 镜像仓库

昇腾官方提供软件 Docker 镜像，把你需要的驱动/CANN/框架一键封装成镜像。

- **入口**：<https://www.hiascend.com/developer/ascendhub>

常用镜像类型：

- CANN 基础镜像（Toolkit + Kernels）
- CANN + PyTorch + torch_npu
- CANN + MindSpore
- 训练/推理套件镜像（MindSpeed、MindIE 等）

## 二、拉起镜像（在线环境示例）

```bash
# 拉取 AscendHub 镜像（示例示意，实际以仓库内镜像名/tag 为准）
docker pull quay.io/ascend/cann:8.5.0  # 示意

# 启动一个带 NPU 的容器
docker run -it \
  --rm \
  --ipc=host \
  --device /dev/davinci0 \
  --device /dev/davinci_manager \
  --device /dev/devmm_svm \
  --device /dev/hisi_hdc \
  -v /usr/local/Ascend/driver:/usr/local/Ascend/driver \
  -v /usr/local/bin/npu-smi:/usr/local/bin/npu-smi \
  -v /etc/ascend_install.info:/etc/ascend_install.info \
  <镜像名> bash
```

> [!IMPORTANT]
> 容器要访问 NPU，必须把主机的 **davinci 设备节点**和**驱动相关挂载**传进去。上面的 `--device` 项不能省。

## 三、离线场景（隔离内网）

客户机房通常无法访问外网，需要**在能联网的机器上预先下载**，再导入内网：

### 1. 提前下载 Docker 镜像

```bash
docker pull <镜像名>
docker save -o ascend_cann.tar <镜像名>
```

### 2. 拷贝到内网并加载

```bash
# 内网机器上
docker load -i ascend_cann.tar
```

### 3. 离线安装依赖包

- **pip 轮子**：在联网机器 `pip download` 需要的一揽子依赖，再离线安装。
- **CANN/驱动 run 包**：从昇腾下载站在联网机器下载，内网用 run 包本地安装。

### 4. 内网 pip 源

若内网有 pip 缓存/私有源，离线安装可显著节省时间。

```
软件/镜像下载入口汇总见 [资源导航 - 软件下载](/resources/download)。
```

## 四、LLaMA-Factory 官方 NPU 镜像（示例）

LLaMA-Factory 官方提供昇腾可用的一键镜像，适合快速做微调：

```bash
docker pull hiyouga/llamafactory:latest-npu-a2   # A2 系列
docker pull hiyouga/llamafactory:latest-npu-a3   # A3 系列
```

用法详见 [LLaMA-Factory 微调实操](/training/llama-factory)。

## 五、注意事项

- 镜像内版本与主机驱动**仍需配套**（驱动是宿主侧共享的）。
- 生产环境务必确认镜像对应的 CANN/框架版本满足你的业务要求。

## 验证

容器内能执行 `npu-smi info`（host 驱动可见）并成功 import 框架 → 容器环境 OK。接下来进入 [08 环境自检清单](/setup/checklist)。
