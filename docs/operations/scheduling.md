---
layout: doc
title: 多团队调度与资源分配
description: 昇腾算力多团队调度方案：Slurm作业调度、KubeSphere+Volcano、vNPU虚拟化分片、多租户配额管理与公平调度
---

# 多团队调度与资源分配

> **核心目标**：当多个团队共享昇腾算力时，实现资源公平分配、高效利用、按需弹性

---

## 为什么需要调度系统

当算力从"单团队使用"变为"多团队共享"时，没有调度系统会面临以下问题：

| 问题 | 无调度系统 | 有调度系统 |
|------|----------|----------|
| 资源争抢 | 谁先占谁先用，先到先得 | 按优先级和配额公平分配 |
| 资源浪费 | 占住资源不释放 | 自动回收闲置资源 |
| 任务管理 | 手动启停任务 | 作业排队、监控、日志管理 |
| 成本核算 | 无法统计谁用了多少 | 精确到团队/项目的资源统计 |
| 故障恢复 | 任务失败需手动重启 | 自动重试和故障切换 |

---

## 调度系统选型

### 两种主流方案对比

| 维度 | Slurm | KubeSphere + Volcano |
|------|-------|---------------------|
| **定位** | HPC传统作业调度 | 云原生容器调度 |
| **适用场景** | 训练任务为主、批处理 | 推理服务+训练混合 |
| **任务类型** | 作业（Job）为单位 | 容器（Pod/Job）为单位 |
| **弹性** | 较弱（需手动扩缩容） | 强（自动弹性伸缩） |
| **学习成本** | 中等 | 较高（需了解K8s生态） |
| **昇腾支持** | 原生支持（srun直接调用NPU） | 通过device plugin支持 |
| **推荐场景** | AI训练集群 | AI推理+训练混合平台 |

### 选型决策

```
你的算力主要用来做什么？
    │
    ├── 主要是训练任务（批量作业、排队执行）
    │   └── 选择 Slurm
    │       适合：训练集群、研究机构、训练为主的企业
    │       特点：轻量级、上手简单、适合HPC场景
    │       昇腾支持原生！
    │
    └── 主要是推理服务 + 少量训练
        └── 选择 KubeSphere + Volcano
            适合：推理平台、云原生AI平台
            特点：容器化、弹性伸缩、微服务化
            昇腾通过device plugin支持！
```

---

## Slurm作业调度系统

### Slurm简介

Slurm（Simple Linux Utility for Resource Management）是HPC领域最广泛使用的作业调度系统，也是AI训练集群的首选调度方案。

**Slurm核心概念**：
- **节点（Node）**：物理服务器，如一台Atlas 800T A2
- **分区（Partition）**：节点的逻辑分组，如训练分区、推理分区
- **作业（Job）**：用户提交的计算任务
- **作业步（Step）**：作业中的子任务

### Slurm安装与配置

#### 集群架构

```
┌──────────────┐
│  登录节点     │  用户提交作业
│  (Login Node) │  ssh登录、编译代码
└──────┬───────┘
       │
┌──────┴───────┐
│  管理节点     │  Slurm管理服务
│  (Slurmctld)  │  调度器、资源管理
└──────┬───────┘
       │
┌──────┴───────────────────────┐
│  计算节点                      │
│  (Compute Nodes)               │
│  ┌─────┐ ┌─────┐ ┌─────┐      │
│  │Node1│ │Node2│ │Node3│      │
│   Ascend  Ascend  Ascend      │
│   800T    800T    800T        │
└───────────────────────────────┘
```

#### 安装步骤

```bash
# ===== 所有节点 =====
# 1. 安装Munge（认证服务）
yum install munge munge-libs munge-devel -y

# 2. 生成Munge密钥（在管理节点执行）
create-munge-key
# 将密钥分发到所有节点
scp /etc/munge/munge.key node1:/etc/munge/
scp /etc/munge/munge.key node2:/etc/munge/

# 3. 启动Munge服务
systemctl enable munge
systemctl start munge

# ===== 管理节点 =====
# 4. 安装Slurm
yum install slurm slurmctld -y

# ===== 计算节点 =====
# 5. 安装Slurm
yum install slurm slurmd -y

# ===== 配置（在管理节点） =====
# 6. 生成配置文件
# 访问 https://slurm.schedmd.com/configurator.html 生成配置
# 或手动创建 /etc/slurm/slurm.conf
```

#### 昇腾集群Slurm配置示例

```bash
# /etc/slurm/slurm.conf 关键配置

# 集群名称
ClusterName=AscendCluster

# 管理节点
SlurmctldHost=slurm-master

# 计算节点
NodeName=node[01-08] RealMemory=512000 Sockets=2 CoresPerSocket=48 State=UNKNOWN

# 分区（按用途划分）
PartitionName=training Nodes=node[01-06] MaxTime=72:00:00 Default=YES
PartitionName=inference Nodes=node[07-08] MaxTime=INFINITE State=UP
PartitionName=experimental Nodes=node[01-08] MaxTime=04:00:00 Priority=10

# 调度器配置
SchedulerType=sched/backfill     # 回填调度
SelectType=select/cons_tres      # 细粒度资源选择
SelectTypeParameters=CR_Core     # 按核分配

# 抢占配置
PreemptMode=REQUEUE
PreemptType=preempt/partition_prio
GraceTime=120                    # 被抢占后120秒优雅退出

# 日志
SlurmctldDebug=info
SlurmdDebug=info
```

### Slurm日常操作

#### 提交作业

```bash
# 方式1：交互式作业（直接在计算节点执行）
srun --partition=training --nodes=2 --ntasks-per-node=8 python train.py

# 方式2：批处理作业（提交脚本，排队执行）
sbatch train_job.sh

# 方式3：分配作业（分配资源后用户手动执行）
salloc --partition=training --nodes=1 --time=02:00:00
```

#### 训练作业脚本示例

```bash
#!/bin/bash
#SBATCH --job-name=llm_finetune          # 作业名称
#SBATCH --partition=training             # 分区
#SBATCH --nodes=2                        # 节点数
#SBATCH --ntasks-per-node=8              # 每节点任务数（对应NPU卡数）
#SBATCH --cpus-per-task=8                # 每任务CPU核数
#SBATCH --gres=npu:8                     # 每节点NPU卡数
#SBATCH --time=24:00:00                  # 最大运行时间
#SBATCH --output=logs/%j.out             # 标准输出
#SBATCH --error=logs/%j.err              # 错误输出
#SBATCH --mail-type=END,FAIL             # 邮件通知
#SBATCH --mail-user=user@company.com

# 加载环境
source /usr/local/Ascend/ascend-toolkit/set_env.sh
export GLOG_v=2

# 获取分配的节点
echo "Running on nodes: $SLURM_JOB_NODELIST"
echo "Job ID: $SLURM_JOB_ID"

# 分布式训练环境变量
export RANK_SIZE=$SLURM_NTASKS
export RANK_TABLE_FILE=./rank_table.json

# 生成rank_table
python generate_rank_table.py --nodes $SLURM_JOB_NODELIST --npus 8

# 启动训练
srun python train.py --config config.yaml --distributed True
```

#### 作业管理常用命令

```bash
# 查看作业队列
squeue
squeue -u username          # 查看某用户的作业
squeue -p training          # 查看某分区的作业

# 查看作业详情
scontrol show job <job_id>

# 取消作业
scancel <job_id>
scancel -u username         # 取消某用户所有作业

# 查看节点状态
sinfo
sinfo -p training           # 查看某分区
scontrol show node node01   # 查看某节点详情

# 查看历史作业
sacct -j <job_id> --format=JobID,JobName,Elapsed,MaxNPU,State
sacct --starttime 2026-08-01 --endtime 2026-08-26  # 按时间查询

# 查看资源使用统计
sreport cluster utilization
sreport user top            # 用户资源使用排行
```

---

## KubeSphere + Volcano调度

### 方案概述

KubeSphere是基于Kubernetes的容器平台，Volcano是K8s的高性能批处理调度器。两者结合适合构建云原生AI算力平台。

**架构**：
```
┌─────────────────────────────────┐
│       KubeSphere 控制台          │  Web管理界面
├─────────────────────────────────┤
│       Kubernetes 集群            │  容器编排
├─────────────────────────────────┤
│       Volcano 调度器             │  批处理调度
├─────────────────────────────────┤
│   昇腾 Device Plugin            │  NPU资源管理
├─────────────────────────────────┤
│   Atlas 800T A2 × N            │  硬件层
└─────────────────────────────────┘
```

### 昇腾Device Plugin部署

```bash
# 1. 安装昇腾K8s Device Plugin
# 将NPU资源注册到K8s
kubectl apply -f ascend-device-plugin.yaml

# 2. 验证NPU资源注册
kubectl describe node node01 | grep -A5 "Allocated"
# 应看到 ascend.kubectl.kubernetes.io/npu: 8

# 3. 查看节点NPU资源
kubectl get nodes -o custom-columns=NAME:.metadata.name,NPU:.status.allocatable['ascend.kubernetes.io/npu']
```

### 推理服务部署示例

```yaml
# inference-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: llm-inference
  namespace: ai-platform
spec:
  replicas: 2                    # 2个推理副本
  selector:
    matchLabels:
      app: llm-inference
  template:
    metadata:
      labels:
        app: llm-inference
    spec:
      containers:
      - name: inference
        image: ascend-llm-inference:latest
        resources:
          limits:
            ascend.kubernetes.io/npu: 2    # 每Pod申请2张NPU
            memory: 64Gi
            cpu: 16
        env:
        - name: MODEL_PATH
          value: "/models/qwen-14b"
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: llm-inference-svc
spec:
  selector:
    app: llm-inference
  ports:
  - port: 8080
    targetPort: 8080
  type: LoadBalancer
```

### Volcano训练作业示例

```yaml
# training-job.yaml
apiVersion: batch.volcano.sh/v1alpha1
kind: Job
metadata:
  name: distributed-training
spec:
  minAvailable: 2                    # 最少2个Pod就绪才开始
  schedulerName: volcano
  policies:
    - event: PodEvicted
      action: RestartJob
  tasks:
    - replicas: 2                    # 2个worker
      name: worker
      template:
        spec:
          containers:
            - name: worker
              image: ascend-training:latest
              resources:
                limits:
                  ascend.kubernetes.io/npu: 8    # 每worker 8卡
                  memory: 128Gi
                  cpu: 48
              command:
                - /bin/bash
                - -c
                - |
                  source /usr/local/Ascend/ascend-toolkit/set_env.sh
                  python train.py --distributed True --config config.yaml
          restartPolicy: OnFailure
```

---

## vNPU虚拟化分片

### 为什么需要vNPU

传统方式一张NPU卡只能分配给一个任务，导致：
- 小模型推理浪费大量算力（如7B模型推理只用了30%算力）
- 无法按需分配细粒度算力
- 资源碎片化严重

vNPU虚拟化分片将一张物理NPU切分为多个逻辑NPU，每个逻辑NPU可以独立分配给不同任务。

### vNPU切分模式

| 模式 | 切分比例 | 说明 | 适用场景 |
|------|---------|------|---------|
| 不切分 | 1:1 | 整卡分配 | 大模型训练/推理 |
| 二切分 | 1:1 | 2个等分vNPU | 中等模型推理 |
| 四切分 | 1:1:1:1 | 4个等分vNPU | 轻量模型推理 |
| 不等切分 | 1:3, 1:7 | 按需比例切分 | 混合负载 |

### vNPU操作命令

```bash
# 1. 查看物理NPU状态
npu-smi info

# 2. 查看支持的vNPU切分模式
npu-smi info -t board -i 0

# 3. 创建vNPU（以2切分为例）
# -i: NPU ID, -c: Chip ID, -f: 切分模式
npu-smi set -t create-vnpu -i 0 -c 0 -f 0    # 创建vNPU，模式0（2切分）

# 4. 查看vNPU列表
npu-smi info -t vnpu

# 5. 销毁vNPU
npu-smi set -t destroy-vnpu -i 0 -c 0 -f 0
```

### vNPU在K8s中使用

```yaml
# 使用vNPU的Pod配置
apiVersion: v1
kind: Pod
metadata:
  name: vnpu-inference
spec:
  containers:
  - name: inference
    image: ascend-inference:latest
    resources:
      limits:
        # 申请1/2 vNPU
        ascend.kubernetes.io/Ascend310P-2c: 1    # 2c表示2切分
```

### vNPU使用建议

| 场景 | 建议切分 | 理由 |
|------|---------|------|
| 70B+大模型推理 | 不切分 | 需要整卡显存和算力 |
| 7B-14B模型推理 | 二切分 | 单vNPU足够，提升并发 |
| 1B-7B模型推理 | 四切分 | 轻量模型，细粒度分配 |
| 模型微调 | 不切分 | 训练需要整卡性能 |
| 开发调试 | 四切分 | 调试不需全卡算力 |

---

## 多租户配额管理

### 配额管理架构

```
┌─────────────────────────────────────┐
│          算力总池（Total Pool）        │
│          100台 Atlas 800T A2         │
├─────────────────────────────────────┤
│  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐│
│  │团队A │  │团队B │  │团队C │  │弹性池││
│  │30台  │  │25台  │  │20台  │  │25台 ││
│  │配额30│  │配额25│  │配额20│  │弹性 ││
│  └─────┘  └─────┘  └─────┘  └─────┘│
│                                     │
│  配额：保底资源，团队可长期占用         │
│  弹性池：闲时借用，忙时回收             │
└─────────────────────────────────────┘
```

### Slurm配额管理

```bash
# slurm.conf 中配置账户和配额

# 定义账户（对应团队）
AccountName=team_a Description="AI研发团队A"
AccountName=team_b Description="AI研发团队B"
AccountName=team_c Description="产品团队C"

# 配置QoS（Quality of Service）限制
# team_a: 最大使用30台节点
# team_b: 最大使用25台节点
# team_c: 最大使用20台节点

# 创建QoS
sacctmgr add qos team_a_qos maxnodes=30
sacctmgr add qos team_b_qos maxnodes=25
sacctmgr add qos team_c_qos maxnodes=20

# 将QoS关联到账户
sacctmgr modify account team_a set qos=team_a_qos
sacctmgr modify account team_b set qos=team_b_qos
sacctmgr modify account team_c set qos=team_c_qos

# 设置配额（限制最大运行作业数和资源）
sacctmgr modify account team_a set maxjobs=10 maxsubmit=20
```

### K8s配额管理

```yaml
# ResourceQuota - 按命名空间（团队）限制资源
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-a-quota
  namespace: team-a
spec:
  hard:
    requests.ascend.kubernetes.io/npu: "30"     # 最大30张NPU
    requests.memory: 4000Gi
    requests.cpu: "1000"
    persistentvolumeclaims: "50"
    pods: "100"

---
# LimitRange - 限制单个Pod的资源
apiVersion: v1
kind: LimitRange
metadata:
  name: team-a-limits
  namespace: team-a
spec:
  limits:
  - type: Container
    max:
      ascend.kubernetes.io/npu: 8    # 单容器最多8卡
      memory: 512Gi
    min:
      ascend.kubernetes.io/npu: 1    # 最少1卡
      memory: 4Gi
```

---

## 公平调度策略

### 公平调度原则

| 原则 | 说明 | 实现方式 |
|------|------|---------|
| **配额保障** | 每个团队有保底资源 | QoS/ResourceQuota |
| **公平共享** | 闲时资源按权重公平分配 | Fair Share算法 |
| **优先级** | 紧急任务优先执行 | 优先级队列 |
| **可抢占** | 高优先级可抢占低优先级 | Preempt机制 |

### Slurm Fair Share配置

```bash
# slurm.conf 公平调度配置
PriorityType=priority/multifactor    # 多因子优先级
PriorityDecayHalfLife=7-0            # 7天半衰期
PriorityMaxAge=14-0                  # 最长排队14天提升优先级
PriorityFavorSmall=NO                # 不偏向小作业
PriorityWeightFairshare=100000       # 公平分享权重
PriorityWeightQOS=10000              # QOS权重
PriorityWeightAge=1000               # 排队时间权重

# 设置各团队的Fair Share权重
# 权重越高，闲时分配资源越多
sacctmgr modify account team_a set fairshare=3000
sacctmgr modify account team_b set fairshare=2500
sacctmgr modify account team_c set fairshare=2000
```

### 优先级计算

Slurm多因子优先级计算公式：

```
优先级 = FairShare权重 × FairShare因子 
       + QOS权重 × QOS因子
       + Age权重 × 排队时间因子
       + 分区权重 × 分区因子
       + 作业大小权重 × 作业大小因子
```

### Volcano公平调度

```yaml
# Volcano公平调度队列配置
apiVersion: scheduling.volcano.sh/v1beta1
kind: Queue
metadata:
  name: team-a-queue
spec:
  weight: 3                    # 权重3
  reclaimable: true            # 允许回收
  capability:
    cpu: "1000"
    memory: 4000Gi
    ascend.kubernetes.io/npu: "30"

---
apiVersion: scheduling.volcano.sh/v1beta1
kind: Queue
metadata:
  name: team-b-queue
spec:
  weight: 2.5
  reclaimable: true
  capability:
    cpu: "800"
    memory: 3000Gi
    ascend.kubernetes.io/npu: "25"
```

---

## 调度最佳实践

### 训练集群调度建议

1. **分区隔离**：训练和推理分区分开，避免相互影响
2. **时间限制**：训练作业设置最大运行时间，防止资源长期占用
3. **检查点保存**：长训练任务定期保存checkpoint，被抢占时可恢复
4. **弹性训练**：支持弹性batch size，适应不同资源量

### 推理集群调度建议

1. **自动伸缩**：根据负载自动扩缩容推理副本
2. **灰度发布**：新模型灰度上线，逐步替换
3. **健康检查**：推理服务健康检查，自动重启异常实例
4. **负载均衡**：请求均匀分配到各NPU卡

### 多团队共享建议

1. **明确配额**：各团队配额写入制度文件，定期评审
2. **透明报告**：每周发布资源使用报告，包括各团队利用率
3. **弹性借用**：允许闲时借用其他团队配额，忙时自动归还
4. **成本反馈**：每月向各团队反馈算力成本，促进节约使用

---

## 下一步

- [利用率优化](./utilization.md) — 提升算力利用率的方法
- [成本核算](./cost-accounting.md) — 算力成本管理与计费
- [批量部署](../setup/batch-deployment.md) — 算力集群批量部署

---

*本文档由昇腾AI解决方案架构师团队编写，持续更新中。*
*最后更新：2026-08-26*
