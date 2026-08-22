# Contributing to AscendMate

欢迎贡献 AscendMate！任何形式的贡献都欢迎：修正错漏、补充教程、整理 FAQ、优化导航与检索。

详细说明见 [在线文档 · 参与贡献](docs/contributing/index.md)。

## 快速开始

```bash
npm install
npm run docs:dev   # 本地预览
npm run docs:build # 构建检查
```

## 提交 PR

1. Fork 并创建新分支。
2. 修改 `docs/` 下对应板块的内容。
3. 本地构建通过后提交 PR。

## 写作约定

- 面向**真实场景**，结论先行，写明"什么时候读这节"。
- 尽量给**可复现命令**与**验证方法**。
- 涉及版本务必标注"以官方配套为准"。
- 诚实标注未经实测的内容。

## 对应关系

- 站内文档 → `docs/`（VitePress）
- 导航/侧边栏 → `docs/.vitepress/config.mts`
- 首页 → `docs/index.md`
