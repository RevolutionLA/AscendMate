import { ContentService } from './ContentService';
import { HighlightSegment, SearchDoc, SearchHit } from '../model/Models';

export class SearchService {
  private static readonly instance: SearchService = new SearchService();

  private constructor() {
  }

  static getInstance(): SearchService {
    return SearchService.instance;
  }

  search(query: string, catFilter: string): SearchHit[] {
    const q: string = query.trim().toLowerCase();
    if (q === '') {
      return [];
    }
    const docs: SearchDoc[] = ContentService.getInstance().getSearchDocs();
    const hits: SearchHit[] = [];
    for (let i = 0; i < docs.length; i++) {
      const doc: SearchDoc = docs[i];
      if (catFilter !== '' && doc.catId !== catFilter) {
        continue;
      }
      const titleLower: string = doc.title.toLowerCase();
      const titleIdx: number = titleLower.indexOf(q);
      const textLower: string = doc.text.toLowerCase();
      const textIdx: number = textLower.indexOf(q);
      if (titleIdx < 0 && textIdx < 0) {
        continue;
      }
      const hit = new SearchHit();
      hit.docId = doc.id;
      hit.catId = doc.catId;
      hit.breadcrumb = doc.cat;
      hit.title = SearchService.splitHighlight(doc.title, titleIdx, q.length);
      if (titleIdx >= 0 && textIdx >= 0) {
        hit.score = 150 - titleIdx * 0.5 - textIdx * 0.001;
      } else if (titleIdx >= 0) {
        hit.score = 100 - titleIdx * 0.5;
      } else {
        hit.score = 50 - textIdx * 0.002;
      }
      hit.excerpt = SearchService.buildExcerpt(doc.text, textIdx >= 0 ? textIdx : 0, q.length);
      hits.push(hit);
    }
    hits.sort((a: SearchHit, b: SearchHit): number => b.score - a.score);
    return hits.slice(0, 40);
  }

  suggest(query: string): string[] {
    const q: string = query.trim().toLowerCase();
    if (q === '') {
      return [];
    }
    const docs: SearchDoc[] = ContentService.getInstance().getSearchDocs();
    const out: string[] = [];
    for (let i = 0; i < docs.length && out.length < 8; i++) {
      if (docs[i].title.toLowerCase().indexOf(q) >= 0) {
        out.push(docs[i].title);
      }
    }
    return out;
  }

  private static buildExcerpt(text: string, hitIdx: number, hitLen: number): HighlightSegment[] {
    const start: number = Math.max(0, hitIdx - 36);
    let end: number = Math.min(text.length, hitIdx + hitLen + 60);
    if (end < text.length) {
      const dotIdx: number = text.indexOf('。', end);
      if (dotIdx > 0 && dotIdx < end + 30) {
        end = dotIdx + 1;
      }
    }
    let body: string = text.substring(start, end);
    const prefix: string = start > 0 ? '…' : '';
    const suffix: string = end < text.length ? '…' : '';
    const relHit: number = hitIdx - start;
    const segments: HighlightSegment[] = [];
    if (relHit > 0) {
      segments.push(new HighlightSegment(prefix + body.substring(0, relHit), false));
    }
    segments.push(new HighlightSegment(body.substring(relHit, relHit + hitLen), true));
    if (relHit + hitLen < body.length) {
      segments.push(new HighlightSegment(body.substring(relHit + hitLen) + suffix, false));
    }
    return segments;
  }

  private static splitHighlight(text: string, hitIdx: number, hitLen: number): HighlightSegment[] {
    if (hitIdx < 0) {
      return [new HighlightSegment(text, false)];
    }
    const segments: HighlightSegment[] = [];
    if (hitIdx > 0) {
      segments.push(new HighlightSegment(text.substring(0, hitIdx), false));
    }
    segments.push(new HighlightSegment(text.substring(hitIdx, hitIdx + hitLen), true));
    if (hitIdx + hitLen < text.length) {
      segments.push(new HighlightSegment(text.substring(hitIdx + hitLen), false));
    }
    return segments;
  }
}
