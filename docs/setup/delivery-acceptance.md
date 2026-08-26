---
layout: doc
title: 交付验收 · 到货检查与验收测试
description: 昇腾硬件到货验收全流程：硬件点检Checklist、固件版本核对、性能抽测脚本、交付文档模板及常见问题
---

# 交付验收 · 到货检查与验收测试

> **核心目标**：确保到货的昇腾硬件数量正确、状态完好、性能达标，为后续部署奠定基础

---

## 交付验收概述

昇腾硬件到货后，必须经过严格的验收流程才能投入使用。验收不只是"数箱子"，而是要确保：
1. **数量正确**：硬件型号和数量与采购合同一致
2. **状态完好**：运输过程无损坏，硬件功能正常
3. **版本合规**：固件/驱动版本符合要求
4. **性能达标**：NPU计算性能达到标称指标
5. **文档齐全**：交付文档完整可追溯

### 验收流程

```
到货接收 → 外观检查 → 硬件点检 → 上电测试 → 固件核对 → 性能抽测 → 文档归档 → 验收签字
   1天        1天       0.5天      1天       0.5天      2天       0.5天      0.5天
```

---

## 到货验收Checklist

### 第一阶段：到货接收

#### 1.1 外包装检查

| 检查项 | 检查内容 | 合格标准 | 结果 |
|--------|---------|---------|------|
| 包装箱数量 | 清点总箱数 | 与发货单一致 | □ |
| 包装箱外观 | 检查有无破损/变形/水渍 | 无明显破损 | □ |
| 包装箱标签 | 检查标签信息 | 型号/数量/SN正确 | □ |
| 倾斜指示器 | 检查倾斜标签 | 未变色（未倾斜） | □ |
| 防潮指示 | 检查防潮标签 | 未变色（未受潮） | □ |
| 封条完整性 | 检查封条是否完好 | 封条未被破坏 | □ |

> **注意**：如发现外包装破损、倾斜指示器变色或封条被破坏，应立即拍照留存，并联系供应商处理，暂不签收。

#### 1.2 开箱检查

| 检查项 | 检查内容 | 合格标准 | 结果 |
|--------|---------|---------|------|
| 内部填充 | 防震材料是否完好 | 填充物完好 | □ |
| 设备外观 | 设备有无划痕/变形/锈蚀 | 外观完好 | □ |
| 配件齐全 | 电源线/导轨/耳片等 | 与装箱单一致 | □ |
| 设备标签 | 设备铭牌信息 | 型号/SN/MAC正确 | □ |
| 保修卡 | 保修文件 | 保修卡齐全 | □ |
| 产品合格证 | 合格证明文件 | 合格证齐全 | □ |

### 第二阶段：硬件点检

#### 2.1 服务器硬件点检

**以Atlas 800T A2为例**：

| 检查项 | 检查内容 | 合格标准 | 检查方式 | 结果 |
|--------|---------|---------|---------|------|
| 服务器型号 | 面板标识型号 | 与采购合同一致 | 目视 | □ |
| NPU卡数量 | 检查NPU卡槽数量 | 8张910B | 目视/BIOS | □ |
| NPU卡型号 | 卡上标签型号 | Ascend 910B | 目视 | □ |
| CPU配置 | CPU型号和数量 | 与合同一致 | BIOS | □ |
| 内存配置 | 内存容量和条数 | 与合同一致 | BIOS | □ |
| 硬盘配置 | 系统盘/数据盘 | 与合同一致 | BIOS/OS | □ |
| 网卡配置 | 网卡型号和数量 | 与合同一致 | BIOS/OS | □ |
| 电源模块 | 电源数量和功率 | 冗余电源正常 | BIOS | □ |
| 风扇模块 | 风扇数量 | 全部正常 | BIOS | □ |
| PCIe插槽 | NPU卡安装牢固 | 卡已插紧 | 目视 | □ |

#### 2.2 NPU卡专项检查

```bash
# 1. 上电后检查NPU识别
npu-smi info

# 预期输出：应显示8张910B卡
# +---------------------------+---------------------------+
# | NPU   Name                | Health  Power(W) Temp(C)  |
# | Chip                      | Bus-Id                    |
# | AICore(%)  Memory-Usage(M)|                           |
# +===========================+===========================+
# | 0     Ascend910B          | OK       0.0     35       |
# | 0                         | 0000:C1:00.0              |
# | 0          0 / 65536      |                           |
# +===========================+===========================+
# | 1     Ascend910B          | OK       0.0     34       |
# ...

# 2. 检查NPU序列号（与装箱单核对）
npu-smi info -t board -i 0
# 输出包含BoardSN，与设备标签核对

# 3. 检查NPU健康状态
npu-smi info -t health -i 0
# 应返回OK

# 4. 检查所有NPU
for i in 0 1 2 3 4 5 6 7; do
    echo "=== NPU $i ==="
    npu-smi info -t board -i $i | grep -E "Name|BoardSN|Health"
done
```

### 第三阶段：固件版本核对

#### 3.1 版本配套表

昇腾软件栈版本必须严格配套，不匹配会导致功能异常：

| 组件 | 检查命令 | 参考版本 | 检查结果 |
|------|---------|---------|---------|
| NPU驱动 | `npu-smi info -t board -i 0` | 23.0.0+ | □ |
| NPU固件 | `npu-smi info -t fw -i 0` | 6.3.0+ | □ |
| CANN工具包 | `cat /usr/local/Ascend/ascend-toolkit/latest/version.cfg` | 7.0.0+ | □ |
| 操作系统 | `cat /etc/os-release` | EulerOS 2.0 / Ubuntu 22.04 | □ |
| 内核版本 | `uname -r` | 与CANN兼容 | □ |

#### 3.2 版本检查脚本

```bash
#!/bin/bash
# 版本检查脚本 - firmware_check.sh

echo "=========================================="
echo "  昇腾硬件固件版本检查"
echo "=========================================="
echo ""

# 1. 操作系统版本
echo "【1. 操作系统】"
cat /etc/os-release | grep -E "^NAME|^VERSION"
echo "内核: $(uname -r)"
echo ""

# 2. NPU驱动版本
echo "【2. NPU驱动版本】"
npu-smi info -t board -i 0 | grep -i "version" || echo "驱动版本获取失败"
echo ""

# 3. NPU固件版本
echo "【3. NPU固件版本】"
npu-smi info -t fw -i 0
echo ""

# 4. CANN版本
echo "【4. CANN版本】"
if [ -f /usr/local/Ascend/ascend-toolkit/latest/version.cfg ]; then
    cat /usr/local/Ascend/ascend-toolkit/latest/version.cfg
else
    echo "CANN未安装或路径不正确"
fi
echo ""

# 5. NPU卡信息汇总
echo "【5. NPU卡信息汇总】"
echo "卡数: $(npu-smi info -l | grep "Total Count" | awk '{print $3}')"
for i in $(seq 0 7); do
    npu-smi info -t board -i $i 2>/dev/null | grep -E "Name|Health|Power" | head -3
    echo "---"
done

echo ""
echo "=========================================="
echo "  版本检查完成"
echo "=========================================="
```

### 第四阶段：性能抽测

#### 4.1 基础性能测试

```bash
#!/bin/bash
# 性能抽测脚本 - perf_test.sh

echo "=========================================="
echo "  昇腾NPU性能抽测"
echo "=========================================="

# 1. 基础计算能力测试
echo ""
echo "【1. NPU基础状态检查】"
npu-smi info
echo ""

# 2. 显存带宽测试
echo "【2. 显存带宽测试】"
# 使用MindSpore进行简单的显存带宽测试
python3 -c "
import mindspore as ms
import time
import numpy as np

ms.set_context(device_target='Ascend', device_id=0)

# 分配大数组测试显存
size = 1024 * 1024 * 512  # 512MB
x = ms.Tensor(np.random.randn(size).astype(np.float32))

# 显存拷贝带宽测试
start = time.time()
for _ in range(10):
    y = x * 2.0 + 1.0
elapsed = time.time() - start
print(f'显存计算测试: {10 * size * 4 / elapsed / 1e9:.2f} GB/s (等效带宽)')
"

# 3. 矩阵计算性能测试
echo ""
echo "【3. 矩阵计算性能测试】"
python3 -c "
import mindspore as ms
import time
import numpy as np

ms.set_context(device_target='Ascend', device_id=0)

# 大矩阵乘法测试
M, N, K = 4096, 4096, 4096
a = ms.Tensor(np.random.randn(M, K).astype(np.float16))
b = ms.Tensor(np.random.randn(K, N).astype(np.float16))

# warmup
for _ in range(3):
    c = ms.ops.matmul(a, b)

# 测试
start = time.time()
for _ in range(20):
    c = ms.ops.matmul(a, b)
elapsed = time.time() - start

tflops = 2 * M * N * K * 20 / elapsed / 1e12
print(f'矩阵乘法: {tflops:.2f} TFLOPS (FP16, {M}x{K}x{N})')
"

# 4. 多卡通信测试
echo ""
echo "【4. 多卡HCCL通信测试】"
python3 -c "
import mindspore as ms
from mindspore.communication import init, get_rank, get_group_size

ms.set_context(mode=ms.GRAPH_MODE, device_target='Ascend')
init()
rank = get_rank()
size = get_group_size()
print(f'HCCL通信测试: rank={rank}, group_size={size}')
if size > 1:
    print('多卡通信正常')
else:
    print('单卡模式，跳过多卡通信测试')
"

echo ""
echo "=========================================="
echo "  性能抽测完成"
echo "=========================================="
```

#### 4.2 性能基准参考值

| 测试项 | Atlas 800T A2 (910B) 参考值 | 合格标准 |
|--------|---------------------------|---------|
| NPU识别 | 8张910B | 全部识别 |
| 健康状态 | 全部OK | 100% OK |
| FP16矩阵乘法 | 280-320 TFLOPS/卡 | ≥ 标称值90% |
| 显存容量 | 64GB HBM/卡 | 64GB |
| 显存带宽 | ~1.2 TB/s | ≥ 1.0 TB/s |
| 功耗（空载） | 30-50W/卡 | < 60W |
| 功耗（满载） | 350-400W/卡 | < 410W |
| 温度（空载） | 35-45°C | < 50°C |
| 温度（满载） | 65-75°C | < 80°C |
| HCCL通信 | 多卡通信正常 | 无超时/错误 |

#### 4.3 压力测试

```bash
#!/bin/bash
# 压力测试脚本 - stress_test.sh

echo "=========================================="
echo "  昇腾NPU压力测试（24小时）"
echo "=========================================="

DURATION=86400  # 24小时
START_TIME=$(date +%s)

while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    
    if [ $ELAPSED -ge $DURATION ]; then
        echo "压力测试完成，总时长: $ELAPSED 秒"
        break
    fi
    
    # 每轮训练10分钟
    echo "[$(date)] 第 $((ELAPSED/600+1)) 轮压力测试..."
    
    # 运行计算密集任务
    python3 stress_workload.py --duration 600 --all_npu
    
    # 检查NPU状态
    echo "[$(date)] NPU状态检查:"
    npu-smi info | grep -E "Ascend|OK|Warning|Critical"
    
    # 检查温度告警
    TEMP=$(npu-smi info | grep "Temp" | awk '{print $NF}' | sort -rn | head -1)
    if [ "$TEMP" -gt 80 ]; then
        echo "[告警] NPU温度过高: ${TEMP}°C"
    fi
    
    # 短暂休息
    sleep 10
done

echo "压力测试结束，生成报告..."
python3 generate_stress_report.py
```

---

## 交付文档模板

### 验收报告模板

```markdown
# 昇腾硬件验收报告

## 基本信息
| 项目 | 内容 |
|------|------|
| 验收日期 | 2026-08-26 |
| 采购合同号 | XXXXXXXX |
| 供应商 | XXXXXXXX |
| 验收负责人 | XXX |
| 验收地点 | XXX机房 |

## 硬件清单
| 序号 | 设备名称 | 型号 | 数量 | SN | 状态 |
|------|---------|------|------|-----|------|
| 1 | NPU训练服务器 | Atlas 800T A2 | 10 | ... | 合格 |
| 2 | NPU推理服务器 | Atlas 800I A2 | 5 | ... | 合格 |
| 3 | 边端推理设备 | Atlas 500 A2 | 20 | ... | 合格 |

## 验收结果汇总
| 验收项 | 结果 | 备注 |
|--------|------|------|
| 外观检查 | □合格 □不合格 | |
| 硬件点检 | □合格 □不合格 | |
| 固件版本 | □合格 □不合格 | |
| 性能测试 | □合格 □不合格 | |
| 压力测试 | □合格 □不合格 | |
| 文档齐全 | □合格 □不合格 | |

## 性能测试结果
（附性能测试报告）

## 问题记录
| 序号 | 问题描述 | 处理方式 | 状态 |
|------|---------|---------|------|
| 1 | ... | ... | 已解决/待处理 |

## 验收结论
□ 验收通过
□ 有条件通过（需整改）
□ 验收不通过

## 签字
| 角色 | 姓名 | 签字 | 日期 |
|------|------|------|------|
| 验收负责人 | | | |
| 供应商代表 | | | |
| IT负责人 | | | |
```

### 交付物清单

| 交付物 | 说明 | 必须 |
|--------|------|------|
| 硬件设备 | 服务器/卡/配件 | ✅ |
| 产品合格证 | 厂商合格证明 | ✅ |
| 保修卡 | 保修凭证 | ✅ |
| 验收报告 | 验收结果记录 | ✅ |
| 性能测试报告 | 性能数据记录 | ✅ |
| 固件版本清单 | 各组件版本 | ✅ |
| 设备台账 | SN/MAC/IP登记 | ✅ |
| 机柜布置图 | 物理部署图 | 推荐 |
| 网络拓扑图 | 网络连接图 | 推荐 |
| 操作手册 | 基本操作指南 | 推荐 |

---

## 常见交付问题

### 问题一：NPU识别不全

**现象**：`npu-smi info`只显示部分卡，如8张卡只识别6张。

**排查步骤**：
```bash
# 1. 检查lspci是否能看到NPU设备
lspci | grep -i "processing"

# 2. 检查NPU卡是否插紧
# 关机后重新插拔NPU卡

# 3. 检查驱动日志
dmesg | grep -i "npu\|ascend\|davinci"

# 4. 检查PCIe链路
npu-smi info -t board -i 0 | grep -i "pci"
```

**常见原因**：
- NPU卡未插紧（运输震动）
- PCIe插槽故障
- 驱动版本不匹配
- 供电不足

### 问题二：固件版本不匹配

**现象**：CANN与NPU固件版本不兼容，运行报错。

**解决方案**：
```bash
# 1. 查看版本配套表
# 访问昇腾官方文档，确认CANN与固件的配套关系

# 2. 升级NPU固件（如需）
npu-smi upgrade -t fw -i 0 -f /path/to/firmware.bin

# 3. 升级NPU驱动
# 下载对应版本驱动包
rpm -ivh ascend-driver-xxx.rpm

# 4. 重启后验证
reboot
# 重启后执行版本检查脚本
```

### 问题三：性能不达标

**现象**：矩阵乘法TFLOPS远低于标称值。

**排查步骤**：
```bash
# 1. 检查NPU频率模式
npu-smi info -t board -i 0 | grep -i "freq"
# 确认非降频模式

# 2. 检查温度（高温会降频）
npu-smi info | grep "Temp"

# 3. 检查电源模式
npu-smi set -t power-mode -i 0 -c 0 -d 1  # 设置为高性能模式

# 4. 检查是否使用了混合精度
# 确认测试使用FP16而非FP32
```

### 问题四：HCCL通信失败

**现象**：多卡分布式训练时HCCL初始化失败。

**排查步骤**：
```bash
# 1. 检查网络连通性
ping <other_node_ip>

# 2. 检查RoCE网卡
ibdev2netdev
# 确认RoCE网卡正常

# 3. 检查HCCL配置
cat /etc/hccn.conf  # 或环境变量
# 确认IP配置正确

# 4. HCCL连通性测试
python3 -c "
from mindspore.communication import init
init()
print('HCCL初始化成功')
"

# 5. 检查rank_table配置
cat rank_table_8p.json
# 确认各卡IP和端口配置正确
```

### 问题五：高温告警

**现象**：NPU温度持续超过80°C。

**排查步骤**：
```bash
# 1. 检查机房温度
# 确认机房制冷正常（建议22-25°C）

# 2. 检查服务器风扇
ipmitool sensor | grep -i "fan"
# 确认风扇转速正常

# 3. 检查机柜风道
# 确认机柜前后通风良好，无阻挡

# 4. 检查NPU导热
# 如单卡温度异常高，可能是散热硅脂问题
# 联系供应商处理

# 5. 临时措施：限制功耗
npu-smi set -t power-limit -i 0 -c 0 -d 350  # 限制350W
```

---

## 验收最佳实践

### 验收前准备

1. **环境就绪**：机房温度/湿度/供电/网络就绪
2. **工具准备**：验收脚本、测试工具、文档模板
3. **人员到位**：验收负责人、IT运维、供应商代表
4. **时间规划**：预留5-7个工作日完成全部验收

### 验收中注意事项

1. **全程记录**：拍照/录像记录开箱和测试过程
2. **问题即报**：发现问题立即记录并通知供应商
3. **不放过异常**：任何异常都需查明原因
4. **抽样比例**：10台以下全测，10台以上抽测30%+

### 验收后工作

1. **文档归档**：验收报告/测试数据/设备台账归档
2. **标签粘贴**：设备贴标签（IP/SN/用途）
3. **台账录入**：录入资产管理系统
4. **保修登记**：登记保修信息，设置保修到期提醒
5. **知识沉淀**：记录验收经验和问题处理方案

---

## 下一步

- [批量部署](./batch-deployment.md) — 验收后批量部署环境
- [算力运营管理](../operations/index.md) — 上线后运营管理
- [利用率优化](../operations/utilization.md) — 提升算力利用率

---

*本文档由昇腾AI解决方案架构师团队编写，持续更新中。*
*最后更新：2026-08-26*
