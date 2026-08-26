---
layout: doc
title: 深度学习入门
description: 理解神经网络的核心原理，掌握PyTorch框架基础，了解MindSpore，动手训练MNIST手写数字识别模型。
---

# 深度学习入门

> 「神经网络不是在模拟大脑，而是在用数学函数逼近任何复杂的映射关系。」

## 阶段目标

这个阶段，你将从"理解概念"走向"动手实现"。

学完这个阶段，你将能够：
- 理解神经网络的核心原理（前向传播、反向传播）
- 了解 CNN 和 RNN 两种关键网络结构
- 使用 PyTorch 搭建和训练神经网络模型
- 了解 MindSpore 框架及其与 PyTorch 的异同
- 独立完成 MNIST 手写数字识别项目

::: tip 💡 学习建议
这个阶段**实践比理论重要**。看懂原理后，立刻动手写代码。代码跑不通的时候，就是理解最深刻的时候。
:::

---

## 第一部分：神经网络基础

### 从一个神经元开始

#### 生物神经元 vs 人工神经元

```text
生物神经元：
  树突（接收信号） → 细胞体（处理） → 轴突（输出信号）
  
人工神经元：
  输入（x₁, x₂, ...） → 加权求和 + 偏置 → 激活函数 → 输出
```

#### 人工神经元的数学表示

```text
输入: x = [x₁, x₂, x₃]
权重: w = [w₁, w₂, w₃]
偏置: b

计算过程:
  加权求和: z = w₁·x₁ + w₂·x₂ + w₃·x₃ + b
  激活:    a = f(z)    （f 是激活函数）
  输出:    a
```

```python
import numpy as np

# 一个简单的神经元
def neuron(x, w, b, activation):
    z = np.dot(w, x) + b
    return activation(z)

# 示例
x = np.array([0.5, 0.8, 0.2])     # 输入
w = np.array([0.3, -0.5, 0.8])    # 权重
b = 0.1                            # 偏置
activation = lambda z: max(0, z)   # ReLU 激活函数

output = neuron(x, w, b, activation)
print(f"神经元输出: {output}")
```

### 激活函数

激活函数给神经网络引入**非线性**，让它能学习复杂的映射关系。

#### 常用激活函数

| 激活函数 | 公式 | 特点 | 使用场景 |
|:---|:---|:---|:---|
| **Sigmoid** | σ(z) = 1/(1+e⁻ᶻ) | 输出 0~1，易梯度消失 | 二分类输出层 |
| **Tanh** | tanh(z) | 输出 -1~1，零中心化 | RNN 中常用 |
| **ReLU** | max(0, z) | 计算快，缓解梯度消失 | 隐藏层默认选择 |
| **Leaky ReLU** | max(0.01z, z) | 解决 ReLU 的"死亡"问题 | 深层网络 |
| **Softmax** | e^zᵢ/Σe^zⱼ | 输出概率分布（和为1） | 多分类输出层 |
| **GELU** | 复杂 | 平滑的 ReLU | Transformer 中使用 |

```python
import numpy as np
import matplotlib.pyplot as plt

x = np.linspace(-5, 5, 200)

# 常用激活函数
sigmoid = 1 / (1 + np.exp(-x))
tanh = np.tanh(x)
relu = np.maximum(0, x)

fig, axes = plt.subplots(1, 3, figsize=(15, 4))
axes[0].plot(x, sigmoid); axes[0].set_title('Sigmoid'); axes[0].grid(True)
axes[1].plot(x, tanh); axes[1].set_title('Tanh'); axes[1].grid(True)
axes[2].plot(x, relu); axes[2].set_title('ReLU'); axes[2].grid(True)
plt.tight_layout()
plt.show()
```

::: tip 💡 为什么需要激活函数？
**没有激活函数，多层神经网络等价于单层线性模型。** 不管你堆叠多少层，线性函数的复合还是线性函数，无法学习非线性关系。激活函数打破了这种"线性诅咒"。
:::

### 前向传播

**前向传播**：数据从输入层经过各层计算到达输出的过程。

```text
一个三层神经网络：

输入层        隐藏层         输出层
(o₁, o₂)     (h₁, h₂, h₃)   (y)

  o₁ ──┐
        ├──→ h₁ ──┐
  o₂ ──┤          ├──→ y
        ├──→ h₂ ──┤
        └──→ h₃ ──┘

计算过程：
  第1层：h = f₁(W₁·x + b₁)
  第2层：y = f₂(W₂·h + b₂)
```

```python
import numpy as np

def forward(x, W1, b1, W2, b2):
    """两层神经网络的前向传播"""
    # 第一层
    z1 = np.matmul(x, W1) + b1    # 线性变换
    h = np.maximum(0, z1)          # ReLU 激活
    
    # 第二层
    z2 = np.matmul(h, W2) + b2    # 线性变换
    output = z2                    # 输出层（回归任务不加激活）
    
    return output, h  # 返回输出和隐藏层值（反向传播需要）

# 初始化参数
W1 = np.random.randn(2, 3)  # 输入2维 → 隐藏3维
b1 = np.zeros(3)
W2 = np.random.randn(3, 1)  # 隐藏3维 → 输出1维
b2 = np.zeros(1)

# 前向传播
x = np.array([[1.0, 2.0]])  # 一个样本
output, _ = forward(x, W1, b1, W2, b2)
print(f"网络输出: {output}")
```

### 反向传播

**反向传播**：从损失出发，反向逐层计算梯度的过程。

```text
前向传播（计算输出和损失）：
  x → h → y → Loss

反向传播（计算梯度）：
  Loss → ∂L/∂y → ∂L/∂h → ∂L/∂W

核心：利用链式法则逐层求导
```

```python
def backward(x, y_true, h, output, W2):
    """简化版反向传播"""
    # 输出层梯度
    dL_doutput = 2 * (output - y_true)  # MSE损失的梯度
    
    # 对 W2 的梯度
    dL_dW2 = np.matmul(h.T, dL_doutput)
    
    # 传播到隐藏层
    dL_dh = np.matmul(dL_doutput, W2.T)
    
    # ReLU 的梯度：z>0 时为1，否则为0
    dL_dz1 = dL_dh * (h > 0)
    
    # 对 W1 的梯度
    dL_dW1 = np.matmul(x.T, dL_dz1)
    
    return dL_dW1, dL_dW2
```

::: tip 💡 好消息
**在实际工作中，你几乎不需要手写反向传播。** PyTorch 的 `autograd` 会自动帮你完成。但理解原理非常重要，它帮助你：
- 调试梯度消失/爆炸问题
- 理解为什么某些技巧有效
- 阅读论文和源码
:::

### 完整训练流程

```text
┌─────────────────────────────────────────┐
│           神经网络训练流程                │
├─────────────────────────────────────────┤
│                                         │
│  1. 准备数据                             │
│     └→ 加载、预处理、分批                 │
│                                         │
│  2. 定义模型                             │
│     └→ 网络结构、激活函数                 │
│                                         │
│  3. 定义损失函数和优化器                   │
│     └→ Loss: MSE / CrossEntropy         │
│     └→ Optimizer: SGD / Adam            │
│                                         │
│  4. 训练循环（重复多个 Epoch）            │
│     ├→ 前向传播：计算预测值               │
│     ├→ 计算损失                          │
│     ├→ 反向传播：计算梯度                 │
│     └→ 更新参数：优化器步进               │
│                                         │
│  5. 评估模型                             │
│     └→ 在验证集/测试集上评估              │
│                                         │
│  6. 保存模型                             │
│                                         │
└─────────────────────────────────────────┘
```

---

## 第二部分：关键网络结构

### CNN（卷积神经网络）

CNN 是处理**图像**的利器。它利用了图像的局部特征和空间结构。

#### 核心概念

| 组件 | 说明 | 作用 |
|:---|:---|:---|
| **卷积层** | 用小窗口扫描图像提取特征 | 检测边缘、纹理、形状等局部特征 |
| **池化层** | 降采样，缩小特征图尺寸 | 减少计算量、增强平移不变性 |
| **全连接层** | 传统神经网络层 | 综合特征做最终分类 |

```text
CNN 处理图像的过程：

输入图片 → [卷积层 → 激活 → 池化层] × N → 全连接层 → 分类结果

直觉理解：
  第1层卷积：检测边缘、线条
  第2层卷积：检测角点、简单形状
  第3层卷积：检测复杂图案（眼睛、轮子等）
  最后全连接：综合判断"这是一只猫"
```

#### 为什么 CNN 比全连接网络更适合图像？

```text
全连接网络处理图片的问题：
  一张 224×224 的图片 → 展平为 50176 维向量
  第一层 1000 个神经元 → 需要 50176×1000 = 5000万 参数！
  参数太多，容易过拟合，且丢失空间信息

CNN 的优势：
  卷积核在整张图上共享参数 → 参数量大幅减少
  保留了空间结构信息
  层次化特征提取 → 从简单到复杂
```

### RNN（循环神经网络）

RNN 是处理**序列数据**（文本、语音、时间序列）的网络。

#### 核心思想

```text
RNN 的核心：有"记忆"

普通网络：
  输入 → 输出（每次独立处理）

RNN：
  输入₁ → 输出₁（同时产生隐藏状态 h₁）
  输入₂ + h₁ → 输出₂（同时产生 h₂）
  输入₃ + h₂ → 输出₃
  
  每一步的处理都"记得"之前的信息
```

#### 应用场景

| 任务 | 输入 | 输出 |
|:---|:---|:---|
| 文本分类 | 一段文本 | 类别标签 |
| 机器翻译 | 源语言序列 | 目标语言序列 |
| 语音识别 | 音频序列 | 文字序列 |
| 股票预测 | 历史价格序列 | 未来价格 |

#### RNN 的问题与改进

```text
RNN 的问题：梯度消失/爆炸，难以记住长距离依赖
  "我出生在[北京]...（中间100个字）...所以我说[?]"
  RNN 可能忘了"北京"

改进方案：
  LSTM（长短期记忆网络）：引入门控机制，选择性记忆
  GRU（门控循环单元）：LSTM的简化版

终极方案：
  Transformer（用注意力机制替代循环结构）→ 下一阶段详解
```

---

## 第三部分：PyTorch 基础

### 为什么选 PyTorch？

| 特性 | PyTorch | TensorFlow |
|:---|:---|:---|
| 动态图 | ✅ 直观易调试 | ❌ 静态图（TF2.x 已改进） |
| 社区 | 研究界主流 | 工业界广泛使用 |
| 上手难度 | 简单 | 略复杂 |
| 生态 | Hugging Face 原生支持 | 生态完善 |
| 昇腾支持 | PyTorch-NPU 适配 | 较少 |

**结论：先学 PyTorch，它是最主流、最好上手的深度学习框架。**

### 核心概念

#### 1. Tensor（张量）

Tensor 是 PyTorch 的核心数据结构，类似 NumPy 的 ndarray，但可以在 GPU/NPU 上运算。

```python
import torch

# 创建 Tensor
x = torch.tensor([1, 2, 3])
y = torch.randn(3, 4)          # 随机正态分布
z = torch.zeros(2, 3)          # 全零

# Tensor 运算（和 NumPy 几乎一样）
a = torch.randn(3, 4)
b = torch.randn(4, 5)
c = torch.matmul(a, b)         # 矩阵乘法
print(c.shape)                  # torch.Size([3, 5])

# GPU/NPU 加速
if torch.cuda.is_available():
    x = x.cuda()                # 移到 GPU
# 昇腾环境：
# x = x.npu()                   # 移到 NPU
```

#### 2. Autograd（自动求导）

PyTorch 最强大的特性之一：自动计算梯度。

```python
import torch

# 创建需要求导的 Tensor
w = torch.randn(1, requires_grad=True)
b = torch.randn(1, requires_grad=True)

# 前向计算
x = torch.tensor([1.0, 2.0, 3.0])
y_true = torch.tensor([2.0, 4.0, 6.0])

y_pred = w * x + b
loss = ((y_pred - y_true) ** 2).mean()

# 自动求导！
loss.backward()

print(f"w 的梯度: {w.grad}")  # dL/dw
print(f"b 的梯度: {b.grad}")  # dL/db
# 你不需要手写反向传播，PyTorch 自动完成
```

#### 3. nn.Module（模型定义）

`nn.Module` 是定义模型的基类。

```python
import torch
import torch.nn as nn

class SimpleNet(nn.Module):
    def __init__(self, input_size, hidden_size, num_classes):
        super(SimpleNet, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)   # 全连接层1
        self.relu = nn.ReLU()                            # 激活函数
        self.fc2 = nn.Linear(hidden_size, num_classes)   # 全连接层2
    
    def forward(self, x):
        out = self.fc1(x)      # 第一层
        out = self.relu(out)   # 激活
        out = self.fc2(out)    # 第二层
        return out

# 创建模型
model = SimpleNet(input_size=784, hidden_size=128, num_classes=10)
print(model)
```

#### 4. 训练循环模板

这是 PyTorch 训练的标准模板，记住这个框架，大部分训练任务都能套用：

```python
import torch
import torch.nn as nn
import torch.optim as optim

# 1. 准备数据和模型
model = SimpleNet(784, 128, 10)
criterion = nn.CrossEntropyLoss()              # 损失函数
optimizer = optim.Adam(model.parameters(), lr=0.001)  # 优化器

# 2. 训练循环
num_epochs = 10
for epoch in range(num_epochs):
    for batch_x, batch_y in train_loader:
        # 前向传播
        outputs = model(batch_x)
        loss = criterion(outputs, batch_y)
        
        # 反向传播 + 优化
        optimizer.zero_grad()    # 清空梯度（重要！）
        loss.backward()          # 自动计算梯度
        optimizer.step()         # 更新参数
    
    print(f"Epoch [{epoch+1}/{num_epochs}], Loss: {loss.item():.4f}")

# 3. 评估
model.eval()
with torch.no_grad():  # 评估时不需要梯度
    correct = 0
    total = 0
    for batch_x, batch_y in test_loader:
        outputs = model(batch_x)
        _, predicted = torch.max(outputs, 1)
        total += batch_y.size(0)
        correct += (predicted == batch_y).sum().item()
    print(f"测试准确率: {100 * correct / total:.2f}%")
```

::: tip 💡 关键细节
- `optimizer.zero_grad()`：每次反向传播前**必须**清空梯度，否则梯度会累积
- `model.train()` / `model.eval()`：切换训练/评估模式（影响 Dropout 和 BatchNorm）
- `torch.no_grad()`：评估时禁用梯度计算，节省内存和加速
:::

---

## 第四部分：MindSpore 简介

MindSpore 是华为自研的深度学习框架，在昇腾生态中有原生优势。

### MindSpore vs PyTorch

| 特性 | PyTorch | MindSpore |
|:---|:---|:---|
| 开发商 | Meta | 华为 |
| 计算图 | 动态图（Eager） | 静态图（Graph）为主 |
| 自动微分 | 反向模式自动微分 | 反向模式自动微分 |
| 昇腾支持 | 通过适配层（PyTorch-NPU） | 原生支持 |
| API 风格 | 面向对象 | 函数式 + 面向对象 |
| 社区 | 庞大 | 成长中 |
| 适用场景 | 研究 + 生产 | 昇腾生产环境 |

### MindSpore 代码示例

```python
import mindspore
from mindspore import nn, Tensor, Model
from mindspore.dataset import vision, transforms

# 定义模型（和 PyTorch 类似）
class SimpleNet(nn.Cell):
    def __init__(self, input_size, hidden_size, num_classes):
        super(SimpleNet, self).__init__()
        self.fc1 = nn.Dense(input_size, hidden_size)
        self.relu = nn.ReLU()
        self.fc2 = nn.Dense(hidden_size, num_classes)
    
    def construct(self, x):
        x = self.fc1(x)
        x = self.relu(x)
        x = self.fc2(x)
        return x

# 创建模型
net = SimpleNet(784, 128, 10)
loss_fn = nn.CrossEntropyLoss()
optimizer = nn.Adam(net.trainable_params(), learning_rate=0.001)

# 编译模型
model = Model(net, loss_fn, optimizer, metrics={"accuracy"})

# 训练
model.train(epoch=10, train_dataset=train_dataset)

# 评估
result = model.eval(test_dataset)
print(result)
```

### 选择建议

```text
如果你是初学者 → 先学 PyTorch（资源丰富，社区大）
如果你在昇腾上做生产 → 同时了解 MindSpore（原生优势）
如果你做研究 → PyTorch 为主
如果你在华为生态内工作 → 两个都要会
```

::: tip 💡 好消息
在昇腾上，你可以用 PyTorch（通过 PyTorch-NPU 适配），也可以用 MindSpore。**不用强迫自己只用一个**。
:::

---

## 第五部分：实战项目 — MNIST 手写数字识别

MNIST 是深度学习的"Hello World"——识别 28×28 像素的手写数字（0-9）。

### 项目概述

```text
任务：给定一张 28×28 的手写数字图片，判断它是 0-9 中的哪个数字

数据集：MNIST
  训练集：60,000 张图片
  测试集：10,000 张图片
  每张图片：28×28 像素，灰度

方法：使用全连接神经网络（也可以扩展为 CNN）
```

### 完整代码（PyTorch 版）

```python
import torch
import torch.nn as nn
import torch.optim as optim
import torchvision
import torchvision.transforms as transforms
from torch.utils.data import DataLoader

# ============================================================
# 第一步：数据准备
# ============================================================
transform = transforms.Compose([
    transforms.ToTensor(),                    # 转为 Tensor，归一化到 [0, 1]
    transforms.Normalize((0.1307,), (0.3081,)) # 标准化
])

# 下载并加载 MNIST 数据集
train_dataset = torchvision.datasets.MNIST(
    root='./data', train=True, download=True, transform=transform
)
test_dataset = torchvision.datasets.MNIST(
    root='./data', train=False, download=True, transform=transform
)

train_loader = DataLoader(train_dataset, batch_size=64, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=1000, shuffle=False)

print(f"训练集大小: {len(train_dataset)}")
print(f"测试集大小: {len(test_dataset)}")

# ============================================================
# 第二步：定义模型
# ============================================================
class MNISTNet(nn.Module):
    def __init__(self):
        super(MNISTNet, self).__init__()
        self.flatten = nn.Flatten()
        self.fc1 = nn.Linear(28 * 28, 256)    # 输入 784 → 隐藏 256
        self.relu1 = nn.ReLU()
        self.dropout = nn.Dropout(0.2)         # 防止过拟合
        self.fc2 = nn.Linear(256, 128)         # 隐藏 256 → 隐藏 128
        self.relu2 = nn.ReLU()
        self.fc3 = nn.Linear(128, 10)          # 隐藏 128 → 输出 10
    
    def forward(self, x):
        x = self.flatten(x)       # 28×28 → 784
        x = self.relu1(self.fc1(x))
        x = self.dropout(x)
        x = self.relu2(self.fc2(x))
        x = self.fc3(x)           # 输出 logits（不需要 softmax）
        return x

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = MNISTNet().to(device)
print(model)

# ============================================================
# 第三步：定义损失函数和优化器
# ============================================================
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

# ============================================================
# 第四步：训练循环
# ============================================================
num_epochs = 5

for epoch in range(num_epochs):
    model.train()
    running_loss = 0.0
    
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.to(device), target.to(device)
        
        # 前向传播
        output = model(data)
        loss = criterion(output, target)
        
        # 反向传播
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()
        
        running_loss += loss.item()
        
        if batch_idx % 200 == 0:
            print(f"Epoch {epoch+1} [{batch_idx * len(data)}/{len(train_dataset)}] "
                  f"Loss: {loss.item():.4f}")
    
    avg_loss = running_loss / len(train_loader)
    print(f"=== Epoch {epoch+1} 完成, 平均损失: {avg_loss:.4f} ===\n")

# ============================================================
# 第五步：评估模型
# ============================================================
model.eval()
correct = 0
total = 0

with torch.no_grad():
    for data, target in test_loader:
        data, target = data.to(device), target.to(device)
        output = model(data)
        _, predicted = torch.max(output, 1)
        total += target.size(0)
        correct += (predicted == target).sum().item()

accuracy = 100 * correct / total
print(f"测试集准确率: {accuracy:.2f}%")

# ============================================================
# 第六步：保存模型
# ============================================================
torch.save(model.state_dict(), 'mnist_model.pth')
print("模型已保存到 mnist_model.pth")
```

### 预期结果

```text
训练集大小: 60000
测试集大小: 10000

Epoch 1 [0/60000] Loss: 2.3026
Epoch 1 [12800/60000] Loss: 0.3521
...
=== Epoch 1 完成, 平均损失: 0.3124 ===

...
=== Epoch 5 完成, 平均损失: 0.0345 ===

测试集准确率: 97.85%
模型已保存到 mnist_model.pth
```

::: tip 🎉 恭喜！
你已经完成了第一个深度学习项目！97% 以上的准确率对于一个简单的全连接网络来说已经很不错了。如果用 CNN，可以达到 99% 以上。
:::

### 进阶挑战

完成基础版后，尝试以下改进：

1. **使用 CNN**：将全连接网络替换为卷积网络，观察准确率提升
2. **调整超参数**：尝试不同的学习率、batch size、网络结构
3. **数据增强**：使用旋转、平移等数据增强技术
4. **可视化**：绘制训练损失曲线、混淆矩阵

```python
# CNN 版本的模型定义
class MNISTCNN(nn.Module):
    def __init__(self):
        super(MNISTCNN, self).__init__()
        self.conv1 = nn.Conv2d(1, 32, 3, 1)    # 卷积层
        self.conv2 = nn.Conv2d(32, 64, 3, 1)
        self.pool = nn.MaxPool2d(2)              # 池化层
        self.dropout1 = nn.Dropout(0.25)
        self.dropout2 = nn.Dropout(0.5)
        self.fc1 = nn.Linear(9216, 128)
        self.fc2 = nn.Linear(128, 10)
    
    def forward(self, x):
        x = self.pool(torch.relu(self.conv1(x)))
        x = self.pool(torch.relu(self.conv2(x)))
        x = self.dropout1(x)
        x = torch.flatten(x, 1)
        x = torch.relu(self.fc1(x))
        x = self.dropout2(x)
        x = self.fc2(x)
        return x
```

---

## 推荐学习资源

### 教材

| 资源 | 说明 | 推荐指数 |
|:---|:---|:---:|
| 《动手学深度学习》李沐 | 理论+PyTorch代码，强烈推荐 | ★★★★★ |
| 《深度学习》（花书） | 理论经典，可作参考 | ★★★★☆ |
| 《神经网络与深度学习》邱锡鹏 | 中文，系统全面 | ★★★★★ |

### 视频课程

| 课程 | 平台 | 说明 | 推荐指数 |
|:---|:---|:---|:---:|
| 李沐《动手学深度学习》 | B站 | 免费，理论+代码 | ★★★★★ |
| 李宏毅《深度学习》 | B站/YouTube | 中文，讲解生动 | ★★★★★ |
| 吴恩达 Deep Learning | Coursera | 系统全面 | ★★★★☆ |
| Fast.ai | fast.ai | 实践导向 | ★★★★☆ |

### 实践平台

| 平台 | 说明 |
|:---|:---|
| Google Colab | 免费 GPU，适合学习实验 |
| Kaggle | 数据集 + 免费 GPU + 比赛 |
| PyTorch 官方教程 | 官方权威教程 |
| 昇腾 ModelArts | 华为云平台，有昇腾算力 |

---

## 阶段总结

### 知识点清单

完成本阶段后，确认你掌握了：

**理论**：
- [ ] 神经元、激活函数的作用
- [ ] 前向传播和反向传播的过程
- [ ] CNN 适合处理图像的原因
- [ ] RNN 适合处理序列的原因
- [ ] 梯度消失/爆炸问题

**实践**：
- [ ] PyTorch Tensor 操作
- [ ] autograd 自动求导
- [ ] nn.Module 定义模型
- [ ] 完整的训练循环
- [ ] 模型保存和加载
- [ ] 独立完成 MNIST 项目

---

## 下一步

::: tip 🚀 下一阶段
👉 [阶段四：大模型技术栈](./llm-basics) —— 学习 Transformer 和大语言模型
:::

> 「你已经学会了造砖（神经网络基础），接下来要学怎么盖摩天大楼（大模型）。原理是相通的，只是规模和结构更复杂。」
