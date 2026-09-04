# 07 技术架构方案

## 1. 技术选型

| 项 | 选型 | 说明 |
|----|------|------|
| 系统版本 | HarmonyOS NEXT（API 12+） | 纯血鸿蒙，不兼容安卓 APK |
| 开发语言 | ArkTS（TypeScript 超集） | 鸿蒙一等公民语言 |
| UI 框架 | ArkUI（声明式） | 状态驱动，与 Flutter/SwiftUI 理念一致 |
| 开发工具 | DevEco Studio 5.x | 官方 IDE，内置模拟器 |
| 包管理 | ohpm（OpenHarmony Package Manager） | |
| 持久化 | 关系型数据库 RDB + Preferences | ArkData 组件 |
| 网络 | @ohos.net.http / axios-ohos | |
| 状态管理 | AppStorage / LocalStorage / V2 | 官方推荐 |
| 路由 | Navigation（系统路由）+ Router | |
| 卡片 | FormExtensionAbility（ArkTS Widget） | |
| 元服务 | Atomic Service（共享工程） | |
| 云同步（可选） | 华为云数据库 / iCloud 不可用 → AGC CloudDB | HarmonyOS 原生云数据库 |

**不使用 WebView 套壳** — 保证原生体验、离线能力、系统级特性整合。

## 2. 工程结构

```
AscendMate/
├── AppScope/                     # 应用级配置
│   ├── app.json5                  # 全局配置（名称、版本、图标）
│   └── resources/                 # 全局资源
├── entry/                        # 主模块（主 APP）
│   ├── src/main/
│   │   ├── ets/
│   │   │   ├── entryability/      # UIAbility 入口
│   │   │   ├── pages/             # 页面（Index, Detail, Search...）
│   │   │   ├── common/            # 公共组件（卡片、代码块、标签...）
│   │   │   ├── model/             # 数据模型
│   │   │   ├── service/           # 网络/缓存/索引服务
│   │   │   └── utils/             # 工具函数（markdown 解析封装等）
│   │   └── resources/             # 语言、图标、主题资源
│   └── src/test/                  # 单测
├── widgets/                      # 桌面卡片模块（ArkTS Widget）
│   └── src/main/ets/widget/       # FormExtensionAbility + 卡片布局
├── atomic/                       # 元服务模块（共享代码）
│   └── src/main/ets/              # 搜索/文章速览元服务
├── oh-package.json5              # 依赖声明
└── build-profile.json5           # 构建配置
```

## 3. 数据架构

### 3.1 内容管道（Content Pipeline）

```
GitHub 仓库 docs/*.md
        │  CI（GitHub Actions）构建
        ▼
modules/  →  content-index.json（目录树+元数据）
                 │
        ├─ 内容拉取（raw MD 按需下载）
        │
        ▼
    HarmonyosAApp 打包资源（首次内置全集）
                 │
        └─ OTA 更新（后端增量包 / 直接拉 GitHub raw）
```

**决策：v1 采用「首次安装内置全集 + 增量 OTA 更新」策略**

理由：
- 昇腾资料总量约 10-30MB（文本），完全可接受内置
- 离线可用是移动端核心体验（机房弱网场景）
- 更新采用对比目录树 `content-index.json`，只下载变化文件

### 3.2 数据模型（TypeScript）

```typescript
/** 分类节点（目录树） */
interface CategoryNode {
  id: string;          // 唯一 id
  title: string;       // 分类名
  icon?: string;       // 图标
  order: number;       // 排序
  parentId: string | null;
  children?: CategoryNode[];
}

/** 文档元数据（frontmatter） */
interface DocMeta {
  id: string;
  title: string;
  category: string;        // 所属分类
  tags: string[];          // 标签
  summary?: string;        // 摘要
  readingTime: number;     // 分钟
  fileName: string;        // 源文件名
  updatedAt: string;       // 更新时间
  order?: number;          // 同分类排序
}

/** 本地状态 */
interface LocalState {
  favorites: Favorites[];   // 收藏夹
  history: HistoryItem[];   // 阅读历史
  progress: ProgressMap;    // 进度记录 {docId: scrollPercent}
  settings: UserSettings;   // 偏好
}
```

### 3.3 存储方案

| 数据 | 技术 | 理由 |
|------|------|------|
| 收藏夹/历史/进度 | RDB（Relational Store） | 结构化、可查询 |
| 用户偏好 | Preferences | 键值对、轻量 |
| 内容文件缓存 | 沙箱文件系统（filesDir） | 大文件、按需删除 |
| 搜索索引（元数据） | 内存 + JSON 文件 | 轻量级倒排索引 |
| 图片缓存 | LruCache + 文件缓存 | 系统级缓存策略 |

## 4. 搜索方案

### 4.1 本地搜索（v1 核心）

- **索引范围**：文章标题 + 正文纯文本（构建时生成索引片段）
- **算法**：简单倒排索引（分词 + 词频），中文分词采用轻量方案（按字符 n-gram + 关键词词组匹配）
- **匹配**：关键词子串匹配 + 相关性排序（标题命中 > 标签命中 > 正文命中）
- **高亮**：前后指针标记命中片段

### 4.2 增强搜索（v2 可选）

- 集成**系统搜索能力**（@ohos.intent）让 APP 内容出现在系统全局搜索中
- 或接入云端搜索 API（后端 Elasticsearch）支持语义搜索

## 5. Markdown 渲染方案

### 5.1 技术选择

| 方案 | 优缺点 | 决策 |
|------|--------|------|
| 原生 Web 组件（WebView）渲染 MD | 成熟但性能/一致性差 | ❌ |
| 自研 ArkTS 渲染器 | 可控、原生 | ✅ v1 |
| 第三方渲染库（@ohos/markdown） | 快速但局限 | 备选 |

**决策：自研 Markdown 渲染器（渲染为 ArkUI 组件树）**

核心考虑：
- 纯 ArkUI 渲染 → 完美支持深色模式、无障碍、系统动效
- 代码高亮使用本地 `highlight.js` 子集（或自研轻量高亮）
- 表格/图片/引用块/代码块/列表/标题全覆盖

### 5.2 渲染组件树

```
MarkdownDocView
├── TitleBlock
├── MetaInfo (阅读时间/分类/标签)
├── Section H1/H2/H3 (带锚点)
├── ParagraphBlock (支持行内 code/加粗/链接)
├── CodeBlock (深色卡片+复制+高亮+横向滚动)
├── QuoteBlock (左边线+背景)
├── ListBlock (有序/无序)
├── TableBlock (横向滚动容器)
├── ImageBlock (点击放大)
├── TipBlock (提示/注意/警告区分)
└── LinkBlock (站内路由 / 外部唤起浏览器)
```

## 6. 网络与缓存

### 6.1 网络层

- 统一 `HttpService` 封装（拦截器、超时、重试、缓存策略）
- 仅 https 请求
- OTA 更新：请求目录树 → 对比本地 → 下载变更文件
- 图片：懒加载 + 磁盘缓存 + 占位图

### 6.2 缓存策略

| 内容 | 策略 |
|------|------|
| 首页推荐配置 | 1 小时失效 |
| 目录树 | OTA 更新时刷新 |
| 文章内容 | LRU（最近 20 篇常驻）+ 收藏永久 |
| 图片 | LRU 磁盘缓存（上限 50MB） |
| 搜索索引 | 构建时生成，随包发布 |

### 6.3 弱网模式

- 断网时自动降级为「仅离线缓存内容」浏览模式
- 顶部黄色横幅提示「当前为离线模式」
- 离线时仍可使用收藏/进度/搜索（缓存内）

## 7. 性能目标

| 指标 | 目标值 |
|------|--------|
| 冷启动（首屏） | < 2s |
| 热启动 | < 500ms |
| 内容页渲染 | < 300ms（大文章 < 800ms） |
| 列表滚动帧率 | 60fps |
| 搜索响应 | < 200ms |
| 包体大小 | 基础包 < 20MB，内容包 < 30MB（首启下载） |
| 内存占用 | 常驻 < 150MB |

## 8. 安全合规

| 项 | 要求 |
|----|------|
| 网络协议 | 全部 HTTPS |
| 权限 | 最少化（仅网络，见 PRD 权限清单） |
| 隐私 | 无采集、无广告 SDK、无匿名上报 |
| 存储 | 数据仅存应用沙箱，卸载即清除 |
| 内容合规 | 资源为开源教材链接，标注来源 |
| 应用签名 | DevEco 自动签名 + 上架 AGC |

## 9. 可测试性

- 单元测试：ArkTS 单测框架（模型、工具函数、搜索排序）
- UI 测试：`ohos.uitest` 自动化脚本
- 冒烟测试：核心流程（首页→详情→搜索→收藏→深色切换）
- CI：GitHub Actions + DevEco-Test 集成（可选）

## 10. 发布与更新

| 事项 | 说明 |
|------|------|
| 上架渠道 | 华为应用市场（AGC）+ 元服务市场 |
| 包类型 | HAP（应用包）+ HAP（元服务包装） |
| 灰度 | AGC 灰度发布（先 5% 后全量） |
| 内容更新 | OTA 增量包 / GitHub Actions 定时构建 |
| 版本管理 | 遵循语义化版本 semver |
| 崩溃监控 | 华为崩溃服务（AppGallery Connect） |
