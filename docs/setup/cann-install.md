# 04 CANN 安装

> **什么时候读**：驱动已识别设备后，安装昇腾算力使能平台 CANN。

CANN（Compute Architecture for Neural Networks）是昇腾的核心算力栈，提供 **AscendCL**（应用编程接口）、**AscendC**（算子编程）、**HCCL**（集合通信）等能力。绝大多数框架（torch_npu、MindSpore）和推理引擎都依赖它。

## 一、选择版本

- **社区版**：免费，更新快，适合开发与学习，本仓库默认示例用社区版。
- **商用版**：商业发布，稳定性好，适合生产交付，需按授权获取。

下载页：<https://www.hiascend.com/developer/download>

CANN 版本示例：8.2.RC1 / 8.3.RC2 / 8.5.0 等。**要与你选定的 torch_npu / MindSpore 版本配套**（见各框架页）。

## 二、安装前确认

```bash
# 确认驱动 OK
npu-smi info

# 确认架构与 OS
uname -m

# 已安装 CANN 目录（若曾装过需先卸载干净）
ls /usr/local/Ascend 2>/dev/null
```

## 三、安装 CANN Toolkit（run 包方式）

下载得到 `Ascend-cann-toolkit_<版本>_linux-<arch>.run`，执行：

```bash
chmod +x Ascend-cann-toolkit_<版本>_linux-<arch>.run
sudo ./Ascend-cann-toolkit_<版本>_linux-<arch>.run --install
```

默认安装到 `/usr/local/Ascend/ascend-toolkit`。

## 四、安装 CANN Kernels（算子包）

部分场景（算子开发、部分训练）还要求安装配套 **Kernels** 包：

```bash
chmod +x Ascend-cann-kernels_<版本>_linux-<arch>.run
sudo ./Ascend-cann-kernels_<版本>_linux-<arch>.run --install
```

> [!TIP]
> 具体需要装哪些子包（Toolkit / Kernels / nnl 等），以你使用的框架（torch_npu / MindSpore）安装文档的要求为准。最小可用通常 = Toolkit。

## 五、配置环境变量

每次使用前需 source 环境变量，或写入 `~/.bashrc`：

```bash
source /usr/local/Ascend/ascend-toolkit/set_env.sh

# 常用变量
export ASCEND_HOME=/usr/local/Ascend/ascend-toolkit/latest
export ASCEND_TOOLKIT_HOME=$ASCEND_HOME
```

## 六、验证 CANN

```bash
# 查看 CANN 版本
cat /usr/local/Ascend/ascend-toolkit/latest/version.cfg
# 或
ascend-toolkit --version 2>/dev/null

# 确认关键库存在
ls /usr/local/Ascend/ascend-toolkit/latest/*/lib64 2>/dev/null | head
```

## 七、pip 方式的补充

若你不需要完整命令行工具，只想让 torch_npu 等能跑，可只安装 CANN 提供的 Python 侧依赖（`te topi hccl` 等会由框架安装过程处理），但仍建议按上面完整安装 Toolkit 最稳妥。

> [!NOTE]关于 `pip uninstall te topi hccl`
> 如果之前手动装过 CANN 提供的 python 包（te/topi/hccl），请在安装框架前先 `pip uninstall te topi hccl`，避免版本冲突。详见各框架页。

## 验证

`version.cfg` 存在且 `npu-smi` 正常 → 进入 [05 PyTorch + torch_npu 安装](/setup/torch-npu-install) 或 [06 MindSpore 安装](/setup/mindspore-install)。
