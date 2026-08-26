# 01 服务器上电与规划

> 交付昇腾智算服务器的第一步：确认硬件、规划版本、准备环境。

## 一、确认硬件型号

到货后先确认你拿到的硬件是哪种生态定位，因为后续所有版本都要围绕它选型：

- **Atlas 900 A3 SuperPoD / A2 PoD**：超节点集群，用于超大规模训练。
- **Atlas 800T A2/A3**：训练服务器。
- **Atlas 800I A2/A3**：推理服务器。
- **Atlas 300I A2 / Duo / Pro / V Pro**：推理卡。
- **Atlas 200I DK A2**：开发套件 / 模组（学习、边缘）。

录好以下信息（后续排查和报障都要用）：

```bash
# 品牌/系列、产品型号、序列号
# 内存、系统盘/数据盘容量
# NPU 卡数量
# 操作系统计划（若已装）
```

## 二、规划版本配套

**这是最关键的一步。** 请在上电安装前，先确定目标版本组合：

- **操作系统**：openEuler / Ubuntu / EulerOS 等，须在兼容清单内。
- **固件 + 驱动**：连在一体的升级包，与 CANN 版本配套。
- **CANN**：社区版 or 商用版，版本号要与你选定的框架配套。
- **AI 框架**：torch_npu / MindSpore，各有配套 CANN 与 Python 版本。

> [!WARNING]
> 版本配套关系是昇腾最容易踩坑的地方。最稳妥的做法是：**选定一套「官方推荐配套」，全套一起装**，不要混搭最新版。

常见配套示例（以 torch_npu 为主）：

| 组件 | 建议版本思路 |
| --- | --- |
| 操作系统 | openEuler 22.03/24.03 LTS SP1（Arm 或 x86，按机器） |
| 驱动固件 | 与 CANN 配套的最新稳定版 |
| CANN | 社区版 8.2.RC1 / 8.3.RC2 / 8.5.0 等，按框架要求 |
| PyTorch | 2.1 / 2.5 / 2.6 等，与 torch_npu 版本对应 |
| torch_npu | 与 PyTorch 版本严格对应（如 2.6.0 ←→ torch_npu 对应版本） |

> 各组件精确配套表见对应安装页：[/setup/cann-install](https://revolutionla.github.io/AscendMate/setup/cann-install)、[/setup/torch-npu-install](https://revolutionla.github.io/AscendMate/setup/torch-npu-install)

## 三、物理准备清单

- [ ] 机架/电源（双电源更稳），供电到位
- [ ] 带外管理（iBMC/BMC）IP 已配置、可登录
- [ ] 管理网口 + 业务网口已连接
- [ ] 系统盘（U 盘/ISO/网络引导）就绪
- [ ] 记录机器 IP / 主机名 / 账号规划

## 四、上电动作

1. 接好电源与网线。
2. 通过 **iBMC**（带外）打开远程 Console。
3. 上电，进入 BIOS/UEFI。
4. 设置引导顺序，从你的系统安装介质引导。

## 验证

上电进入引导菜单，即说明带外与电源链路 OK。接下来进入 [02 操作系统选择与安装](https://revolutionla.github.io/AscendMate/setup/os-install)。
