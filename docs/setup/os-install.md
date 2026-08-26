# 02 操作系统选择与安装

> **什么时候读**：准备在昇腾智算服务器上安装操作系统。

## 一、操作系统怎么选

昇腾支持的操作系统以官方兼容性为准：

- **查询地址**：<https://www.hiascend.com/hardware/compatibility>

主流选择：

| 系统 | 特点 | 适用 | 备注 |
| --- | --- | --- | --- |
| **openEuler** | 社区开源系统，与昇腾协同好 | 推荐首选 | 本仓库默认示例 |
| **Ubuntu** | 生态广、教程多 | 通用 | 注意选用受支持 LTS |
| **EulerOS** | 商用发行 | 有商用订阅的客户 | |
| **CentOS / Kylin / UOS** 等 | 按客户现网而定 | 有存量 | 需自查兼容性 |

> [!TIP]
> 若不是客户强指定，**推荐 openEuler LTS**，官方适配与示例最多。

## 二、下载镜像

openEuler 24.03 LTS SP1（Arm 版）等镜像可从 openEuler 官网 / 昇腾云社区镜像下载。

- openEuler 官网：<https://www.openeuler.org/zh/download/>
- 昇腾云镜像站：可加速国内下载

注意区分 **aarch64（Arm）** 与 **x86_64** 架构，选错无法引导。

## 三、制作启动介质

- **物理机**：用 `dd`（Linux）/ Rufus / balenaEtcher 把 ISO 写入 U 盘，设为引导盘。
- **服务器**：也可使用 **iBMC 远程挂载 ISO** 引导，无需 U 盘。

```bash
# Linux 下写入 U 盘示例（替换 sdX 为实际设备，务必谨慎）
sudo dd if=openEuler.iso of=/dev/sdX bs=4M status=progress
```

## 四、安装步骤（openEuler 为例）

1. 引导进入安装程序，选择「Install openEuler」。
2. 选择语言（建议 English 以防中文乱码，或中文皆可）。
3. 分区规划：建议 `/` 与 `/home` 合理分配，若不熟悉保留默认自动分区。
4. 选择 **软件包 / 最小安装** 或带基础开发工具的分组（若可选，勾选 "Development Tools"）。
5. 配置 **root 密码** 与 **用户账号**（昇腾操作建议用普通用户 + sudo）。
6. 等待安装完成，重启。

## 五、安装后基础配置

```bash
# 更新系统（按需）
sudo dnf update -y

# 确认架构
uname -m                  # 应为 aarch64 或 x86_64

# 确认网络
ip addr
ping -c 3 www.baidu.com   # 或内网 DNS

# 确认 CPU / 内存
lscpu
free -h
```

> [!NOTE]
> 安装系统本身不涉昇腾，但**系统装完后一定要确认：架构、能上网（或内网镜像可用）、有关键编译工具**，否则后续装 CANN/框架会卡住。

## 关键：装前确认网络/仓库

后续要装 CANN、torch_npu 等，需要能访问软件源或已有离线包。建议提前确认：

- 是否能访问昇腾下载站、pip 源、conda 源。
- 若在隔离内网，需提前**离线下载**好所有依赖包（见 [Docker 镜像与离线部署](https://revolutionla.github.io/AscendMate/setup/docker-offline)）。

## 验证

系统能正常引导、网络通、架构正确 → 进入 [03 固件与驱动安装](https://revolutionla.github.io/AscendMate/setup/firmware-driver)。
