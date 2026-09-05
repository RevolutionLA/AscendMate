// AscendMate HMAPP content pipeline
// Scans ../docs (VitePress source) and generates rawfile content for the HarmonyOS app.
// Usage: node tools/build-content.mjs
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const DOCS_DIR = path.resolve(__dirname, '../../docs');
const OUT_DIR = path.resolve(__dirname, '../entry/src/main/resources/rawfile');
const SITE_PREFIX = 'https://revolutionla.github.io/AscendMate';

// Category tree, mirrors docs/.vitepress/config.mts sidebar (order preserved)
const CATEGORIES = [
  {
    id: 'guide', title: '快速开始', desc: '认识 AscendMate，选对路径，7 步从裸机到跑通代码', icon: 'compass',
    docs: ['guide/index', 'guide/what-is-ascendmate', 'guide/use-cases', 'guide/choose-your-path', 'guide/seven-steps', 'guide/ascend-landscape'],
  },
  {
    id: 'setup', title: '环境搭建', desc: '从上电规划到批量部署的全流程实操手册', icon: 'layers',
    docs: ['setup/index', 'setup/server-onboarding', 'setup/os-install', 'setup/firmware-driver', 'setup/cann-install', 'setup/torch-npu-install', 'setup/mindspore-install', 'setup/docker-offline', 'setup/checklist', 'setup/delivery-acceptance', 'setup/batch-deployment'],
  },
  {
    id: 'training', title: '大模型训练', desc: 'LLaMA-Factory 微调、MindSpeed 预训练与模型迁移', icon: 'flame',
    docs: ['training/index', 'training/llama-factory', 'training/mindspeed', 'training/pytorch-migration', 'training/mindspore-migration'],
  },
  {
    id: 'inference', title: '模型推理', desc: 'MindIE、vLLM-Ascend、SGLang、Dify 部署实战', icon: 'rocket',
    docs: ['inference/index', 'inference/mindie', 'inference/vllm-ascend', 'inference/sglang', 'inference/dify'],
  },
  {
    id: 'ops', title: '算子开发', desc: 'Ascend C、Triton-Ascend、CATLASS 算子开发指南', icon: 'chip',
    docs: ['ops/index', 'ops/ascend-c', 'ops/triton-ascend', 'ops/catlass'],
  },
  {
    id: 'tools', title: '工具链', desc: 'MindStudio、精度调试与性能调优工具', icon: 'wrench',
    docs: ['tools/index', 'tools/mindstudio', 'tools/precision-debug', 'tools/profiling'],
  },
  {
    id: 'monitoring', title: '运维监控', desc: 'NPU 指标采集、Prometheus + Grafana 大屏与巡检 SOP', icon: 'pulse',
    docs: ['monitoring/index', 'monitoring/npu-exporter', 'monitoring/prometheus-grafana', 'monitoring/alerting', 'monitoring/inspection', 'monitoring/log-management'],
  },
  {
    id: 'operations', title: '算力运营', desc: '利用率优化、多团队调度与成本核算', icon: 'chart',
    docs: ['operations/index', 'operations/utilization', 'operations/scheduling', 'operations/cost-accounting'],
  },
  {
    id: 'hardware', title: '昇腾硬件', desc: '集群、A2/A3 服务器、推理卡与开发套件', icon: 'server',
    docs: ['hardware/index', 'hardware/cluster', 'hardware/a2-server', 'hardware/a3-server', 'hardware/inference-card', 'hardware/devkit-module'],
  },
  {
    id: 'faq', title: '问题定位', desc: '环境、训练、推理、性能精度常见问题速查', icon: 'question',
    docs: ['faq/index', 'faq/setup-issues', 'faq/training-issues', 'faq/inference-issues', 'faq/perf-precision-issues'],
  },
  {
    id: 'learning', title: '学习路径', desc: '六阶段体系化学习，从零到昇腾 AI 工程师', icon: 'graduation',
    docs: ['learning/index', 'learning/ai-fundamentals', 'learning/math-programming', 'learning/deep-learning', 'learning/llm-basics', 'learning/ascend-hands-on', 'learning/industry-applications'],
  },
  {
    id: 'scenes', title: '场景价值', desc: '金融、医疗、政务、制造行业方案与 POC 指南', icon: 'grid',
    docs: ['scenes/index', 'scenes/finance', 'scenes/healthcare', 'scenes/government', 'scenes/manufacturing', 'scenes/poc-guide'],
  },
  {
    id: 'resources', title: '资源导航', desc: '链接导航、样例模型、镜像下载与生态社区', icon: 'link',
    docs: ['resources/index', 'resources/links', 'resources/samples-models', 'resources/download', 'resources/community'],
  },
];

function readDoc(docId) {
  const file = path.join(DOCS_DIR, docId + '.md');
  if (!fs.existsSync(file)) {
    throw new Error(`Missing doc: ${docId}`);
  }
  return fs.readFileSync(file, 'utf-8');
}

function parseFrontmatter(raw) {
  let title = '';
  let description = '';
  let body = raw;
  if (raw.startsWith('---')) {
    const end = raw.indexOf('\n---', 3);
    if (end > 0) {
      const fm = raw.slice(3, end).trim();
      body = raw.slice(raw.indexOf('\n', end + 1) + 1);
      const tm = fm.match(/^title:\s*(.+)$/m);
      if (tm) title = tm[1].trim().replace(/^["']|["']$/g, '');
      const dm = fm.match(/^description:\s*(.+)$/m);
      if (dm) description = dm[1].trim().replace(/^["']|["']$/g, '');
    }
  }
  if (!title) {
    const hm = body.match(/^#\s+(.+)$/m);
    title = hm ? hm[1].trim() : docId;
  }
  return { title, description, body };
}

function plainText(md) {
  return md
    .replace(/```[\s\S]*?```/g, (m) => m.replace(/```(\w*)\n?/g, '')) // keep code content, strip fences
    .replace(/`([^`]*)`/g, '$1')
    .replace(/!\[[^\]]*\]\([^)]*\)/g, '')
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/^#{1,6}\s+/gm, '')
    .replace(/^>\s?/gm, '')
    .replace(/^:::.*$/gm, '')
    .replace(/[*_~|]+/g, ' ')
    .replace(/^-{3,}$/gm, ' ')
    .replace(/<[^>]+>/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function normalizeLinks(body, knownIds) {
  // Rewrite internal links to doc:<id>; keep others untouched.
  return body.replace(/\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g, (m, text, target) => {
    let id = null;
    if (target.startsWith('./') || target.startsWith('../') || target.startsWith('/')) {
      let base;
      if (target.startsWith('./')) {
        // resolved against current doc dir; doc dir unknown here, handled below by caller
        return m; // caller handles
      }
    }
    return m;
  });
}

// Resolve link targets relative to a doc into global doc ids
function rewriteBodyLinks(body, docId, knownIds) {
  const dir = path.dirname(docId);
  return body.replace(/\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)/g, (m, text, target) => {
    let id = null;
    if (target.startsWith(SITE_PREFIX)) {
      id = target.slice(SITE_PREFIX.length).replace(/^\/+/, '');
    } else if (target.startsWith('./') || target.startsWith('../')) {
      const joined = path.posix.normalize(path.posix.join(dir, target));
      id = joined.replace(/^\/+/, '');
    } else if (target.startsWith('/') && !target.startsWith('//')) {
      id = target.slice(1);
    } else {
      return m; // external
    }
    id = id.split('#')[0];
    if (id === '' || id === '/') id = 'index';
    if (id.endsWith('/')) id = id.slice(0, -1) + '/index';
    if (knownIds.has(id)) {
      return `[${text}](doc:${id})`;
    }
    return m;
  });
}

function readingMinutes(md) {
  const chars = plainText(md).length;
  return Math.max(1, Math.round(chars / 450));
}

function build() {
  const knownIds = new Set();
  for (const cat of CATEGORIES) {
    for (const d of cat.docs) knownIds.add(d);
  }
  const docsOutDir = path.join(OUT_DIR, 'docs');
  fs.rmSync(docsOutDir, { recursive: true, force: true });
  fs.mkdirSync(docsOutDir, { recursive: true });

  const searchEntries = [];
  const catalogCategories = [];
  let total = 0;

  for (const cat of CATEGORIES) {
    const catDocs = [];
    for (const docId of cat.docs) {
      const raw = readDoc(docId);
      const { title, description, body } = parseFrontmatter(raw);
      const cleaned = body
        .replace(/^\*本文档由[^\n]*\*\s*\n?/gm, '')
        .replace(/^\*最后更新[^\n]*\*\s*\n?/gm, '');
      const linked = rewriteBodyLinks(cleaned, docId, knownIds);
      const summary = description || plainText(body).slice(0, 80);
      const readTime = readingMinutes(cleaned);
      const docFile = `doc_${docId.replace('/', '_')}.json`;
      const doc = {
        id: docId,
        title,
        category: cat.id,
        categoryTitle: cat.title,
        summary,
        readTime,
        updatedAt: '2026-09',
        source: `${SITE_PREFIX}/${docId === 'guide/index' ? 'guide/' : docId.replace(/\/index$/, '/')}`,
        content: linked,
      };
      fs.writeFileSync(path.join(docsOutDir, docFile), JSON.stringify(doc), 'utf-8');
      catDocs.push({
        id: docId, title, summary, readTime, file: docFile,
        category: cat.id, categoryTitle: cat.title,
      });
      searchEntries.push({
        id: docId,
        title,
        cat: cat.title,
        catId: cat.id,
        text: plainText(linked),
      });
      total++;
    }
    catalogCategories.push({
      id: cat.id, title: cat.title, desc: cat.desc, icon: cat.icon,
      docs: catDocs,
    });
  }

  const catalog = {
    version: '1.0.0',
    builtAt: '2026-09-04',
    docCount: total,
    categories: catalogCategories,
  };
  fs.writeFileSync(path.join(OUT_DIR, 'catalog.json'), JSON.stringify(catalog), 'utf-8');
  fs.writeFileSync(path.join(OUT_DIR, 'search.json'), JSON.stringify(searchEntries), 'utf-8');

  console.log(`[build-content] ${total} docs, ${CATEGORIES.length} categories`);
  console.log(`[build-content] catalog.json ${(fs.statSync(path.join(OUT_DIR, 'catalog.json')).size / 1024).toFixed(1)} KB`);
  console.log(`[build-content] search.json ${(fs.statSync(path.join(OUT_DIR, 'search.json')).size / 1024).toFixed(1)} KB`);
}

build();
