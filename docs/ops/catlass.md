# CATLASS 快速开始

> **什么时候读**：你要开发**矩阵乘（Matmul）类算子**，想用现成的模板与基础组件快速起步。

[CATLASS](https://gitcode.com/cann/catlass) 是昇腾提供的**模板库**，为矩阵乘等算子开发提供可复用的模板与基础组件，帮你从零开始开发算子。

## 一、用途

- 提供一套可复用的 **Matmul 算子模板**与基础组件。
- 赋能矩阵乘法算子开发，样例见仓库 `examples/` 目录。
- 适合作为自定义高性能算子的开发起点。

## 二、环境准备

1. **安装 NPU 驱动与固件**（见 [固件驱动安装](/setup/firmware-driver)）。
2. **安装社区版 CANN Toolkit**：

```bash
chmod +x Ascend-cann-toolkit_{version}_linux-{arch}.run
./Ascend-cann-toolkit_{version}_linux-{arch}.run --full --force --install-path=${install_path}
```

> `{arch}` 为系统架构，`{install_path}` 默认 `/usr/local/Ascend`。CANN 下载见 [资源导航](/resources/download)。

3. **使能 CANN 环境**：

```bash
source /usr/local/Ascend/ascend_toolkit/set_env.sh
# 或指定路径：source ${install_path}/set_env.sh
```

4. **下载源码**：

```bash
git clone https://gitcode.com/cann/catlass.git
```

> CATLASS 版本与 CANN 版本有配套，见仓库 README「软硬件配套说明」。
> 注意：不同文档环境变量路径写法可能为 `ascend_toolkit`（CATLASS 示例）或 `ascend-toolkit`（官方），以实际安装为准。

## 三、编译样例

进入项目根目录：

```bash
bash scripts/build.sh [options] <target>
```

常用选项：

- `--clean`：清理编译输出
- `--debug`：Debug 模式编译
- `-DCATLASS_BISHENG_ARCH=a2|a3`：指定 NPU 架构
- `--simulator` / `--enable_profiling` / `--enable_print` 等调测选项

编译某个样例（如 basic_matmul）：

```bash
bash scripts/build.sh 00_basic_matmul
```

出现 `"[INFO] Target '00_basic_matmul' built successfully."` 即成功。

## 四、执行算子

编译产物在 `output/bin`：

```bash
cd output/bin
# ./00_basic_matmul <m> <n> <k> [deviceId]
./00_basic_matmul 256 512 1024 0
```

输出 `Compare success.` 表示计算符合精度预期（左/右矩阵随机生成，真值以 CPU 为准）。

## 五、进阶开发

- 基于模板开发第一个 Matmul 算子：见官方 `dev_guide.md`。
- Python/PyTorch 调用扩展：`scripts/build.sh python_extension|torch_library`。
- 性能调优 / 仿真：`--enable_profiling`、`--simulator`、msDebug 等。

## 相关

- [算子开发全景](/ops/)
- [Ascend C 算子开发](/ops/ascend-c)
- [Triton-Ascend](/ops/triton-ascend)
