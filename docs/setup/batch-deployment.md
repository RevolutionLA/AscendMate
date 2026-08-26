---
layout: doc
title: 批量部署 · Ansible自动化方案
description: 昇腾集群批量部署方案：Ansible批量安装驱动/CANN、Playbook示例、配置管理、版本基线及常见问题
---

# 批量部署 · Ansible自动化方案

> **核心目标**：用自动化工具批量部署昇腾环境，实现"一次编写，N台部署"，确保环境一致性

---

## 为什么需要批量部署

当昇腾集群规模超过5台服务器时，手动部署会遇到以下问题：

| 问题 | 手动部署 | 批量部署 |
|------|---------|---------|
| 效率 | 单台1-2小时，10台需1-2天 | 10台并行30分钟完成 |
| 一致性 | 每台配置可能有差异 | 所有节点配置完全一致 |
| 可重复性 | 无法精确复现 | Playbook版本化管理 |
| 可审计性 | 无操作记录 | 完整执行日志 |
| 故障恢复 | 出错需逐台排查 | 自动重试 + 错误报告 |

---

## Ansible批量部署方案

### Ansible简介

Ansible是开源的IT自动化工具，具有以下优势：
- **无Agent**：无需在目标节点安装客户端，通过SSH管理
- **幂等性**：多次执行结果一致，不会重复操作
- **易学习**：YAML语法，学习成本低
- **模块化**：丰富的内置模块，支持自定义模块
- **昇腾友好**：通过shell/script模块可执行任何昇腾命令

### 集群架构

```
┌──────────────────┐
│  Ansible控制机     │  编写Playbook，执行部署
│  (管理节点)        │  存放安装包和配置
└────────┬─────────┘
         │ SSH
    ┌────┴────────────────────────────┐
    │           昇腾计算节点             │
    │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐│
    │  │node1│ │node2│ │node3│ │node4││
    │  └─────┘ └─────┘ └─────┘ └─────┘│
    │  ┌─────┐ ┌─────┐ ┌─────┐ ┌─────┐│
    │  │node5│ │node6│ │node7│ │node8││
    │  └─────┘ └─────┘ └─────┘ └─────┘│
    └─────────────────────────────────┘
```

### Ansible安装

```bash
# 在控制机上安装Ansible（推荐使用pip）
pip install ansible

# 或使用yum
yum install epel-release -y
yum install ansible -y

# 验证安装
ansible --version
```

### 主机清单配置

```ini
# /etc/ansible/hosts 或项目目录下的 inventory.ini

# 昇腾训练集群
[training_nodes]
node01 ansible_host=192.168.1.101 npu_count=8
node02 ansible_host=192.168.1.102 npu_count=8
node03 ansible_host=192.168.1.103 npu_count=8
node04 ansible_host=192.168.1.104 npu_count=8
node05 ansible_host=192.168.1.105 npu_count=8
node06 ansible_host=192.168.1.106 npu_count=8

# 昇腾推理集群
[inference_nodes]
node07 ansible_host=192.168.1.107 npu_count=8
node08 ansible_host=192.168.1.108 npu_count=8

# 管理节点
[management]
slurm-master ansible_host=192.168.1.10

# 全部节点
[ascend_cluster:children]
training_nodes
inference_nodes
management

# 全局变量
[ascend_cluster:vars]
ansible_user=root
ansible_ssh_private_key_file=~/.ssh/id_rsa
ansible_python_interpreter=/usr/bin/python3

# CANN版本
cann_version=7.0.0
driver_version=23.0.0
firmware_version=6.3.0
```

### SSH免密配置

```bash
# 在控制机生成密钥
ssh-keygen -t rsa -b 4096

# 分发公钥到所有节点
for host in 192.168.1.{101..108}; do
    ssh-copy-id root@$host
done

# 验证连通性
ansible ascend_cluster -m ping
# 预期输出：所有节点返回 SUCCESS
```

---

## Playbook示例：批量安装驱动/CANN

### 目录结构

```
ascend-deploy/
├── inventory.ini              # 主机清单
├── site.yml                   # 主入口Playbook
├── playbooks/
│   ├── 00-prerequisites.yml   # 系统准备
│   ├── 01-driver.yml          # 安装NPU驱动
│   ├── 02-firmware.yml        # 升级NPU固件
│   ├── 03-cann.yml            # 安装CANN工具包
│   ├── 04-mindspore.yml       # 安装MindSpore
│   ├── 05-mindformers.yml     # 安装MindFormers
│   ├── 06-verify.yml          # 环境验证
│   └── 07-slurm.yml           # 安装Slurm调度
├── roles/
│   ├── prerequisites/
│   ├── driver/
│   ├── cann/
│   └── ...
├── files/                     # 安装包存放
│   ├── Ascend-hdk-910b-npu-driver_23.0.0_linux-x86_64.run
│   ├── Ascend-hdk-910b-npu-firmware_6.3.0.run
│   ├── Ascend-cann-toolkit_7.0.0_linux-x86_64.run
│   └── ...
├── templates/                 # 配置模板
│   ├── hccn.conf.j2
│   ├── mindspore_env.j2
│   └── ...
└── group_vars/
    └── all.yml                # 全局变量
```

### 全局变量

```yaml
# group_vars/all.yml

# 软件版本
driver_version: "23.0.0"
firmware_version: "6.3.0"
cann_version: "7.0.0"
mindspore_version: "2.3.0"
mindformers_version: "1.2.0"

# 安装路径
ascend_home: "/usr/local/Ascend"
cann_home: "{{ ascend_home }}/ascend-toolkit/latest"

# NPU配置
npu_count: 8
hccn_config:
  - { device_id: 0, ip: "192.168.100.101", netmask: "255.255.255.0", gateway: "192.168.100.1" }
  - { device_id: 1, ip: "192.168.100.102", netmask: "255.255.255.0", gateway: "192.168.100.1" }
  - { device_id: 2, ip: "192.168.100.103", netmask: "255.255.255.0", gateway: "192.168.100.1" }
  - { device_id: 3, ip: "192.168.100.104", netmask: "255.255.255.0", gateway: "192.168.100.1" }
  - { device_id: 4, ip: "192.168.100.105", netmask: "255.255.255.0", gateway: "192.168.100.1" }
  - { device_id: 5, ip: "192.168.100.106", netmask: "255.255.255.0", gateway: "192.168.100.1" }
  - { device_id: 6, ip: "192.168.100.107", netmask: "255.255.255.0", gateway: "192.168.100.1" }
  - { device_id: 7, ip: "192.168.100.108", netmask: "255.255.255.0", gateway: "192.168.100.1" }

# 系统配置
max_user_processes: 65535
max_open_files: 65535
tcp_tw_reuse: 1
```

### 主入口Playbook

```yaml
# site.yml
---
- name: 昇腾集群全量部署
  hosts: ascend_cluster
  become: yes
  serial: 2  # 每次部署2台，避免同时重启全部节点
  
  tasks:
    - name: 导入系统准备
      import_playbook: playbooks/00-prerequisites.yml
    
    - name: 安装NPU驱动
      import_playbook: playbooks/01-driver.yml
    
    - name: 升级NPU固件
      import_playbook: playbooks/02-firmware.yml
    
    - name: 安装CANN工具包
      import_playbook: playbooks/03-cann.yml
    
    - name: 安装MindSpore
      import_playbook: playbooks/04-mindspore.yml
    
    - name: 安装MindFormers
      import_playbook: playbooks/05-mindformers.yml
    
    - name: 环境验证
      import_playbook: playbooks/06-verify.yml
```

### Playbook: 系统准备

```yaml
# playbooks/00-prerequisites.yml
---
- name: 系统准备
  hosts: ascend_cluster
  become: yes
  tasks:
    # 1. 安装依赖包
    - name: 安装系统依赖
      yum:
        name:
          - gcc
          - gcc-c++
          - make
          - cmake
          - unzip
          - zlib-devel
          - openssl-devel
          - pciutils
          - net-tools
          - python3
          - python3-pip
        state: present
    
    # 2. 配置系统参数
    - name: 配置最大进程数
      sysctl:
        name: kernel.pid_max
        value: "{{ max_user_processes }}"
        state: present
    
    - name: 配置最大文件描述符
      lineinfile:
        path: /etc/security/limits.conf
        line: "{{ item }}"
      with_items:
        - "* soft nofile {{ max_open_files }}"
        - "* hard nofile {{ max_open_files }}"
        - "* soft nproc {{ max_user_processes }}"
        - "* hard nproc {{ max_user_processes }}"
    
    # 3. 关闭防火墙
    - name: 关闭firewalld
      systemd:
        name: firewalld
        state: stopped
        enabled: no
    
    # 4. 关闭SELinux
    - name: 关闭SELinux
      selinux:
        state: disabled
    
    # 5. 配置时间同步
    - name: 安装chrony
      yum:
        name: chrony
        state: present
    
    - name: 配置时间同步服务器
      lineinfile:
        path: /etc/chrony.conf
        regexp: "^server "
        line: "server ntp.company.com iburst"
      notify: restart chrony
    
    # 6. 创建用户和目录
    - name: 创建昇腾安装目录
      file:
        path: "{{ ascend_home }}"
        state: directory
        mode: '0755'
    
    - name: 创建日志目录
      file:
        path: /var/log/ascend
        state: directory
        mode: '0755'
  
  handlers:
    - name: restart chrony
      systemd:
        name: chronyd
        state: restarted
        enabled: yes
```

### Playbook: 安装NPU驱动

```yaml
# playbooks/01-driver.yml
---
- name: 安装NPU驱动
  hosts: ascend_cluster
  become: yes
  tasks:
    # 1. 检查是否已安装驱动
    - name: 检查NPU驱动状态
      command: npu-smi info
      register: npu_status
      ignore_errors: yes
      changed_when: false
    
    # 2. 安装驱动（如果未安装）
    - name: 安装NPU驱动
      command: >
        ./files/Ascend-hdk-910b-npu-driver_{{ driver_version }}_linux-x86_64.run
        --install
        --quiet
      when: npu_status.rc != 0
      register: driver_install
      timeout: 600
    
    # 3. 重启节点
    - name: 重启节点
      reboot:
        reboot_timeout: 300
      when: npu_status.rc != 0
    
    # 4. 验证驱动安装
    - name: 验证NPU驱动
      command: npu-smi info
      register: npu_verify
      changed_when: false
    
    - name: 显示NPU状态
      debug:
        var: npu_verify.stdout_lines
    
    # 5. 检查NPU卡数量
    - name: 检查NPU卡数量
      assert:
        that:
          - "'Total Count : {{ npu_count }}' in npu_verify.stdout"
        fail_msg: "NPU卡数量不正确，期望 {{ npu_count }} 张"
        success_msg: "NPU卡数量正确: {{ npu_count }} 张"
```

### Playbook: 安装CANN

```yaml
# playbooks/03-cann.yml
---
- name: 安装CANN工具包
  hosts: ascend_cluster
  become: yes
  tasks:
    # 1. 创建CANN安装用户（不推荐root安装）
    - name: 创建HwHiAiUser用户
      user:
        name: HwHiAiUser
        group: HwHiAiUser
        shell: /bin/bash
        create_home: yes
      when: ansible_user != "HwHiAiUser"
    
    # 2. 安装CANN工具包
    - name: 安装CANN Toolkit
      command: >
        ./files/Ascend-cann-toolkit_{{ cann_version }}_linux-x86_64.run
        --install
        --quiet
      environment:
        LD_LIBRARY_PATH: ""
      register: cann_install
      timeout: 1800
    
    - name: 显示安装结果
      debug:
        var: cann_install.stdout_lines[-5:]
    
    # 3. 安装CANN Kernels（可选，提升算子性能）
    - name: 安装CANN Kernels
      command: >
        ./files/Ascend-cann-kernels-910b_{{ cann_version }}_linux-x86_64.run
        --install
        --quiet
      timeout: 1800
    
    # 4. 配置环境变量
    - name: 配置CANN环境变量
      template:
        src: templates/cann_env.j2
        dest: /etc/profile.d/cann_env.sh
        mode: '0644'
    
    # 5. 验证CANN安装
    - name: 验证CANN版本
      shell: source /etc/profile.d/cann_env.sh && cat {{ cann_home }}/version.cfg
      register: cann_version_check
      changed_when: false
    
    - name: 显示CANN版本
      debug:
        var: cann_version_check.stdout_lines
```

### 配置模板

```jinja2
# templates/cann_env.j2
# CANN环境变量配置

# 工具包路径
export ASCEND_HOME={{ ascend_home }}
export ASCEND_TOOLKIT_HOME={{ cann_home }}

# 环境变量
source ${ASCEND_TOOLKIT_HOME}/set_env.sh

# MindSpore相关
export GLOG_v=2
export HCCL_CONNECT_TIMEOUT=7200
export HCCL_EXEC_TIMEOUT=0
export ASCEND_SLOG_PRINT_TO_STDOUT=0

# 性能优化
export MS_DEV_ENABLE_KERNEL_SORT=1
export MS_DEV_ENABLE_LOOP_SINK=1
```

```jinja2
# templates/hccn.conf.j2
# HCCN网络配置
{% for item in hccn_config %}
device_{{ item.device_id }}:{{ item.ip }}:{{ item.netmask }}:{{ item.gateway }}
{% endfor %}
```

### Playbook: 环境验证

```yaml
# playbooks/06-verify.yml
---
- name: 环境验证
  hosts: ascend_cluster
  tasks:
    # 1. NPU状态验证
    - name: 验证NPU状态
      shell: source /etc/profile.d/cann_env.sh && npu-smi info
      register: npu_info
      changed_when: false
    
    - name: 显示NPU状态
      debug:
        var: npu_info.stdout_lines
    
    # 2. MindSpore验证
    - name: 验证MindSpore安装
      shell: |
        source /etc/profile.d/cann_env.sh
        python3 -c "import mindspore as ms; ms.set_context(device_target='Ascend'); print('MindSpore版本:', ms.__version__); print('设备:', ms.context.get_context('device_target'))"
      register: ms_verify
      changed_when: false
      ignore_errors: yes
    
    - name: 显示MindSpore验证结果
      debug:
        var: ms_verify.stdout_lines
    
    # 3. 计算能力验证
    - name: 验证NPU计算能力
      shell: |
        source /etc/profile.d/cann_env.sh
        python3 -c "
        import mindspore as ms
        import numpy as np
        ms.set_context(device_target='Ascend', device_id=0)
        x = ms.Tensor(np.ones([1024, 1024], dtype=np.float16))
        y = ms.Tensor(np.ones([1024, 1024], dtype=np.float16))
        z = ms.ops.matmul(x, y)
        print('矩阵乘法验证: 通过')
        print('结果形状:', z.shape)
        print('结果值(前5):', z.asnumpy()[0][:5])
        "
      register: compute_verify
      changed_when: false
    
    - name: 显示计算验证结果
      debug:
        var: compute_verify.stdout_lines
    
    # 4. 生成验证报告
    - name: 生成验证报告
      copy:
        content: |
          昇腾环境验证报告
          =================
          节点: {{ inventory_hostname }}
          IP: {{ ansible_host }}
          日期: {{ ansible_date_time.date }}
          
          NPU状态:
          {{ npu_info.stdout }}
          
          MindSpore:
          {{ ms_verify.stdout }}
          
          计算验证:
          {{ compute_verify.stdout }}
        dest: /var/log/ascend/verify_report_{{ ansible_date_time.date }}.txt
      become: yes
```

### 执行部署

```bash
# 1. 测试连通性
ansible ascend_cluster -m ping

# 2. 执行全量部署（建议先在1台测试）
ansible-playbook site.yml -l node01

# 3. 验证测试结果
ansible node01 -m shell -a "source /etc/profile.d/cann_env.sh && npu-smi info"

# 4. 批量部署（serial控制并发数）
ansible-playbook site.yml --serial 2

# 5. 只部署特定步骤
ansible-playbook playbooks/03-cann.yml  # 只安装CANN

# 6. 查看执行结果
ansible-playbook site.yml --check  # 干跑模式，不实际执行
```

---

## 配置管理

### 环境快照

部署完成后，生成环境快照用于版本管理和故障恢复：

```bash
#!/bin/bash
# 生成环境快照 - snapshot.sh

SNAPSHOT_DIR="/opt/ascend-snapshots/$(date +%Y%m%d_%H%M%S)"
mkdir -p $SNAPSHOT_DIR

# 1. 系统信息
echo "=== 系统信息 ===" > $SNAPSHOT_DIR/system_info.txt
cat /etc/os-release >> $SNAPSHOT_DIR/system_info.txt
uname -r >> $SNAPSHOT_DIR/system_info.txt

# 2. NPU信息
echo "=== NPU信息 ===" > $SNAPSHOT_DIR/npu_info.txt
npu-smi info >> $SNAPSHOT_DIR/npu_info.txt 2>&1
for i in $(seq 0 7); do
    echo "--- NPU $i ---" >> $SNAPSHOT_DIR/npu_info.txt
    npu-smi info -t board -i $i >> $SNAPSHOT_DIR/npu_info.txt 2>&1
done

# 3. CANN版本
echo "=== CANN版本 ===" > $SNAPSHOT_DIR/cann_version.txt
cat /usr/local/Ascend/ascend-toolkit/latest/version.cfg >> $SNAPSHOT_DIR/cann_version.txt 2>&1

# 4. Python包列表
pip3 list > $SNAPSHOT_DIR/python_packages.txt 2>&1

# 5. 环境变量
env | grep -i "ascend\|cann\|mindspore" > $SNAPSHOT_DIR/env_vars.txt 2>&1

# 6. 网络配置
echo "=== 网络配置 ===" > $SNAPSHOT_DIR/network_config.txt
cat /etc/hccn.conf >> $SNAPSHOT_DIR/network_config.txt 2>&1
ip addr show >> $SNAPSHOT_DIR/network_config.txt 2>&1

# 7. 压缩归档
tar -czf ${SNAPSHOT_DIR}.tar.gz -C /opt/ascend-snapshots $(basename $SNAPSHOT_DIR)
rm -rf $SNAPSHOT_DIR

echo "环境快照已生成: ${SNAPSHOT_DIR}.tar.gz"
```

### 版本基线管理

```yaml
# version_baseline.yml - 版本基线文件
# 所有节点的标准版本配置

baseline:
  os: "EulerOS 2.0 (SP8)"
  kernel: "4.19.36"
  npu_driver: "23.0.0"
  npu_firmware: "6.3.0"
  cann: "7.0.0"
  mindspore: "2.3.0"
  mindformers: "1.2.0"
  python: "3.9.2"
  slurm: "22.05.8"
  
# 各节点实际版本（由采集脚本自动更新）
nodes:
  node01:
    cann: "7.0.0"
    mindspore: "2.3.0"
    status: "compliant"
  node02:
    cann: "7.0.0"
    mindspore: "2.2.1"  # 版本不一致
    status: "non-compliant"
```

### 版本合规检查

```yaml
# playbooks/version_check.yml
---
- name: 版本合规检查
  hosts: ascend_cluster
  tasks:
    - name: 检查CANN版本
      shell: cat /usr/local/Ascend/ascend-toolkit/latest/version.cfg | head -1
      register: actual_cann
      changed_when: false
    
    - name: 对比CANN版本
      assert:
        that:
          - "'{{ cann_version }}' in actual_cann.stdout"
        fail_msg: "CANN版本不合规: 实际{{ actual_cann.stdout }} vs 期望{{ cann_version }}"
        success_msg: "CANN版本合规: {{ cann_version }}"
    
    - name: 检查MindSpore版本
      shell: source /etc/profile.d/cann_env.sh && python3 -c "import mindspore; print(mindspore.__version__)"
      register: actual_ms
      changed_when: false
    
    - name: 对比MindSpore版本
      assert:
        that:
          - "'{{ mindspore_version }}' in actual_ms.stdout"
        fail_msg: "MindSpore版本不合规: 实际{{ actual_ms.stdout }} vs 期望{{ mindspore_version }}"
        success_msg: "MindSpore版本合规: {{ mindspore_version }}"
    
    - name: 生成合规报告
      copy:
        content: |
          版本合规报告 - {{ inventory_hostname }}
          CANN: {{ actual_cann.stdout }} (期望: {{ cann_version }})
          MindSpore: {{ actual_ms.stdout }} (期望: {{ mindspore_version }})
        dest: /var/log/ascend/compliance_{{ ansible_date_time.date }}.txt
      become: yes
```

---

## 批量部署常见问题

### 问题一：SSH连接超时

**现象**：Ansible执行时报SSH连接超时错误。

**解决方案**：

```ini
# inventory.ini 中增加超时配置
[ascend_cluster:vars]
ansible_timeout=60
ansible_ssh_common_args='-o ConnectTimeout=60 -o ServerAliveInterval=30'
```

```bash
# 检查SSH连通性
ansible ascend_cluster -m ping -vvv

# 如果部分节点不通，检查：
# 1. 网络连通性：ping <ip>
# 2. SSH服务状态：systemctl status sshd
# 3. 防火墙规则：iptables -L
# 4. SSH配置：/etc/ssh/sshd_config 中 AllowUsers/DenyUsers
```

### 问题二：驱动安装失败

**现象**：NPU驱动安装报错。

**排查步骤**：

```bash
# 1. 检查内核版本兼容性
uname -r
# 确认内核版本在驱动支持列表中

# 2. 检查是否有残留驱动
lsmod | grep drv_pci_host
# 如有残留，先卸载
rmmod drv_pci_host

# 3. 检查依赖
rpm -qa | grep -E "kernel-devel|kernel-headers"
# 确认kernel-devel已安装且版本匹配

# 4. 查看安装日志
cat /var/log/ascend_seclog/ascend_install.log
```

### 问题三：CANN安装后找不到NPU

**现象**：CANN安装成功，但运行MindSpore时报"no NPU available"。

**解决方案**：

```bash
# 1. 检查环境变量是否加载
echo $ASCEND_TOOLKIT_HOME
# 应为 /usr/local/Ascend/ascend-toolkit/latest

# 2. 重新加载环境变量
source /usr/local/Ascend/ascend-toolkit/set_env.sh

# 3. 检查NPU设备文件
ls -la /dev/davinci*
# 应看到 /dev/davinci0 ~ /dev/davinci7

# 4. 检查权限
ls -la /dev/davinci_manager
# 确认当前用户有访问权限

# 5. 检查用户组
groups
# 用户应在 HwHiAiUser 组中
usermod -aG HwHiAiUser $USER
```

### 问题四：版本不匹配

**现象**：CANN与驱动/固件版本不匹配，运行报错。

**解决方案**：

```bash
# 1. 查看版本配套表
# 访问昇腾官方文档确认版本配套关系

# 2. 统一升级到配套版本
# 先升级驱动+固件，再升级CANN

# 3. 使用Ansible批量升级
ansible-playbook playbooks/01-driver.yml -e "driver_version=23.0.1"
ansible-playbook playbooks/02-firmware.yml -e "firmware_version=6.3.1"
ansible-playbook playbooks/03-cann.yml -e "cann_version=7.0.1"
```

### 问题五：并行部署导致网络拥塞

**现象**：批量部署时多台节点同时下载安装包，导致网络拥塞。

**解决方案**：

```yaml
# 方案1：控制并发数
# site.yml中设置serial
serial: 2  # 每次只部署2台

# 方案2：本地文件分发（推荐）
# 将安装包放在Ansible控制机，通过copy模块分发
- name: 分发NPU驱动安装包
  copy:
    src: files/Ascend-hdk-910b-npu-driver_23.0.0_linux-x86_64.run
    dest: /tmp/
    mode: '0755'

# 方案3：使用NFS共享存储
# 将安装包放在NFS共享目录，所有节点从NFS读取
```

---

## 部署最佳实践

### 部署前

1. **准备安装包**：所有安装包下载到控制机，验证MD5
2. **网络规划**：NPU RoCE网络IP规划，避免冲突
3. **测试验证**：先在1台节点完整跑一遍Playbook
4. **备份准备**：如有已有环境，先做备份

### 部署中

1. **分批执行**：使用`serial`控制并发，避免批量重启
2. **实时监控**：观察执行输出，及时发现错误
3. **错误处理**：单台失败不影响其他节点
4. **日志记录**：`ansible-playbook site.yml -vvv | tee deploy.log`

### 部署后

1. **全量验证**：执行验证Playbook，确认所有节点正常
2. **版本基线**：生成版本基线文件，记录各节点配置
3. **环境快照**：执行快照脚本，保存环境状态
4. **文档归档**：部署日志/版本基线/快照归档

---

## 下一步

- [交付验收](./delivery-acceptance.md) — 部署前的硬件验收
- [算力运营管理](../operations/index.md) — 部署后运营管理
- [调度管理](../operations/scheduling.md) — 集群调度配置

---

*本文档由昇腾AI解决方案架构师团队编写，持续更新中。*
*最后更新：2026-08-26*
