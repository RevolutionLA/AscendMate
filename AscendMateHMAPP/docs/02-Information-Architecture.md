# 02 信息架构与页面结构

## 1. 设计原则

1. **浅层化**：任意内容在 3 次点击内可达
2. **拇指优先**：核心操作放在屏幕下半区（拇指易达区）
3. **场景驱动**：按「我想做什么」组织导航，而非按技术堆栈
4. **延续网页**：与 AscendMate 网页信息架构保持一致，降低迁移学习成本

## 2. 整体信息架构

```
昇腾之家 AscendMate
├── 首页 (Home)
│   ├── 顶部搜索入口
│   ├── 快捷功能宫格（6宫格）
│   ├── 今日推荐 / 精选文章
│   ├── 生态组件（MindIE/vLLM/SGLang…）
│   └── 继续阅读（最近阅读）
├── 三分类
│   ├── 学习 (Learn)
│   │   ├── 学习路径总览
│   │   └── 六阶段课程
│   ├── 场景 (Scenes)
│   │   ├── 场景价值（金融/医疗/政务/制造）
│   │   └── POC 指南
│   └── 资源 (Resources)
│       ├── 链接导航
│       ├── 样例与模型
│       ├── 下载
│       └── 社区
├── 技术导航 (Docs)
│   ├── 快速开始（Guide）
│   ├── 环境搭建（Setup）
│   ├── 大模型训练（Training）
│   ├── 模型推理（Inference）
│   ├── 算子开发（Ops）
│   ├── 工具链（Tools）
│   ├── 运维监控（Monitoring）
│   ├── 算力运营（Operations）
│   ├── 昇腾硬件（Hardware）
│   └── 问题定位（FAQ）
└── 我的 (Mine)
    ├── 收藏夹
    ├── 阅读历史
    ├── 学习进度
    ├── 设置（主题/字体/语言/引导重播）
    └── 关于
```

## 3. 底部导航设计（TabBar）

采用 **4 Tab 结构**，符合手机端拇指操作：

| Tab | 名称 | 图标 | 核心内容 |
|-----|------|------|----------|
| 1 | 首页 | 房子 | 推荐、入口、继续阅读 |
| 2 | 知识库 | 书籍 | 三分类 + 技术导航全集 |
| 3 | 搜索 | 放大镜 | 全局搜索、热搜、历史 |
| 4 | 我的 | 人形 | 收藏、历史、设置 |

点击 Tab 页面切换，长按 Tab 显示快捷菜单（鸿蒙特性，可选）。

## 4. 页面清单

### 4.1 一级页面（Tab 页面）

| 页面 | 路由 | 简述 |
|------|------|------|
| 首页 | `pages/Index` | 个性化推荐、快捷入口 |
| 知识库 | `pages/Knowledge` | 全部内容的分类门户 |
| 搜索 | `pages/Search` | 搜索输入、结果、历史 |
| 我的 | `pages/Mine` | 个人数据与设置 |

### 4.2 二级页面

| 页面 | 路由 | 入口 | 简述 |
|------|------|------|------|
| 分类列表 | `pages/CategoryList` | 知识库/首页 | 分类下文章列表 |
| 列表 | `pages/DocList` | 分类列表 | 文章列表 |
| 文章详情 | `pages/DocDetail` | 列表/搜索 | Markdown 渲染页面 |
| 搜索结果 | `pages/SearchResult` | 搜索 | 结果列表 |
| 收藏夹 | `pages/Favorites` | 我的 | 收藏文章管理 |
| 阅读历史 | `pages/History` | 我的 | 历史记录 |
| 学习路径 | `pages/LearningPath` | 学习分类 | 六阶段路径 |
| 学习详情 | `pages/LearningDetail` | 学习路径 | 阶段内课程 |
| 设置 | `pages/Settings` | 我的 | 偏好设置 |
| 关于 | `pages/About` | 我的 | 版本、声明、开源信息 |

### 4.3 弹层/浮层

| 浮层 | 触发 | 功能 |
|------|------|------|
| 文章目录浮层 | 文章页右上角目录按钮 | 章节锚点跳转 |
| 分享面板 | 文章页分享按钮 | 系统分享 |
| 字号面板 | 文章页字号按钮 | 调节字号 |
| 分类筛选面板 | 知识库页筛选按钮 | 过滤分类 |

## 5. 内容分类与映射

### 5.1 知识库三分类（对应网页一级导航）

**「学习」分类** → 来源：`docs/learning/`

| 子项 | 来源文件 |
|------|----------|
| 学习路径总览 | `learning/index.md` |
| 阶段一 · AI 基础认知 | `learning/ai-fundamentals.md` |
| 阶段二 · 数学与编程基础 | `learning/math-programming.md` |
| 阶段三 · 深度学习入门 | `learning/deep-learning.md` |
| 阶段四 · 大模型技术栈 | `learning/llm-basics.md` |
| 阶段五 · 昇腾生态实战 | `learning/ascend-hands-on.md` |
| 阶段六 · 行业应用进阶 | `learning/industry-applications.md` |

**「场景」分类** → 来源：`docs/scenes/`

| 子项 | 来源文件 |
|------|----------|
| 场景价值总览 | `scenes/index.md` |
| 金融行业 | `scenes/finance.md` |
| 医疗行业 | `scenes/healthcare.md` |
| 政务行业 | `scenes/government.md` |
| 制造行业 | `scenes/manufacturing.md` |
| 快速 POC 指南 | `scenes/poc-guide.md` |

**「资源」分类** → 来源：`docs/resources/`

| 子项 | 来源文件 |
|------|----------|
| 资源导航 | `resources/links.md` |
| 样例代码与模型 | `resources/samples-models.md` |
| 镜像与软件下载 | `resources/download.md` |
| 生态与社区 | `resources/community.md` |

### 5.2 技术导航（对应网页侧边栏）

| 大项 | 包含子项 | 来源 |
|------|----------|------|
| 快速开始 | 认识 AscendMate、典型部署场景、选择路径、7步走、全景 | `guide/` |
| 环境搭建 | 上电规划→系统→驱动→CANN→PyTorch→MindSpore→Docker→自检 | `setup/` |
| 大模型训练 | LLaMA-Factory、MindSpeed、PyTorch 迁移、MindSpore 迁移 | `training/` |
| 模型推理 | MindIE、vLLM-Ascend、SGLang、Dify | `inference/` |
| 算子开发 | Ascend C、Triton-Ascend、CATLASS | `ops/` |
| 工具链 | MindStudio、精度调试、性能调优 | `tools/` |
| 运维监控 | NPU 指标、Prometheus+Grafana、告警、巡检、日志 | `monitoring/` |
| 算力运营 | 利用率、调度、成本核算 | `operations/` |
| 昇腾硬件 | 集群、A2/A3 服务器、推理卡、开发套件 | `hardware/` |
| 问题定位 | 环境/训练/推理/性能精度 FAQ | `faq/` |

## 6. 信息架构维护

- 内容目录树由仓库 `docs/` 结构自动生成（CI 构建时同步写入 rawfile/catalog.json）
- 分类标签由文档 frontmatter 控制，构建脚本读取
- 新增或修改内容后 → 重跑构建管线 → 重新打包 HAP → 通过版本发布分发
