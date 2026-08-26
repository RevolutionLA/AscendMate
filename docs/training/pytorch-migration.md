# PyTorch 模型迁移

> **什么时候读**：你把原本在 GPU（CUDA）或其他平台上写的 PyTorch 模型/训练/推理代码，迁移到昇腾 NPU 上运行。

昇腾通过 **torch_npu** 提供与 `torch.cuda` 对应的 `torch.npu` 能力，GPU 代码迁移总体成本较低。

## 一、迁移的本质

- `torch.cuda.*` → `torch.npu.*`
- 设备从 `cuda` → `npu`
- 数据处理/模型代码主体基本不变。

## 二、最常用的替换映射

| GPU 写法 | NPU 写法 |
| --- | --- |
| `import torch` | `import torch` + `import torch_npu` |
| `.cuda()` | `.npu()` |
| `torch.device('cuda')` | `torch.device('npu')` |
| `torch.cuda.is_available()` | `torch.npu.is_available()` |
| `torch.cuda.device_count()` | `torch.npu.device_count()` |
| `torch.cuda.set_device(i)` | `torch.npu.set_device(i)` |
| `data_loader.to('cuda:0')` | `data_loader.to('npu:0')` |
| `with torch.cuda.amp.autocast()` | `with torch.npu.amp.autocast()` |

很多时候只需把代码里的 `cuda` 字符串/接口替换成 `npu`，并对 `.npu()` 显式调用。

## 三、实用技巧：用环境变量切换

不想全改硬编码时，可定义一个统一的设备选择：

```python
import torch
import torch_npu

def get_device():
    if torch.npu.is_available():
        return torch.device('npu:0')
    return torch.device('cuda:0' if torch.cuda.is_available() else 'cpu')

device = get_device()
model = model.to(device)
```

## 四、迁移后常见坑

1. **版本配套**：PyTorch 与 torch_npu 版本必须匹配（见 [安装页](https://revolutionla.github.io/AscendMate/setup/torch-npu-install)）。
2. **算子兼容**：个别自定义算子/高阶 API 在 NPU 上可能不生效，需改写或查替代（见 [算子开发](https://revolutionla.github.io/AscendMate/ops/)）。
3. **显存策略**：OOM 时调整 batch、用显存优化（见 [性能与精度问题](https://revolutionla.github.io/AscendMate/faq/perf-precision-issues)）。
4. **seed/随机**：训练收敛对齐需固定 NPU 随机种子。

## 五、多 GPU / 分布式

- torch 原生分布式（`torch.distributed`）经由 torch_npu 支持集合通信（HCCL）。
- 大规模训练建议直接用 [MindSpeed](https://revolutionla.github.io/AscendMate/training/mindspeed) 管理并行。

## 六、参考模型代码

昇腾官方 **ModelZoo-PyTorch** 提供基于 NPU 的训练/推理参考源码：

- PyTorch 训练源码：`gitcode.com/ascend/ModelZoo-PyTorch/tree/master/PyTorch`
- 推理（ACL）源码：`.../ACL_PyTorch`
- MindIE 参考：`.../MindIE`

👉 汇总见 [资源导航](https://revolutionla.github.io/AscendMate/resources/samples-models)。

## 官方迁移文档

- 昇腾 PyTorch 训练迁移指南：[官方文档](https://www.hiascend.com/document/detail/zh/Pytorch/730/ptmoddevg/trainingmigrguide/PT_LMTMOG_0013.html)

> [!TIP]
> 迁移难点通常不在"cuda→npu"，而在**算子和性能**。先跑通，再优化。遇到性能瓶颈看 [性能调优](https://revolutionla.github.io/AscendMate/tools/profiling)。
