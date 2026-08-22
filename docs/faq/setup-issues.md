# 环境搭建类问题

> 昇腾环境搭建阶段最常见的报错与排查。

## 一、`npu-smi info` 不识别 / 无设备

**现象**：`npu-smi: command not found`，或命令执行后无设备/报错。

**排查**：

1. 驱动是否安装正确？`cat /usr/local/Ascend/driver/version.info` 有无版本。
2. 内核模块是否加载：`lsmod | grep npu`。
3. 是否为板卡直插：检查 PCIe 枚举（`lspci | grep -i ascend`）。
4. 重新安装/升级驱动并**重启**。

## 二、装驱动报错 / 残留冲突

- 之前装过旧版本→需要**干净卸载**再装。
- 内核版本不匹配，检查驱动与内核支持的对应关系。

## 三、CANN 环境变量不对

现象：`bash: source: Ascend: No such file` 或框架找不到 CANN。

排查：确认路径并正确 source：

```bash
source /usr/local/Ascend/ascend-toolkit/set_env.sh   # 社区版常见路径
# 或 /usr/local/Ascend/ascend_toolkit/set_env.sh     # 部分版本写法
```

> 注意 `ascend-toolkit` 与 `ascend_toolkit` 两种写法不同版本/来源可能不同，按实际目录选。

## 四、版本不配套（最高频）

**现象**：框架 import 不了设备、CANN 版本太老/太新不支持某功能。

**对策**：安装前查官方**配套表**，选择一套完整配套一起装：

- 操作系统兼容：<https://www.hiascend.com/hardware/compatibility>
- 选择成套版本，见 [环境搭建总览](/setup/)

## 五、Python/Docker 相关

| 现象 | 排查 |
| --- | --- |
| ARM 下 pip 装不上 | 升级 pip（`pip install -U pip`），确认 Python 版本在支持范围 |
| 容器内看不到 NPU | 检查 `docker run` 时是否传了 `--device`（见 [Docker](/setup/docker-offline)） |
| 之前装过 te/topi/hccl | `pip uninstall te topi hccl` 后重装依赖 |

## 六、还要看

- 日志：`dmesg | grep -i npu`、`cat /var/log/npu/slog/*.log`
- [环境自检清单](/setup/checklist)

> [!TIP]
> 先用 [环境自检清单](/setup/checklist) 逐项确认，多数环境问题都会暴露在这一步。
