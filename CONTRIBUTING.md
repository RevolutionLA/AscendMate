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

## 可信度元数据规范（新文档必填）

昇腾生态版本迭代很快（CANN、torch_npu、MindIE 几乎季度变），读者需要知道一篇文档**在什么环境下、什么时候验证过**。因此**每篇新增/修订的文档必须在标题下方的第一个引言块之前**，附上如下格式的可信度标注：

```markdown
> 🗓 **验证环境**：openEuler 22.03 LTS + CANN 8.x + 固件 24.x（Atlas 800T A2 实测） · **验证日期**：2026-xx-xx
```

若内容**未在硬件上实测**（整理自官方文档/开源项目），请诚实标注，不要留空、更不要伪造实测记录：

```markdown
> 🗓 **验证环境**：未实测（内容整理自官方文档，状态 `from-official-docs`） · **核对日期**：2026-xx
```

字段说明：

| 字段 | 含义 | 取值示例 |
| --- | --- | --- |
| 验证环境 | OS + CANN/驱动/固件版本 + 机型；未实测则写明来源 | `openEuler 22.03 + CANN 8.3.RC2（Atlas 800I A2 实测）` / `未实测（整理自官方文档）` |
| 验证日期 / 核对日期 | 实测当天日期；未实测时为最后一次与官方文档核对日期 | `2026-10-24` |
| 状态 | `tested-on-hardware`（真机实测）/ `from-official-docs`（整理自官方） | 二选一 |

已在 `docs/setup/index.md`、`docs/training/llama-factory.md`、`docs/inference/mindie.md`、`docs/inference/vllm-ascend.md`、`docs/faq/index.md` 顶部落地示范，供参考。

## 对应关系

- 站内文档 → `docs/`（VitePress）
- 导航/侧边栏 → `docs/.vitepress/config.mts`
- 首页 → `docs/index.md`
