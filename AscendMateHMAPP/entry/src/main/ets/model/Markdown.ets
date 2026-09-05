export enum MBType {
  Heading = 'heading',
  Paragraph = 'para',
  Code = 'code',
  Quote = 'quote',
  List = 'list',
  Table = 'table',
  Hr = 'hr',
  Callout = 'callout'
}

export class InlineSpan {
  text: string = '';
  hit: boolean = false;
  bold: boolean = false;
  italic: boolean = false;
  code: boolean = false;
  linkDoc: string = '';
  linkUrl: string = '';
}

export class MBListItem {
  level: number = 0;
  marker: string = '-';
  spans: InlineSpan[] = [];
}

export class MDBlock {
  type: MBType = MBType.Paragraph;
  level: number = 0;
  text: string = '';
  spans: InlineSpan[] = [];
  items: MBListItem[] = [];
  headers: string[] = [];
  rows: string[][] = [];
  lang: string = '';
  code: string = '';
  kind: string = '';
  title: string = '';
  children: MDBlock[] = [];
  docId: string = '';
  linkUrl: string = '';
  anchor: number = 0;
}

export class MarkdownParser {
  private static readonly INLINE_RE: RegExp = new RegExp(
    '\\*\\*([^*]+?)\\*\\*' +
    '|`([^`\\n]+?)`' +
    '|\\*([^*\\n]+?)\\*' +
    '|\\[([^\\]\\n]*?)\\]\\(([^)\\n]*?)\\)', 'g');

  static parse(md: string): MDBlock[] {
    const lines: string[] = md.split('\n');
    return MarkdownParser.parseLines(lines);
  }

  private static parseLines(lines: string[]): MDBlock[] {
    const blocks: MDBlock[] = [];
    let i = 0;
    while (i < lines.length) {
      const line: string = lines[i];
      const trimmed: string = line.trim();
      if (trimmed === '') {
        i++;
        continue;
      }
      if (trimmed.startsWith('```')) {
        const lang: string = trimmed.slice(3).trim();
        i++;
        const codeLines: string[] = [];
        while (i < lines.length && lines[i].trim() !== '```') {
          codeLines.push(lines[i].replace(new RegExp('\\t', 'g'), '    '));
          i++;
        }
        i++;
        const b = new MDBlock();
        b.type = MBType.Code;
        b.lang = lang;
        b.code = codeLines.join('\n');
        blocks.push(b);
        continue;
      }
      const headingMatch: RegExpMatchArray | null = trimmed.match(new RegExp('^(#{1,6})\\s+(.*)$'));
      if (headingMatch !== null) {
        const b = new MDBlock();
        b.type = MBType.Heading;
        b.level = headingMatch[1].length;
        b.text = MarkdownParser.stripInline(headingMatch[2]);
        blocks.push(b);
        i++;
        continue;
      }
      if (MarkdownParser.isCalloutStart(trimmed)) {
        const kindMatch: RegExpMatchArray | null = trimmed.match(new RegExp('^:::\\s*(\\w+)\\s*(.*)$'));
        const kind: string = kindMatch !== null ? kindMatch[1] : 'tip';
        const rawTitle: string = kindMatch !== null ? kindMatch[2].trim() : '';
        i++;
        const inner: string[] = [];
        while (i < lines.length && lines[i].trim() !== ':::') {
          inner.push(lines[i]);
          i++;
        }
        i++;
        const b = new MDBlock();
        b.type = MBType.Callout;
        b.kind = kind;
        b.title = MarkdownParser.calloutTitle(kind, rawTitle);
        b.children = MarkdownParser.parseLines(inner);
        blocks.push(b);
        continue;
      }
      if (MarkdownParser.isTableStart(lines, i)) {
        const parseRes = MarkdownParser.parseTable(lines, i);
        const b = new MDBlock();
        b.type = MBType.Table;
        b.headers = parseRes.headers;
        b.rows = parseRes.rows;
        blocks.push(b);
        i = parseRes.next;
        continue;
      }
      if (trimmed.startsWith('>')) {
        const quoteLines: string[] = [];
        while (i < lines.length && lines[i].trim().startsWith('>')) {
          quoteLines.push(lines[i].trim().replace(new RegExp('^>\\s?'), ''));
          i++;
        }
        const alertMatch: RegExpMatchArray | null =
          quoteLines[0].trim().match(new RegExp('^\\[!(TIP|NOTE|INFO|WARNING|CAUTION|IMPORTANT|DANGER)\\]\\s*(.*)$', 'i'));
        if (alertMatch !== null) {
          const kindRaw: string = alertMatch[1].toUpperCase();
          let kind: string = 'tip';
          if (kindRaw === 'NOTE' || kindRaw === 'IMPORTANT') {
            kind = 'note';
          } else if (kindRaw === 'INFO') {
            kind = 'info';
          } else if (kindRaw === 'WARNING') {
            kind = 'warning';
          } else if (kindRaw === 'CAUTION' || kindRaw === 'DANGER') {
            kind = 'danger';
          }
          const restLines: string[] = quoteLines.slice(1);
          if (alertMatch[2].trim() !== '') {
            restLines.unshift(alertMatch[2].trim());
          }
          const alertBlock = new MDBlock();
          alertBlock.type = MBType.Callout;
          alertBlock.kind = kind;
          alertBlock.title = MarkdownParser.calloutTitle(kind, '');
          alertBlock.children = MarkdownParser.parseLines(restLines);
          blocks.push(alertBlock);
          continue;
        }
        const b = new MDBlock();
        b.type = MBType.Quote;
        b.spans = MarkdownParser.parseInline(quoteLines.join('\n'));
        blocks.push(b);
        continue;
      }
      if (trimmed.match(new RegExp('^(-{3,}|\\*{3,}|_{3,})$')) !== null) {
        const b = new MDBlock();
        b.type = MBType.Hr;
        blocks.push(b);
        i++;
        continue;
      }
      const bulletMatch: RegExpMatchArray | null = line.match(new RegExp('^(\\s*)([-*+]|\\d+\\.)\\s+(.*)$'));
      if (bulletMatch !== null) {
        const res = MarkdownParser.parseList(lines, i);
        const b = new MDBlock();
        b.type = MBType.List;
        b.items = res.items;
        blocks.push(b);
        i = res.next;
        continue;
      }
      const paraLines: string[] = [];
      while (i < lines.length) {
        const cur: string = lines[i];
        const curTrim: string = cur.trim();
        if (curTrim === '' || MarkdownParser.isBlockStart(curTrim, lines, i)) {
          break;
        }
        paraLines.push(curTrim);
        i++;
      }
      if (paraLines.length > 0) {
        const b = new MDBlock();
        b.type = MBType.Paragraph;
        b.spans = MarkdownParser.parseInline(MarkdownParser.joinLines(paraLines));
        b.docId = MarkdownParser.firstInternalDoc(b.spans);
        b.linkUrl = MarkdownParser.firstExternalUrl(b.spans);
        blocks.push(b);
      }
    }
    return blocks;
  }

  private static isBlockStart(trimmed: string, lines: string[], idx: number): boolean {
    if (trimmed.startsWith('```') || trimmed.startsWith('#') || trimmed.startsWith('>')) {
      return true;
    }
    if (MarkdownParser.isCalloutStart(trimmed)) {
      return true;
    }
    if (trimmed.match(new RegExp('^(\\s*)([-*+]|\\d+\\.)\\s+')) !== null) {
      return true;
    }
    if (trimmed.match(new RegExp('^(-{3,}|\\*{3,}|_{3,})$')) !== null) {
      return true;
    }
    if (MarkdownParser.isTableStart(lines, idx)) {
      return true;
    }
    return false;
  }

  private static isCalloutStart(trimmed: string): boolean {
    return trimmed.startsWith(':::');
  }

  private static calloutTitle(kind: string, rawTitle: string): string {
    if (rawTitle !== '') {
      return MarkdownParser.stripInline(rawTitle);
    }
    if (kind === 'tip') {
      return '提示';
    }
    if (kind === 'info') {
      return '信息';
    }
    if (kind === 'note') {
      return '说明';
    }
    if (kind === 'warning') {
      return '注意';
    }
    if (kind === 'danger') {
      return '警告';
    }
    return '提示';
  }

  private static isTableStart(lines: string[], idx: number): boolean {
    const cur: string = lines[idx].trim();
    if (!cur.startsWith('|')) {
      return false;
    }
    if (idx + 1 >= lines.length) {
      return false;
    }
    const next: string = lines[idx + 1].trim();
    if (next.match(new RegExp('^\\|?\\s*:?-{2,}.*$')) === null) {
      return false;
    }
    if (next.indexOf('-') < 0 || next.indexOf('|') < 0) {
      return false;
    }
    return true;
  }

  private static parseTable(lines: string[], start: number): TableParseResult {
    const headers: string[] = MarkdownParser.splitRow(lines[start]);
    let i = start + 2;
    const rows: string[][] = [];
    while (i < lines.length && lines[i].trim().startsWith('|')) {
      rows.push(MarkdownParser.splitRow(lines[i]));
      i++;
    }
    const res = new TableParseResult();
    res.headers = headers;
    res.rows = rows;
    res.next = i;
    return res;
  }

  private static splitRow(line: string): string[] {
    let t: string = line.trim();
    if (t.startsWith('|')) {
      t = t.slice(1);
    }
    if (t.endsWith('|')) {
      t = t.slice(0, t.length - 1);
    }
    const ph: string = '\u0001';
    t = t.split('\\|').join(ph);
    const cells: string[] = t.split('|');
    const out: string[] = [];
    for (let k = 0; k < cells.length; k++) {
      out.push(cells[k].split(ph).join('|').trim());
    }
    return out;
  }

  private static parseList(lines: string[], start: number): ListParseResult {
    const items: MBListItem[] = [];
    let i = start;
    while (i < lines.length) {
      const line: string = lines[i];
      const trimmed: string = line.trim();
      if (trimmed === '') {
        if (i + 1 < lines.length && lines[i + 1].trim().match(new RegExp('^(\\s*)([-*+]|\\d+\\.)\\s+')) !== null) {
          i++;
          continue;
        }
        break;
      }
      const bulletMatch: RegExpMatchArray | null = line.match(new RegExp('^(\\s*)([-*+]|\\d+\\.)\\s+(.*)$'));
      if (bulletMatch !== null) {
        const item = new MBListItem();
        item.level = Math.min(2, Math.floor(bulletMatch[1].replace(new RegExp('\\t', 'g'), '  ').length / 2));
        item.marker = bulletMatch[2];
        item.spans = MarkdownParser.parseInline(bulletMatch[3].trim());
        items.push(item);
        i++;
        continue;
      }
      if (MarkdownParser.isBlockStart(trimmed, lines, i)) {
        break;
      }
      if (items.length > 0) {
        const lastItem: MBListItem = items[items.length - 1];
        if (lastItem.spans.length > 0) {
          lastItem.spans[lastItem.spans.length - 1].text += ' ' + trimmed;
        }
        i++;
        continue;
      }
      break;
    }
    const res = new ListParseResult();
    res.items = items;
    res.next = i;
    return res;
  }

  static parseInline(input: string): InlineSpan[] {
    const spans: InlineSpan[] = [];
    const cleaned: string = input.replace(new RegExp('<[^>]+>', 'g'), '');
    const re: RegExp = new RegExp(MarkdownParser.INLINE_RE.source, 'g');
    let last: number = 0;
    let m: RegExpExecArray | null = re.exec(cleaned);
    while (m !== null) {
      if (m.index > last) {
        spans.push(MarkdownParser.plainSpan(cleaned.substring(last, m.index)));
      }
      if (m[1] !== undefined) {
        const s = new InlineSpan();
        s.text = m[1];
        s.bold = true;
        spans.push(s);
      } else if (m[2] !== undefined) {
        const s = new InlineSpan();
        s.text = m[2];
        s.code = true;
        spans.push(s);
      } else if (m[3] !== undefined) {
        const s = new InlineSpan();
        s.text = m[3];
        s.italic = true;
        spans.push(s);
      } else if (m[4] !== undefined) {
        const url: string = (m[5] !== undefined ? m[5] : '').split('\\|').join('|');
        const s = new InlineSpan();
        s.text = MarkdownParser.stripInline(m[4]);
        if (url.startsWith('doc:')) {
          s.linkDoc = url.slice(4);
        } else if (url.startsWith('http')) {
          s.linkUrl = url;
        }
        spans.push(s);
      }
      last = re.lastIndex;
      m = re.exec(cleaned);
    }
    if (last < cleaned.length) {
      spans.push(MarkdownParser.plainSpan(cleaned.substring(last)));
    }
    return spans;
  }

  private static plainSpan(text: string): InlineSpan {
    const s = new InlineSpan();
    s.text = text;
    return s;
  }

  static stripInline(text: string): string {
    let t: string = text.split('\\|').join('|');
    t = t.replace(new RegExp('\\*\\*([^*]+?)\\*\\*', 'g'), '$1');
    t = t.replace(new RegExp('`([^`\\n]+?)`', 'g'), '$1');
    t = t.replace(new RegExp('\\*([^*\\n]+?)\\*', 'g'), '$1');
    t = t.replace(new RegExp('\\[([^\\]]*?)\\]\\(([^)]*?)\\)', 'g'), '$1');
    t = t.replace(new RegExp('<[^>]+>', 'g'), '');
    return t.trim();
  }

  private static firstInternalDoc(spans: InlineSpan[]): string {
    for (let k = 0; k < spans.length; k++) {
      if (spans[k].linkDoc !== '') {
        return spans[k].linkDoc;
      }
    }
    return '';
  }

  private static firstExternalUrl(spans: InlineSpan[]): string {
    for (let k = 0; k < spans.length; k++) {
      if (spans[k].linkUrl !== '') {
        return spans[k].linkUrl;
      }
    }
    return '';
  }

  private static joinLines(lines: string[]): string {
    let out: string = '';
    for (let k = 0; k < lines.length; k++) {
      if (k === 0) {
        out = lines[k];
      } else {
        out = out + (MarkdownParser.needSpace(out, lines[k]) ? ' ' : '') + lines[k];
      }
    }
    return out;
  }

  private static needSpace(prev: string, next: string): boolean {
    if (prev === '' || next === '') {
      return false;
    }
    const lastCh: string = prev.charAt(prev.length - 1);
    const firstCh: string = next.charAt(0);
    if (MarkdownParser.isCjk(lastCh) || MarkdownParser.isCjk(firstCh)) {
      return false;
    }
    return true;
  }

  private static isCjk(ch: string): boolean {
    const code: number = ch.charCodeAt(0);
    return code >= 0x4E00 && code <= 0x9FFF;
  }
}

class TableParseResult {
  headers: string[] = [];
  rows: string[][] = [];
  next: number = 0;
}

class ListParseResult {
  items: MBListItem[] = [];
  next: number = 0;
}
