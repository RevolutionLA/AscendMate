# 06 MindSpore 安装

> **什么时候读**：你选择使用开源框架 MindSpore，或在昇腾上做 MindSpore 相关开发。

MindSpore 是开源 AI 框架，与昇腾深度协同，支持开箱即用。若你的项目基于 MindSpore，本页给出 pip 安装步骤。

## 一、版本配套

| 组件 | 版本要求 |
| --- | --- |
| 操作系统 | Debian 系列 / openEuler 系列（Ubuntu、Kylin、UOS 等） |
| Python | 3.9 – 3.12 |
| CANN | 8.5.0 / 8.3.RC1 / 8.2.RC1 等（视 MindSpore 版本） |
| GCC | 7.3.0 及以上（源码编译需要） |

## 二、安装依赖软件

### 1. Python 环境（推荐 conda）

```bash
conda create -n mindspore python=3.9.11 -y
conda activate mindspore
python -m pip install -U pip
```

### 2. 处理 CANN 已有 python 包冲突

若之前装过 CANN 提供的 `te topi hccl`，先卸载：

```bash
pip uninstall te topi hccl -y
pip install sympy protobuf attrs cloudpickle decorator ml-dtypes psutil scipy tornado jinja2
```

### 3. 安装 GCC

```bash
# openEuler / EulerOS
sudo yum install gcc -y

# Ubuntu
sudo apt-get install gcc-7 -y

# CentOS 7（切换到 devtoolset-7）
# sudo yum install centos-release-scl devtoolset-7
```

## 三、安装 MindSpore

指定想装的版本（示例 2.8.0）：

```bash
export MS_VERSION=2.8.0
pip install mindspore==${MS_VERSION} \
  -i https://repo.mindspore.cn/pypi/simple --trusted-host repo.mindspore.cn \
  --extra-index-url https://repo.huaweicloud.com/repository/pypi/simple/
```

如未安装到默认路径，安装后配置环境变量：

```bash
# 若 CANN 不在默认路径，需手动加载
LOCAL_ASCEND=/usr/local/Ascend
source ${LOCAL_ASCEND}/cann/set_env.sh
```

## 四、验证安装

**方法一（推荐）**：

```bash
python -c "import mindspore; mindspore.set_device('Ascend'); mindspore.run_check()"
```

输出如下即成功：

```text
MindSpore version: ...
The result of multiplication calculation is correct, MindSpore has been installed on platform [Ascend] successfully!
```

**方法二**：跑一段张量运算：

```python
import numpy as np
import mindspore as ms
import mindspore.ops as ops

ms.set_device("Ascend")
x = ms.Tensor(np.ones([1,3,3,4]).astype(np.float32))
y = ms.Tensor(np.ones([1,3,3,4]).astype(np.float32))
print(ops.add(x, y))
```

## 五、升级 / 从 1.x 迁移

- 从 1.x 升到 2.x：先 `pip uninstall mindspore-ascend`，再装新版本。
- 2.x 之间升级：`pip install --upgrade mindspore=={version}`。

## 六、MindSpore 模型迁移

若要把现有模型迁到 MindSpore，参考 [MindSpore 模型迁移](https://revolutionla.github.io/AscendMate/training/mindspore-migration)。

## 验证

`mindspore.run_check()` 通过 → 环境 OK。
