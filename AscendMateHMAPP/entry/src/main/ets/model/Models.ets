export class DocSummary {
  id: string = '';
  title: string = '';
  summary: string = '';
  readTime: number = 0;
  file: string = '';
  category: string = '';
  categoryTitle: string = '';

  static of(id: string, title: string, summary: string, readTime: number, file: string,
    category: string, categoryTitle: string): DocSummary {
    const d = new DocSummary();
    d.id = id;
    d.title = title;
    d.summary = summary;
    d.readTime = readTime;
    d.file = file;
    d.category = category;
    d.categoryTitle = categoryTitle;
    return d;
  }
}

export class CategoryData {
  id: string = '';
  title: string = '';
  desc: string = '';
  icon: string = 'doc';
  docs: DocSummary[] = [];

  static of(id: string, title: string, desc: string, icon: string, docs: DocSummary[]): CategoryData {
    const c = new CategoryData();
    c.id = id;
    c.title = title;
    c.desc = desc;
    c.icon = icon;
    c.docs = docs;
    return c;
  }
}

export class CatalogData {
  version: string = '';
  builtAt: string = '';
  docCount: number = 0;
  categories: CategoryData[] = [];
}

export class DocContent {
  id: string = '';
  title: string = '';
  category: string = '';
  categoryTitle: string = '';
  summary: string = '';
  readTime: number = 0;
  updatedAt: string = '';
  source: string = '';
  content: string = '';
}

export class SearchDoc {
  id: string = '';
  title: string = '';
  cat: string = '';
  catId: string = '';
  text: string = '';
}

export class HighlightSegment {
  text: string = '';
  hit: boolean = false;

  constructor(text: string, hit: boolean) {
    this.text = text;
    this.hit = hit;
  }
}

export class SearchHit {
  docId: string = '';
  title: HighlightSegment[] = [];
  breadcrumb: string = '';
  catId: string = '';
  excerpt: HighlightSegment[] = [];
  score: number = 0;
  readTime: number = 0;
}

export class FavoriteEntry {
  docId: string = '';
  title: string = '';
  catId: string = '';
  catTitle: string = '';
  addedAt: number = 0;
}

export class HistoryEntry {
  docId: string = '';
  title: string = '';
  catId: string = '';
  catTitle: string = '';
  readAt: number = 0;
  progress: number = 0;
}

export class LearningStage {
  stage: number = 0;
  docId: string = '';
  title: string = '';
  subtitle: string = '';

  constructor(stage: number, docId: string, title: string, subtitle: string) {
    this.stage = stage;
    this.docId = docId;
    this.title = title;
    this.subtitle = subtitle;
  }
}

export class EcoItem {
  name: string = '';
  docId: string = '';
  color: string = '#0066FF';

  constructor(name: string, docId: string, color: string) {
    this.name = name;
    this.docId = docId;
    this.color = color;
  }
}
