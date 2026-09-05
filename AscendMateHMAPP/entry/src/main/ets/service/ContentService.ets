import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { CatalogData, CategoryData, DocContent, DocSummary, EcoItem, LearningStage, SearchDoc } from '../model/Models';

export class ContentService {
  private static readonly instance: ContentService = new ContentService();
  private catalog: CatalogData = new CatalogData();
  private searchDocs: SearchDoc[] = [];
  private docCache: Record<string, DocContent> = {};
  private ready: boolean = false;
  private context: common.UIAbilityContext | undefined = undefined;

  private constructor() {
  }

  static getInstance(): ContentService {
    return ContentService.instance;
  }

  async init(context: common.UIAbilityContext): Promise<void> {
    if (this.ready) {
      return;
    }
    this.context = context;
    const catalogText: string = await ContentService.readRawText(context, 'catalog.json');
    this.catalog = JSON.parse(catalogText) as CatalogData;
    const searchText: string = await ContentService.readRawText(context, 'search.json');
    this.searchDocs = JSON.parse(searchText) as SearchDoc[];
    for (let i = 0; i < this.catalog.categories.length; i++) {
      const cat: CategoryData = this.catalog.categories[i];
      for (let j = 0; j < cat.docs.length; j++) {
        cat.docs[j].category = cat.id;
        cat.docs[j].categoryTitle = cat.title;
      }
    }
    this.ready = true;
  }

  private static async readRawText(context: common.UIAbilityContext, path: string): Promise<string> {
    const content: Uint8Array = await context.resourceManager.getRawFileContent(path);
    const decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
    return decoder.decodeToString(content);
  }

  isReady(): boolean {
    return this.ready;
  }

  getCatalog(): CatalogData {
    return this.catalog;
  }

  getCategories(): CategoryData[] {
    return this.catalog.categories;
  }

  getCategory(catId: string): CategoryData | undefined {
    for (let i = 0; i < this.catalog.categories.length; i++) {
      if (this.catalog.categories[i].id === catId) {
        return this.catalog.categories[i];
      }
    }
    return undefined;
  }

  findSummary(docId: string): DocSummary | undefined {
    for (let i = 0; i < this.catalog.categories.length; i++) {
      const cat: CategoryData = this.catalog.categories[i];
      for (let j = 0; j < cat.docs.length; j++) {
        if (cat.docs[j].id === docId) {
          return cat.docs[j];
        }
      }
    }
    return undefined;
  }

  getSearchDocs(): SearchDoc[] {
    return this.searchDocs;
  }

  async getDoc(docId: string): Promise<DocContent | undefined> {
    const cached: DocContent | undefined = this.docCache[docId];
    if (cached !== undefined) {
      return cached;
    }
    if (this.context === undefined) {
      return undefined;
    }
    const text: string = await ContentService.readRawText(this.context, `docs/doc_${docId.replace('/', '_')}.json`);
    const doc: DocContent = JSON.parse(text) as DocContent;
    this.docCache[docId] = doc;
    return doc;
  }

  getNeighbors(docId: string): DocNeighbors {
    const res = new DocNeighbors();
    for (let i = 0; i < this.catalog.categories.length; i++) {
      const cat: CategoryData = this.catalog.categories[i];
      for (let j = 0; j < cat.docs.length; j++) {
        if (cat.docs[j].id === docId) {
          if (j > 0) {
            res.prev = cat.docs[j - 1];
          }
          if (j < cat.docs.length - 1) {
            res.next = cat.docs[j + 1];
          }
          return res;
        }
      }
    }
    return res;
  }

  static featuredDocIds(): string[] {
    return ['guide/seven-steps', 'setup/cann-install', 'training/llama-factory', 'monitoring/prometheus-grafana'];
  }

  static hotDocIds(): string[] {
    return ['faq/setup-issues', 'inference/vllm-ascend', 'ops/ascend-c', 'tools/profiling',
      'scenes/poc-guide', 'hardware/a2-server', 'operations/utilization', 'guide/choose-your-path'];
  }

  static ecoItems(): EcoItem[] {
    return [
      new EcoItem('MindIE', 'inference/mindie', '#C8102E'),
      new EcoItem('vLLM-Ascend', 'inference/vllm-ascend', '#C8102E'),
      new EcoItem('SGLang', 'inference/sglang', '#C8102E'),
      new EcoItem('Dify', 'inference/dify', '#C8102E'),
      new EcoItem('MindSpeed', 'training/mindspeed', '#C8102E'),
      new EcoItem('CANN', 'setup/cann-install', '#C8102E'),
      new EcoItem('PyTorch', 'setup/torch-npu-install', '#C8102E'),
      new EcoItem('MindSpore', 'setup/mindspore-install', '#C8102E'),
      new EcoItem('Triton', 'ops/triton-ascend', '#C8102E'),
      new EcoItem('MindStudio', 'tools/mindstudio', '#C8102E')
    ];
  }

  static learningStages(): LearningStage[] {
    return [
      new LearningStage(1, 'learning/ai-fundamentals', 'AI 基础认知', '1-2 周 · 建立行业全貌'),
      new LearningStage(2, 'learning/math-programming', '数学与编程基础', '4-8 周 · Python 数据科学栈'),
      new LearningStage(3, 'learning/deep-learning', '深度学习入门', '4-8 周 · 神经网络原理'),
      new LearningStage(4, 'learning/llm-basics', '大模型技术栈', '4-8 周 · Transformer 与微调'),
      new LearningStage(5, 'learning/ascend-hands-on', '昇腾生态实战', '4-8 周 · NPU 推理与调优'),
      new LearningStage(6, 'learning/industry-applications', '行业应用与进阶', '持续 · 业务落地能力')
    ];
  }

  static hotKeywords(): string[] {
    return ['npu-smi', 'CANN安装', 'FAQ', 'vLLM', 'LLaMA-Factory', 'torch_npu', 'MindIE', 'Grafana', '驱动安装'];
  }
}

class DocNeighbors {
  prev: DocSummary | undefined = undefined;
  next: DocSummary | undefined = undefined;
}
