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
| 网络 | **不申请** — APP 无需任何网络访问权限 | 全离线设计 |
| 状态管理 | AppStorage / LocalStorage / V2 | 官方推荐 |
| 路由 | Navigation（系统路由）+ Router | |
| 卡片 | FormExtensionAbility（ArkTS Widget） | |
| 元服务 | Atomic Service（共享工程） | |
| 本地数据迁移（可选） | 华为云数据协同 / 本地备份恢复 | 非云同步，是一键备份/恢复 |
| 内容打包 | rawfile 资源目录 + 构建脚本 | 构建时全量内置 |

**关键设计决策：**
1. **零网络** — 不申请 `ohos.permission.INTERNET`，APP 无任何网络请求
2. **全内容内置** — 所有 Markdown、图片、索引通过构建脚本打包进 `resources/rawfile/`
3. **纯 ArkUI 渲染** — 不依赖任何 WebView，全文 ArkTS 渲染 Markdown
4. **无第三方 SDK** — 无广告、无统计、无推送 SDK，实现真正的最小体积

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
│   │   │   ├── service/           # 内容管线/索引/阅读进度服务（全部本地）
│   │   │   └── utils/             # 工具函数（markdown 解析封装等）
│   │   ├── resources/
│   │   │   └── rawfile/           # ★ 打包内置的全部内容（md/json/图片/索引）
│   └── src/test/                  # 单测
├── tools/                        # 内容构建脚本（Node/Python）→ 生成 rawfile 内容
├── widgets/                      # 桌面卡片模块（ArkTS Widget）
│   └── src/main/ets/widget/       # FormExtensionAbility + 卡片布局
├── atomic/                       # 元服务模块（共享代码 + 共享 rawfile）
│   └── src/main/ets/              # 搜索/文章速览元服务
├── oh-package.json5              # 依赖声明
└── build-profile.json5           # 构建配置
```

### 2.1 rawfile 内容构建工具链

> `tools/` 目录内的构建脚本是「内容进包」的关键，建议使用 Node.js 或 Python 编写，在 CI 中自动执行。

| 脚本 | 功能 | 输出 |
|------|------|------|
| `build-content` | 扫描 `docs/` 目录，读取 frontmatter 与正文 | `catalog.json`（目录树）+ 渲染所需的结构化内容 |
| `build-index` | 生成倒排搜索索引 | `search-index.json` |
| `build-assets` | 转码压缩 SVG/PNG 图片 | `assets/` 目录 |
| `check-consistency` | 校验链接有效性、文章完整性 | 检查报告 |

> 这三个产物随主 APP/HAP 一起打包进 `rawfile/`，用户安装即用，**永不联网**。

## 3. 数据架构

### 3.1 内容管线（构建时全量打包，运行时零网络）

```
【构建阶段（CI，开发者侧）】
GitHub 仓库 docs/*.md + public/*.svg
        │  内容构建工具链（tools/*.js）
        ▼
catalog.json  +  search-index.json  +  assets/  +  渲染中间产物
        │
        ▼
HAP 打包（resources/rawfile/ 全量内置）
        │
        ▼
【运行时（用户侧，完全离线）】
用户安装 HAP
        ▼
首页/列表/搜索/阅读  →  全部读取 rawfile + 本地数据库
（无网络请求、无空白加载）
```

**决策：纯本地打包，唯一更新通道是版本发布**

理由：
- 昇腾资料全集压缩后约 10-20MB（文本为主），内置完全可行
- 全本地保证：① 无限速环境启动即用 ② 任何弱网/无网场所体验一致 ③ 零请求零隐私风险 ④ 无后端成本
- 内容更新通过 APP 应用市场版本升级进行；可在「关于」页提示新版本含内容更新

### 3.2 数据模型（TypeScript）

```typescript
/** 分类节点（目录树）—— 构建时生成缓存到 rawfile/catalog.json */
interface CategoryNode {
  id: string;          // 唯一 id
  title: string;       // 分类名
  icon?: string;       // 图标
  order: number;       // 排序
  parentId: string | null;
  children?: CategoryNode[];
}

/** 文档元数据（frontmatter）—— 构建时生成 */
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

/** 本地状态（运行时，RDB 持久化） */
interface LocalState {
  favorites: Favorites[];   // 收藏夹
  history: HistoryItem[];   // 阅读历史
  progress: ProgressMap;    // 进度记录 {docId: scrollPercent}
  settings: UserSettings;   // 偏好（字体/主题/引导完成状态）
  learningProgress: LearningMap; // 学习路径完成状态
}
```

### 3.3 存储方案

| 数据 | 技术 | 理由 |
|------|------|------|
| 内容（只读） | rawfile 打包资源 | 只读、无需运行时写入 |
| 收藏夹/历史/进度 | RDB（Relational Store） | 结构化、可查询 |
| 用户偏好 | Preferences | 键值对、轻量 |
| 搜索索引（只读） | rawfile 加载入内存 | 预构建倒排索引，毫秒检索 |
| 学习进度 | RDB | 与收藏并列存储 |

## 4. 搜索方案

### 4.1 本地搜索（v1 核心）

- **索引范围**：文章标题 + 正文纯文本（构建时生成索引片段）
- **算法**：简单倒排索引（分词 + 词频），中文分词采用轻量方案（按字符 n-gram + 关键词词组匹配）
- **匹配**：关键词子串匹配 + 相关性排序（标题命中 > 标签命中 > 正文命中）
- **高亮**：前后指针标记命中片段

### 4.2 增强搜索（v2 可选）

- 集成**系统搜索能力**（@ohos.intent.kit）让 APP 内容出现在系统全局搜索中（搜索命中指向本地内容）

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

## 6. 离线架构与「零网络」保障

### 6.1 网络策略

- **不申请 `ohos.permission.INTERNET`** — 从系统层面杜绝一切网络行为
- 无 HttpService、无 Image 远端加载、无 OTA 通道
- 图片资源全部在构建阶段打包进 rawfile，运行时纯本地读取
- 优缺点权衡：优（快/省电/隐私/可靠），缺（内容更新仅随版本发布）——本产品场景下优远大于缺

### 6.2 一致性保障

| 风险 | 规避手段 |
|------|----------|
| 打包内容与仓库不一致 | CI 构建脚本强制从仓库 docs/ 生成，未提交产物不入包 |
| 索引与正文脱节 | 构建脚本校验每个 docId 在主索引中可检索 |
| 链接失效 | 构建时校验所有站内链接、图片引用有效 |
| 版本混乱 | rawfile 内写入 `content-version.json`，运行时校验 |

### 6.3 降级策略（特殊情况）

- 内容版本校验失败 → 展示「数据异常」引导重装/升级，绝不请求网络
- 本地数据库损坏 → 自动重建空白用户数据，内容包不受影响（只读）

## 7. 性能目标

| 指标 | 目标值 |
|------|--------|
| 冷启动（首屏） | < 0.5s（本地直读，无网络等待） |
| 热启动 | < 300ms |
| 内容页渲染 | < 150ms（本地 Markdown 渲染） |
| 列表滚动帧率 | 60fps（含动效） |
| 搜索响应 | < 100ms（本地预构建索引） |
| 包体大小 | HAP < 30MB（含全部内容） |
| 内存占用 | 常驻 < 120MB |

## 8. 安全合规

| 项 | 要求 |
|----|------|
| 网络协议 | 无网络行为，无需 HTTPS 连接 |
| 权限 | **零权限**（不申请 INTERNET 等任何运行时权限） |
| 隐私 | 无采集、无 SDK、无数据上报，无需隐私弹窗 |
| 存储 | 数据仅存应用沙箱，卸载即清除 |
| 内容合规 | 资源为开源教材链接，标注来源 |
| 应用签名 | DevEco 自动签名 + 上架 AGC |

## 9. 可测试性

- 单元测试：ArkTS 单测框架（模型、工具函数、搜索排序）
- UI 测试：`ohos.uitest` 自动化脚本
- 冒烟测试：核心流程（首页→详情→搜索→收藏→深色切换→引导页流程）
- 离线验证：断网状态下全功能可用性回归
- CI：GitHub Actions + DevEco-Test 集成（可选）

## 10. 发布与更新

| 事项 | 说明 |
|------|------|
| 上架渠道 | 华为应用市场（AGC）+ 元服务市场 |
| 包类型 | HAP（应用包）+ HAP（元服务包装） |
| 灰度 | AGC 灰度发布（先 5% 后全量） |
| 内容更新 | 依赖 APP 版本升级（构建管线重跑 → 新包） |
| 版本管理 | 遵循语义化版本 semver |
| 崩溃监控 | 华为崩溃服务（AppGallery Connect，可选） |
