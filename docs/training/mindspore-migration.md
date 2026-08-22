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

## 四、迁移代码要点（对照示例）

> 以下要点汇总自 MindSpore 官方迁移教程，反映 PyTorch → MindSpore 的核心改写模式。

### 4.1 迁移前的模型分析

迁移前先判断哪些代码可复用、哪些必须改。通常只有**与硬件/框架相关的部分**需要改：

- 必须迁移：模型输入（数据加载、参数加载）、模型构建与执行、模型输出（参数保存）。
- 可直接复用：Numpy、OpenCV 等 CPU 计算的三方库，以及 Configuration、Tokenizer 等纯 Python 操作。

### 4.2 数据加载：GeneratorDataset

用 `mindspore.dataset.GeneratorDataset` 包装一个 Python 迭代器即可对接训练。**必须传 `column_names`**。

```python
import numpy as np
from mindspore import dataset as ds

class MyDataset:
    def __init__(self):
        self.data = np.random.sample((5, 2))
        self.label = np.random.sample((5, 1))
    def __getitem__(self, index):
        return self.data[index], self.label[index]
    def __len__(self):
        return len(self.data)

dataset = ds.GeneratorDataset(source=MyDataset(), column_names=["data", "label"],
                              shuffle=True, num_shards=1, shard_id=0)
train_dataset = dataset.batch(batch_size=2, drop_remainder=True)
```

与 PyTorch `DataLoader` 的差别：

- `GeneratorDataset` 必须传入 `column_names`。
- 数据增强输入的是 **numpy 数组**（PyTorch 是 Tensor），且不能用 MindSpore 的 mint/ops/nn 算子做数据处理。
- `batch` 是独立方法（PyTorch 中 `batch` 是 `DataLoader` 属性）。

### 4.3 模型构建：Cell

MindSpore 用 `nn.Cell` 子类，`__init__` 声明子模块，`construct` 里计算，对应 PyTorch 的 `forward`。

```python
from mindspore import mint, nn

class Network(nn.Cell):
    def __init__(self, forward_net):
        super(Network, self).__init__()
        self.net = forward_net
    def construct(self, x):
        return mint.nn.functional.relu(self.net(x))

inner_net = mint.nn.Conv2d(120, 240, kernel_size=4, bias=False)
net = Network(inner_net)
for p in net.get_parameters():
    print(p)
```

### 4.4 权重的保存与加载

> PyTorch：`state_dict()` / `load_state_dict()`；MindSpore：`ms.save_checkpoint()` / `ms.load_checkpoint()`。

```python
# MindSpore
import mindspore as ms
ms.save_checkpoint(model, save_path)
param_dict = ms.load_checkpoint(save_path)
model.load_state_dict(param_dict)
```

### 4.5 优化器执行差异

PyTorch 每步需 `optimizer.zero_grad()` → `loss.backward()` → `optimizer.step()`；MindSpore 用 `ms.value_and_grad` 得到梯度和损失，再直接 `optimizer(grads)`，学习率更新在优化器内自动执行。

```python
lr = nn.exponential_decay_lr(0.01, decay_rate, total_step, step_per_epoch, decay_epoch)
optimizer = nn.SGD(model.trainable_params(), learning_rate=lr, momentum=0.9)
grad_fn = ms.value_and_grad(forward_fn, None, optimizer.parameters, has_aux=True)
(loss, _), grads = grad_fn(data, label)
optimizer(grads)   # 更新权重（含自动学习率调整）
```

### 4.6 自动微分

MindSpore 用 `value_and_grad(forward_fn, ...)` 生成「同时返回 loss 和梯度」的图；构建反向图的逻辑与 PyTorch 不同，接口设计也不同。完整 Trainer 示例见官方迁移教程。

## 五、官方迁移教程

- **MindSpore 模型迁移教程**（与 PyTorch 代码差异）：
  [官方教程](https://www.mindspore.cn/tutorials/zh-CN/r2.8.0/model_migration/model_migration.html)

## 六、何时选 MindSpore 而非 PyTorch

- 项目**深度依赖 MindSpore**（或客户指定）。
- 偏静态图/高性能部署场景。
- 想与昇腾做更深协同。

对生态和工具更依赖的场景，通常仍推荐 **PyTorch + torch_npu**（见 [PyTorch 模型迁移](/training/pytorch-migration)）。

> [!TIP]
> 大多数新项目在昇腾上直接用 **torch_npu** 更省事。只有在明确要用 MindSpore 时才走这条迁移路径。

## 相关

- 环境：[MindSpore 安装](/setup/mindspore-install)
- [训练全景](/training/)
