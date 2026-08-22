# MindSpore 模型迁移

> **什么时候读**：你把已有的模型（尤其是基于 PyTorch/其他框架）迁移到 **MindSpore** 框架上训练/推理。

若你选择 MindSpore，需要了解它与 PyTorch 的代码差异，以及数据/模型/训练流程的迁移方法。

## 一、MindSpore 与 PyTorch 主要差异

| 方面 | PyTorch | MindSpore |
| --- | --- | --- |
| 张量定义 | `torch.Tensor` | `mindspore.Tensor` |
| 模块 | `torch.nn.Module` | `mindspore.nn.Cell` |
| 自动求导 | 动态图（默认） | 动态图/静态图，`@ms.jit` |
| 训练循环 | 手动写 | `model.train()` 或手动 `Cell` |
| 优化器 | `torch.optim` | `mindspore.nn.Optimizer` |
| 设备 | `cuda` | `Ascend` |

## 二、迁移方法框架

MindSpore 官方提供**自动/半自动迁移**(API 映射对照)，核心思路：

1. 把 `torch.*` 调用按**算子映射表**替换为 `mindspore.*`。
2. 处理数据加载（`Dataset`）方式差异。
3. 把训练/推理流程改为 MindSpore `Model` / `Cell` 写法。
4. 用 `ms.set_device('Ascend')` 指定设备。

## 三、快速上手差异点

```python
import mindspore as ms
from mindspore import nn, ops

# 设备
ms.set_device('Ascend')

# 定义网络
class Net(nn.Cell):
    def __init__(self):
        super().__init__()
        self.fc = nn.Dense(10, 10)
    def construct(self, x):
        return self.fc(x)
```

## 四、官方迁移教程

- **MindSpore 模型迁移教程**（与 PyTorch 代码差异）：
  [官方教程](https://www.mindspore.cn/tutorials/zh-CN/r2.8.0/model_migration/model_migration.html)

## 五、何时选 MindSpore 而非 PyTorch

- 项目**深度依赖 MindSpore**（或客户指定）。
- 偏静态图/高性能部署场景。
- 想与昇腾做更深协同。

对生态和工具更依赖的场景，通常仍推荐 **PyTorch + torch_npu**（见 [PyTorch 模型迁移](/training/pytorch-migration)）。

> [!TIP]
> 大多数新项目在昇腾上直接用 **torch_npu** 更省事。只有在明确要用 MindSpore 时才走这条迁移路径。

## 相关

- 环境：[MindSpore 安装](/setup/mindspore-install)
- [训练全景](/training/)
