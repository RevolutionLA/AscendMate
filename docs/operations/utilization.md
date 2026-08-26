---
layout: doc
title: 算力利用率监控与优化
description: 昇腾算力利用率的定义测量、低效原因分析、优化策略及提升案例
---

# 算力利用率监控与优化

> **核心目标**：让每一张昇腾NPU卡都在"干活"，且"高效地干活"

---

## 利用率的定义与测量

### 利用率不是单一数字

很多人把"NPU利用率"简单理解为`npu-smi info`中的AI Core使用率，但这是不全面的。完整的利用率应该从**芯片、显存、时间、综合**四个维度理解：

| 维度 | 定义 | 测量方式 | 典型问题 |
|------|------|---------|---------|
| **芯片利用率** | AI Core计算单元实际占用比例 | `npu-smi info` AI Core % | 计算瓶颈/数据饥饿 |
| **显存利用率** | HBM显存占用比例 | `npu-smi info` HBM % | 显存浪费/模型过大 |
| **时间利用率** | 时间维度上算力被占用的比例 | 调度系统统计运行时长/总时长 | 闲置/排队浪费 |
| **综合利用率** | 加权综合评估 | 芯片利用率 × 时间利用率 | 真实效率指标 |

### 昇腾NPU利用率监控

#### 基础监控命令

```bash
# 查看NPU实时状态
npu-smi info

# 输出示例：
# +---------------------------+---------------------------+
# | NPU   Name                | Health  Power(W) Temp(C)  |
# | Chip                      | Bus-Id                    |
# | AICore(%)  Memory-Usage(M)|                           |
# +===========================+===========================+
# | 0     Ascend910B          | OK       65.3    42       |
# | 0                         | 0000:C1:00.0              |
# | 45         10240 / 32768  |                           |
# +===========================+===========================+
```

**关键字段解读**：
- `AICore(%)`：AI Core利用率，即芯片计算单元使用率
- `Memory-Usage(M)`：显存使用量/总量
- `Power(W)`：功耗，可间接反映计算负载
- `Temp(C)`：温度，过高会降频

#### 持续监控方案

使用Prometheus + Grafana构建持续监控体系：

**1. NPU指标采集**

```bash
# 安装昇腾DCMI Exporter（采集NPU指标到Prometheus）
# 采集指标包括：
# - npu_dcmi_utilization_rate（芯片利用率）
# - npu_dcmi_memory_usage（显存利用率）
# - npu_dcmi_power（功耗）
# - npu_dcmi_temperature（温度）
# - npu_dcmi_health_status（健康状态）
```

**2. Prometheus配置示例**

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'npu-metrics'
    static_configs:
      - targets: ['node1:9100', 'node2:9100', 'node3:9100']
    scrape_interval: 15s
```

**3. Grafana看板核心面板**

| 面板 | PromQL/指标 | 说明 |
|------|------------|------|
| NPU利用率趋势 | `npu_dcmi_utilization_rate` | 实时/历史利用率曲线 |
| 显存使用率 | `npu_dcmi_memory_usage / npu_dcmi_memory_total` | 显存占用趋势 |
| 集群利用率热力图 | 按节点×时间展示利用率 | 发现低效节点和时段 |
| 闲置NPU统计 | `count(npu_dcmi_utilization_rate < 5)` | 闲置卡数量 |
| 温度告警 | `npu_dcmi_temperature > 80` | 高温告警 |

### 利用率测量最佳实践

#### 采样频率

| 场景 | 采样频率 | 理由 |
|------|---------|------|
| 实时监控 | 5-15秒 | 及时发现异常 |
| 日报统计 | 1分钟 | 平衡精度和存储 |
| 月报趋势 | 5分钟 | 长期趋势分析 |
| 容量规划 | 1小时 | 宏观规划参考 |

#### 分维度统计

建议按以下维度统计利用率，便于定位问题：

| 统计维度 | 说明 | 用途 |
|---------|------|------|
| 按节点 | 每台服务器的利用率 | 发现异常节点 |
| 按NPU | 每张卡的利用率 | 发现个别卡问题 |
| 按团队 | 各团队占用资源利用率 | 团队效率对比 |
| 按场景 | 训练/推理分别统计 | 不同负载特征分析 |
| 按时段 | 小时/天/周维度 | 发现闲时和忙时规律 |

---

## 利用率低常见原因分析

### 原因一：任务分配不均

**现象**：部分NPU卡利用率高（>80%），部分卡利用率低（<20%）

**原因分析**：
- 训练任务数据并行时，各卡数据量不均匀
- 推理请求负载均衡不当，流量集中在部分卡上
- 任务分配时未考虑NPU亲和性

**解决方案**：
```python
# MindSpore数据并行训练 - 确保数据均匀分片
import mindspore as ms
from mindspore.communication import init

# 初始化分布式环境
ms.set_context(mode=ms.GRAPH_MODE, device_target="Ascend")
init()
ms.set_auto_parallel_context(
    parallel_mode=ms.ParallelMode.DATA_PARALLEL,
    gradients_mean=True  # 梯度聚合
)

# 确保DataLoader的batch_size能被卡数整除
# batch_size_per_card = total_batch_size / num_cards
```

### 原因二：数据I/O瓶颈

**现象**：NPU利用率波动大，呈"锯齿状"（忽高忽低）

**原因分析**：
- 数据加载速度跟不上NPU计算速度
- 存储I/O带宽不足
- 数据预处理在CPU端成为瓶颈

**解决方案**：

```python
# MindSpore数据加载优化
import mindspore.dataset as ds

# 1. 增大预取队列
dataset = ds.ImageFolderDataset(
    data_dir,
    num_parallel_workers=8,  # 增加并行加载线程
    shuffle=True,
    num_shards=rank_size,
    shard_id=rank_id
)

# 2. 使用prefetch预取
dataset = dataset.batch(
    batch_size=32,
    drop_remainder=True
).prefetch(8)  # 预取8个batch

# 3. 使用高效存储（如NVMe SSD / 分布式存储并行读）
```

### 原因三：模型计算密度低

**现象**：NPU利用率持续低位（20-40%），无波动

**原因分析**：
- 模型太小，计算量不足以填满NPU
- batch_size太小，未充分利用并行计算能力
- 频繁的CPU-NPU数据拷贝

**解决方案**：

```python
# 1. 增大batch_size
# 小模型可以适当增大batch_size提升利用率
# 但需注意显存限制

# 2. 使用混合精度训练（提升计算效率）
ms.set_context(
    mode=ms.GRAPH_MODE,
    device_target="Ascend",
    ascend_config={"precision_mode": "allow_mix_precision"}  # 混合精度
)

# 3. 减少CPU-NPU数据拷贝
# 尽量在NPU上完成计算，避免频繁数据来回
```

### 原因四：资源碎片化

**现象**：集群整体有空闲资源，但无法满足新任务需求

**原因分析**：
- 大量小任务占用部分卡，剩余碎片无法利用
- 任务分配不连续，导致资源碎片

**解决方案**：
- 使用vNPU虚拟化分片（详见[调度管理](./scheduling.md)）
- 任务打包：多个小任务共享同一台服务器
- 定期整理碎片：在闲时迁移任务，合并空闲资源

### 原因五：排队等待

**现象**：用户反映算力不够用，但实际NPU利用率不高

**原因分析**：
- 调度策略不合理，任务排队时间长
- 长任务占住资源，短任务无法插队
- 缺乏优先级调度

**解决方案**：
- 实施优先级调度（高优先级任务可抢占）
- 设置任务最长运行时间，防止资源长期占用
- 使用弹性调度（闲时允许超配）

### 原因六：环境问题

**现象**：任务频繁失败重试，NPU利用率不稳定

**原因分析**：
- CANN/MindSpore版本不匹配
- NPU驱动异常或固件版本过旧
- 网络问题导致分布式训练卡死

**解决方案**：
- 统一版本基线（CANN + MindSpore + 驱动版本配套表）
- 定期健康检查（npu-smi info + 温度/功耗监控）
- 分布式训练网络检查（HCCL连通性测试）

---

## 优化策略

### 策略一：任务调度优化

#### 优先级调度

| 优先级 | 适用场景 | 调度策略 |
|--------|---------|---------|
| P0 紧急 | 线上推理、紧急修复 | 立即分配，可抢占低优先级 |
| P1 高 | 重要项目训练 | 优先排队 |
| P2 中 | 日常实验 | 正常排队 |
| P3 低 | 探索性实验 | 闲时执行，忙时可被抢占 |

#### 抢占式调度

```bash
# Slurm抢占式调度配置
# slurm.conf
PreemptMode=REQUEUE          # 抢占模式：重新排队
PreemptType=preempt/partition_prio  # 按分区优先级抢占
GraceTime=300                # 被抢占任务的优雅退出时间（秒）

# 高优先级分区可以抢占低优先级分区
PartitionName=high_prio Priority=1000
PartitionName=low_prio Priority=100 AllowAccounts=experimental
```

### 策略二：资源池化

#### 训练/推理资源弹性共享

```
┌─────────────────────────────────────┐
│         算力资源池（统一管理）          │
├──────────────┬──────────────────────┤
│  推理资源池   │    训练资源池          │
│  （白天优先）  │   （夜间优先）         │
│  最低保障：60% │   最低保障：30%        │
│  弹性上限：100%│   弹性上限：70%        │
└──────────────┴──────────────────────┘
```

**分时复用策略**：
- 工作时间（9:00-18:00）：推理优先，训练资源可被借用
- 非工作时间（18:00-9:00）：训练优先，推理保障最低资源
- 周末：训练全量使用

#### 实现方式

```bash
# Slurm定时调整分区资源
# 工作日早上：扩大推理分区
scontrol update partition=inference nodes=all
scontrol update partition=training nodes=none

# 工作日晚上：扩大训练分区
scontrol update partition=training nodes=all
scontrol update partition=inference nodes=node[01-02]  # 保留2台给推理
```

### 策略三：闲时利用

#### 闲时任务自动填充

| 闲时时段 | 可填充任务 | 收益 |
|---------|----------|------|
| 夜间（22:00-8:00） | 大批量训练、数据预处理 | 利用率+20-30% |
| 周末 | 模型微调、超参搜索 | 利用率+15-25% |
| 节假日 | 批量推理、模型评估 | 利用率+10-15% |

#### 闲时任务管理

```python
# 闲时任务自动提交脚本示例
import subprocess
import datetime

def submit_idle_jobs():
    """在闲时自动提交低优先级任务"""
    now = datetime.datetime.now()
    hour = now.hour
    
    # 22:00-8:00为闲时
    if hour >= 22 or hour < 8:
        jobs = [
            # 低优先级训练任务
            {"script": "train_batch.sh", "partition": "low_prio", "time": "08:00:00"},
            # 数据预处理任务
            {"script": "preprocess.sh", "partition": "low_prio", "time": "04:00:00"},
        ]
        for job in jobs:
            cmd = f"sbatch --partition={job['partition']} --time={job['time']} {job['script']}"
            subprocess.run(cmd, shell=True)
            print(f"提交闲时任务: {job['script']}")

if __name__ == "__main__":
    submit_idle_jobs()
```

### 策略四：vNPU虚拟化分片

vNPU（虚拟NPU）是将一张物理NPU卡虚拟化为多个逻辑NPU，实现算力的细粒度分配：

| 分片模式 | 说明 | 适用场景 |
|---------|------|---------|
| 静态分片 | 按固定比例切分（如1:1, 1:3） | 推理场景，负载稳定 |
| 动态分片 | 按需分配和回收 | 混合负载，弹性需求 |

**vNPU配置示例**：

```bash
# 创建vNPU虚拟化分片
# 将1张物理卡切分为2个vNPU
npu-smi set -t vnpuid -i 0 -c 0 -f 0    # vNPU 0
npu-smi set -t vnpuid -i 0 -c 0 -f 1    # vNPU 1

# 查看vNPU状态
npu-smi info -t vnpu

# 分配vNPU给容器（K8s场景）
# 在Pod YAML中指定vNPU资源
```

> 详见[调度管理](./scheduling.md)文档中的vNPU虚拟化分片章节。

### 策略五：模型推理优化

#### 推理引擎优化

| 优化技术 | 说明 | 效果 |
|---------|------|------|
| **模型量化** | FP32 → FP16/INT8 | 吞吐量提升2-4倍 |
| **张量并行** | 大模型多卡并行推理 | 时延降低，吞吐量提升 |
| **Batch推理** | 多请求合并Batch | 吞吐量提升3-10倍 |
| **动态Shape** | 支持变长输入 | 减少padding浪费 |

**MindIE推理优化示例**：

```bash
# 使用MindIE进行模型推理优化
# 1. 模型转换（MindSpore → MindIR）
python export.py --model qwen_14b --output qwen_14b.mindir

# 2. 量化压缩
mindie --quantize --model qwen_14b.mindir --output qwen_14b_int8.mindir --bit 8

# 3. 推理部署
mindie --serve --model qwen_14b_int8.mindir --port 8080
```

---

## 利用率提升案例

### 案例一：推理集群利用率从35%提升至75%

**背景**：某企业8台Atlas 800I A2推理集群，利用率长期35%左右

**问题诊断**：
1. 推理请求分布不均，部分卡负载90%，部分卡负载10%
2. 单请求推理，未使用Batch推理
3. FP32模型未量化

**优化措施**：
1. **负载均衡**：部署Nginx + 多卡轮询，请求均匀分配
2. **Batch推理**：启用动态Batch，合并100ms窗口内的请求
3. **模型量化**：FP32 → FP16，吞吐量提升2倍
4. **vNPU分片**：将8卡切分为16个vNPU，提升并发能力

**效果**：
| 指标 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| 平均利用率 | 35% | 75% | +114% |
| 吞吐量(QPS) | 50 | 180 | +260% |
| 平均时延 | 200ms | 80ms | -60% |

### 案例二：训练集群利用率从50%提升至82%

**背景**：某研究院4台Atlas 800T A2训练集群，利用率50%左右

**问题诊断**：
1. 数据加载瓶颈，NPU等待数据（锯齿状利用率）
2. 小batch_size未充分利用NPU
3. 任务间排队时间长

**优化措施**：
1. **数据加载优化**：增加DataLoader并行线程（4→16），启用prefetch
2. **存储优化**：训练数据迁移到NVMe SSD，I/O速度提升5倍
3. **batch_size调优**：从32提升至128（配合梯度累积）
4. **闲时任务填充**：夜间自动提交低优先级训练任务
5. **调度优化**：启用Slurm抢占式调度，高优先级任务零等待

**效果**：
| 指标 | 优化前 | 优化后 | 提升 |
|------|--------|--------|------|
| 平均利用率 | 50% | 82% | +64% |
| 任务排队时间 | 平均4小时 | 平均30分钟 | -87% |
| 数据加载等待 | 40%时间 | <5%时间 | -87% |

---

## 利用率监控看板设计

### 推荐Grafana看板面板

| 面板名称 | 展示内容 | 告警阈值 |
|---------|---------|---------|
| 集群总览 | 总卡数/在线/离线/利用率 | 离线 > 0 |
| 利用率趋势 | 24h/7d/30d利用率曲线 | < 40% |
| 节点热力图 | 按节点×时间利用率 | 持续 < 20% |
| 闲置NPU列表 | 利用率 < 5%的卡 | 闲置 > 1h |
| 温度监控 | 各NPU温度 | > 80°C |
| 功耗监控 | 各NPU功耗 | > 额定90% |
| 作业统计 | 运行/排队/完成/失败 | 失败率 > 10% |
| 团队利用率 | 各团队资源利用率 | < 30% |

### 告警规则示例

```yaml
# Prometheus告警规则
groups:
  - name: npu_alerts
    rules:
      # NPU闲置告警
      - alert: NPUIdle
        expr: npu_dcmi_utilization_rate < 5
        for: 1h
        labels:
          severity: warning
        annotations:
          summary: "NPU {{ $labels.npu }} 闲置超过1小时"
      
      # 集群利用率低告警
      - alert: ClusterLowUtilization
        expr: avg(npu_dcmi_utilization_rate) < 40
        for: 6h
        labels:
          severity: warning
        annotations:
          summary: "集群平均利用率低于40%持续6小时"
      
      # NPU高温告警
      - alert: NPUHighTemp
        expr: npu_dcmi_temperature > 80
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "NPU {{ $labels.npu }} 温度超过80°C"
```

---

## 下一步

- [调度管理](./scheduling.md) — 多团队调度与vNPU虚拟化
- [成本核算](./cost-accounting.md) — 算力成本管理与计费
- [场景价值发现](../scenes/index.md) — 提升算力的业务价值

---

*本文档由昇腾AI解决方案架构师团队编写，持续更新中。*
*最后更新：2026-08-26*
