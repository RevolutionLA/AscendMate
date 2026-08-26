# 05 PyTorch + torch_npu 安装

> **什么时候读**：CANN 就绪后，安装最主流的 AI 框架组合 —— PyTorch + torch_npu。

`torch_npu` 是让 **PyTorch** 能在昇腾 NPU 上运行的适配层，作用类似于 `torch.cuda` 之于 NVIDIA。装好它，你就能用 `import torch; import torch_npu` + `torch.npu` 接口在昇腾上写代码。

## 一、版本配套（务必看！）

**torch_npu 与 PyTorch 必须是配套版本**，不能随意装。官方给出严格对应关系。

| PyTorch | torch_npu 对应版本 | 常见 CANN 配套 |
| --- | --- | --- |
| 2.1.0 | torch_npu 相同基线的对应版本 | 见官方发布说明 |
| 2.5.0 / 2.6.0 / 2.7.x 等 | 对应同名版本 | 8.x 及以上 |

> 精确对应表请以官方安装文档为准：
> [torch_npu 官方安装指南](https://www.hiascend.com/document/detail/zh/Pytorch/730/configandinstg/instg/docs/zh/installation_guide/installation_via_binary_package.md)

## 二、准备 Python 环境

```bash
# 推荐 conda 建独立环境，避免污染系统
conda create -n torch_npu python=3.10 -y
conda activate torch_npu

# 升级 pip
python -m pip install -U pip
```

> [!NOTE]
> Python 版本也要在官方支持范围内（通常 3.8–3.11/3.12，视版本而定）。
> ARM 架构下请确保 pip >= 19.3。

## 三、安装 PyTorch

```bash
# 安装指定版本的 PyTorch（示例 2.1.0，实际以配套表为准）
pip install torch==2.1.0 -i https://pypi.tuna.tsinghua.edu.cn/simple
```

## 四、安装 torch_npu

从官方渠道获取对应版本的 torch_npu wheel，然后：

```bash
pip install torch_npu-<版本>-cp3xx-cp3xx-linux_aarch64.whl
```

> 各版本 torch_npu 包与适配信息见昇腾官方文档中心、或 torch_npu 官方仓库（Ascend/PyTorch）。

## 五、环境变量

```bash
source /usr/local/Ascend/ascend-toolkit/set_env.sh
```

## 六、验证可用性

```bash
python -c "import torch; import torch_npu; print('NPU count:', torch.npu.device_count()); print(torch.npu.get_device_name(0))"
```

能打印出设备数量与名称，即安装成功。

也可做一次真实运算：

```python
import torch
import torch_npu

x = torch.randn(3, 3).npu()
y = torch.randn(3, 3).npu()
z = x @ y
torch.npu.synchronize()
print("NPU mul ok, shape=", z.shape)
```

## 七、从 GPU 代码迁移到 NPU 的映射提示

| GPU 写法 | NPU 写法 |
| --- | --- |
| `cuda` / `.cuda()` | `npu` / `.npu()` |
| `torch.cuda.is_available()` | `torch.npu.is_available()` |
| `torch.cuda.device_count()` | `torch.npu.device_count()` |
| `device = "cuda:0"` | `device = "npu:0"` |

更系统的迁移方法见 [PyTorch 模型迁移](https://revolutionla.github.io/AscendMate/training/pytorch-migration)。

## 验证

能 `torch.npu.device_count()` 正确返回 NPU 数量 → 环境核心已打通。接下来可进入 [业务接入](https://revolutionla.github.io/AscendMate/guide/seven-steps#第-6-步接入业务)。
