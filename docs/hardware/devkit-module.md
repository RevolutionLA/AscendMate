# 开发套件与模组

> **什么时候读**：使用 **Atlas 200I DK A2** 开发套件，用于学习、开发与边缘场景。

## 一、代表产品

| 产品 | 定位 | 官方文档 |
| --- | --- | --- |
| **Atlas 200I DK A2 开发套件** | 面向开发者/学习/边缘的开发板 | [链接](https://support.huawei.com/enterprise/zh/ascend-computing/atlas-200i-dk-a2-pid-254412173) |

## 二、用途

- **学习与验证**：低成本体验昇腾开发（AscendCL / AscendC / 推理等）。
- **边缘计算**：在靠近数据的场景做 AI 推理。
- **原型开发**：快速验证算子、算法再规模化。

## 三、快速上手

开发套件通常自带 Ubuntu/CANN 等系统镜像，上手相对简单：

1. 烧录系统镜像到 SD 卡等介质。
2. 上电、连接，进入系统。
3. 用 `npu-smi info` 或对应工具确认识别设备。
4. 开始跑样例（见 [样例代码与模型](https://revolutionla.github.io/AscendMate/resources/samples-models)）或自己开发。

## 四、学习路径推荐

- 先跑官方 **samples**（AscendCL 推理等样例），理解基本调用。
- 再学 [Ascend C](https://revolutionla.github.io/AscendMate/ops/ascend-c) 算子开发。
- 有个性的模型要做 → [推理全景](https://revolutionla.github.io/AscendMate/inference/) 或 [训练全景](https://revolutionla.github.io/AscendMate/training/)。
