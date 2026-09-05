import { pasteboard } from '@kit.BasicServicesKit';
import { common, Want } from '@kit.AbilityKit';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { InlineSpan, MDBlock, MBListItem, MBType, MarkdownParser } from '../model/Markdown';

@Component
export struct BlockView {
  @Prop fontSize: number = 15;
  block: MDBlock = new MDBlock();
  private lastSelected: string = '';
  @Prop highlight: string = '';

  build() {
    Column() {
      if (this.block.type === MBType.Heading) {
        this.headingView()
      } else if (this.block.type === MBType.Paragraph) {
        this.paraView()
      } else if (this.block.type === MBType.Code) {
        this.codeView()
      } else if (this.block.type === MBType.Quote) {
        this.quoteView()
      } else if (this.block.type === MBType.List) {
        this.listView()
      } else if (this.block.type === MBType.Table) {
        this.tableView()
      } else if (this.block.type === MBType.Callout) {
        this.calloutView()
      } else {
        this.hrView()
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private headingView() {
    if (this.block.level === 2) {
      Text(this.block.text)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 22, bottom: 8 })
        .width('100%')
    } else if (this.block.level === 3) {
      Text(this.block.text)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 16, bottom: 6 })
        .width('100%')
    } else {
      Text(this.block.text)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.brand'))
        .margin({ top: 12, bottom: 4 })
        .width('100%')
    }
  }

  @Builder
  private spanText(spans: InlineSpan[], color: ResourceColor) {
    Text() {
      ForEach(this.segmentsOf(spans), (s: InlineSpan, idx: number) => {
        Span(s.text)
          .fontSize(this.fontSize)
          .fontColor(this.spanColor(s, color))
          .fontWeight(s.hit ? FontWeight.Bold : (s.bold ? FontWeight.Bold : FontWeight.Normal))
          .fontStyle(s.italic ? FontStyle.Italic : FontStyle.Normal)
          .fontFamily(s.code ? 'monospace' : 'sans-serif')
          .textBackgroundStyle({
            color: s.hit ? $r('app.color.brand_soft') : Color.Transparent,
            radius: 3
          })
          .decoration(s.linkDoc !== '' || s.linkUrl !== '' ? { type: TextDecorationType.Underline } :
          { type: TextDecorationType.None })
          .onClick(() => this.openSpan(s))
      }, (s: InlineSpan, idx: number) => `${idx}-${s.text.length}-${s.hit ? 1 : 0}`)
    }
    .fontSize(this.fontSize)
    .lineHeight(this.fontSize * 1.72)
    .width('100%')
    .copyOption(CopyOptions.InApp)
    .onTextSelectionChange((start: number, end: number) => {
      this.copySelection(spans, start, end);
    })
  }

  private segmentsOf(spans: InlineSpan[]): InlineSpan[] {
    const term: string = this.highlight.trim().toLowerCase();
    if (term === '') {
      return spans;
    }
    const out: InlineSpan[] = [];
    for (let k = 0; k < spans.length; k++) {
      const s: InlineSpan = spans[k];
      const lower: string = s.text.toLowerCase();
      let i = 0;
      while (i <= lower.length) {
        const idx: number = lower.indexOf(term, i);
        if (idx < 0) {
          if (i < s.text.length) {
            out.push(this.piece(s, i, s.text.length, false));
          }
          break;
        }
        if (idx > i) {
          out.push(this.piece(s, i, idx, false));
        }
        out.push(this.piece(s, idx, idx + term.length, true));
        i = idx + term.length;
      }
    }
    if (out.length === 0) {
      return spans;
    }
    return out;
  }

  private piece(s: InlineSpan, from: number, to: number, hit: boolean): InlineSpan {
    const p = new InlineSpan();
    p.text = s.text.substring(from, to);
    p.bold = s.bold;
    p.italic = s.italic;
    p.code = s.code;
    p.linkDoc = s.linkDoc;
    p.linkUrl = s.linkUrl;
    p.hit = hit;
    return p;
  }

  private openSpan(s: InlineSpan): void {
    if (s.linkDoc !== '') {
      Nav.pushDoc(s.linkDoc);
      return;
    }
    if (s.linkUrl !== '') {
      const ctx = getContext(this) as common.UIAbilityContext;
      const want: Want = {
        action: 'ohos.want.action.viewData',
        uri: s.linkUrl,
        entities: ['entity.system.browser']
      };
      ctx.startAbility(want).catch(() => {
        this.getUIContext().getPromptAction().showToast({ message: '无法打开外部链接' });
      });
    }
  }

  private spansPlainText(spans: InlineSpan[]): string {
    let out: string = '';
    for (let k = 0; k < spans.length; k++) {
      out += spans[k].text;
    }
    return out;
  }

  private copySelection(spans: InlineSpan[], start: number, end: number): void {
    if (end <= start) {
      return;
    }
    const full: string = this.spansPlainText(spans);
    if (end > full.length) {
      return;
    }
    const sel: string = full.substring(start, end);
    if (sel.trim() === '' || sel === this.lastSelected) {
      return;
    }
    this.lastSelected = sel;
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, sel);
    pasteboard.getSystemPasteboard().setData(data).then(() => {
      this.getUIContext().getPromptAction().showToast({ message: '所选内容已复制' });
    });
  }

  private spanColor(s: InlineSpan, base: ResourceColor): ResourceColor {
    if (s.code) {
      return $r('app.color.inline_code');
    }
    if (s.linkDoc !== '' || s.linkUrl !== '') {
      return $r('app.color.brand');
    }
    return base;
  }

  @Builder
  private paraView() {
    Column() {
      this.spanText(this.block.spans, $r('app.color.text_primary'))
    }
    .width('100%')
  }

  @Builder
  private codeView() {
    Column() {
      Row() {
        Text(this.block.lang !== '' ? this.block.lang.toUpperCase() : 'CODE')
          .fontSize(10)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_tertiary'))
          .letterSpacing(1)
        Blank()
        Row({ space: 4 }) {
          Icon({ name: IconName.Copy, iconSize: 13, color: $r('app.color.text_secondary') })
          Text('复制')
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
        }
        .padding({ left: 10, right: 10, top: 5, bottom: 5 })
        .borderRadius(10)
        .backgroundColor($r('app.color.ripple'))
        .onClick(() => this.copyCode())
      }
      .width('100%')
      .padding({ left: 14, right: 8, top: 8, bottom: 4 })

      Scroll() {
        Column() {
          ForEach(this.codeLines(), (line: string, li: number) => {
            Text(line)
              .fontSize(12.5)
              .fontFamily('monospace')
              .fontColor($r('app.color.code_fg'))
              .lineHeight(20)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Clip })
          }, (line: string, li: number) => `cl${li}`)
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 14, right: 14, top: 6, bottom: 12 })
        .constraintSize({ minWidth: '100%' })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Auto)
      .width('100%')
      .align(Alignment.Start)
    }
    .backgroundColor($r('app.color.code_bg'))
    .borderRadius(12)
    .clip(true)
    .margin({ top: 10, bottom: 10 })
    .width('100%')
  }

  private codeLines(): string[] {
    return this.block.code.split('\n');
  }

  private copyCode(): void {
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.block.code);
    pasteboard.getSystemPasteboard().setData(data).then(() => {
      this.getUIContext().getPromptAction().showToast({ message: '代码已复制' });
    }).catch(() => {
      this.getUIContext().getPromptAction().showToast({ message: '复制失败' });
    });
  }

  @Builder
  private quoteView() {
    Column() {
      this.spanText(this.block.spans, $r('app.color.text_secondary'))
    }
    .width('100%')
    .backgroundColor($r('app.color.quote_bg'))
    .borderRadius({ topLeft: 4, topRight: 12, bottomLeft: 4, bottomRight: 12 })
    .border({ width: { left: 3 }, color: $r('app.color.accent') })
    .padding({ top: 12, bottom: 12, left: 12, right: 12 })
    .margin({ top: 8, bottom: 8 })
  }

  @Builder
  private listView() {
    Column({ space: 4 }) {
      ForEach(this.block.items, (item: MBListItem, idx: number) => {
        Row({ space: 8 }) {
          Text(this.itemMarker(item, idx))
            .fontSize(this.fontSize)
            .fontColor($r('app.color.brand'))
            .fontWeight(FontWeight.Medium)
            .width(this.itemMarkerWidth(item))
          Column() {
            this.spanText(item.spans, $r('app.color.text_primary'))
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .padding({ left: item.level * 18 })
      }, (item: MBListItem, idx: number) => `${idx}-${item.marker}`)
    }
    .width('100%')
    .margin({ top: 4, bottom: 4 })
  }

  private itemMarker(item: MBListItem, idx: number): string {
    if (item.marker.match(new RegExp('^\\d+\\.$')) !== null) {
      return item.marker;
    }
    if (item.level === 1) {
      return '◦';
    }
    if (item.level >= 2) {
      return '·';
    }
    return '•';
  }

  private itemMarkerWidth(item: MBListItem): number {
    if (item.marker.match(new RegExp('^\\d+\\.$')) !== null) {
      return 24;
    }
    return 14;
  }

  @Builder
  private tableView() {
    Scroll() {
      Column() {
        Row() {
          ForEach(this.block.headers, (h: string, hi: number) => {
            Text(MarkdownParser.stripInline(h))
              .fontSize(12)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
              .width(this.colWidth(hi))
              .padding({ left: 10, right: 10, top: 9, bottom: 9 })
          }, (h: string, hi: number) => `h${hi}`)
        }
        .backgroundColor($r('app.color.chip_bg'))
        .border({ width: { bottom: 1.5 }, color: $r('app.color.divider') })

        ForEach(this.block.rows, (row: string[], ri: number) => {
          Row() {
            ForEach(row, (cell: string, ci: number) => {
              Text() {
                ForEach(MarkdownParser.parseInline(cell), (s: InlineSpan, si: number) => {
                  Span(s.text)
                    .fontSize(12)
                    .fontColor(this.cellColor(s))
                    .fontWeight(s.bold ? FontWeight.Bold : FontWeight.Normal)
                    .fontFamily(s.code ? 'monospace' : 'sans-serif')
                    .decoration(s.linkDoc !== '' || s.linkUrl !== '' ?
                    { type: TextDecorationType.Underline } : { type: TextDecorationType.None })
                    .onClick(() => this.openSpan(s))
                }, (s: InlineSpan, si: number) => `s${si}`)
              }
              .width(this.colWidth(ci))
              .padding({ left: 10, right: 10, top: 9, bottom: 9 })
            }, (cell: string, ci: number) => `c${ci}`)
          }
          .border({ width: { bottom: 0.5 }, color: $r('app.color.divider') })
        }, (row: string[], ri: number) => `r${ri}`)
      }
      .alignItems(HorizontalAlign.Start)
      .constraintSize({ minWidth: '100%' })
      .borderRadius(10)
      .clip(true)
      .backgroundColor($r('app.color.card_bg'))
      .border({ width: 1, color: $r('app.color.divider') })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Auto)
    .width('100%')
    .margin({ top: 10, bottom: 10 })
  }

  private estTextWidth(s: string): number {
    let w: number = 0;
    for (let i = 0; i < s.length; i++) {
      const code: number = s.charCodeAt(i);
      const isWide: boolean = (code >= 0x2E80 && code <= 0x9FFF) || (code >= 0xFF00 && code <= 0xFFEF);
      w += isWide ? 12 : 6.6;
    }
    return w;
  }

  private cellColor(s: InlineSpan): ResourceColor {
    if (s.code) {
      return $r('app.color.inline_code');
    }
    if (s.linkDoc !== '' || s.linkUrl !== '') {
      return $r('app.color.brand');
    }
    return $r('app.color.text_secondary');
  }

  private colWidth(ci: number): number {
    const headers: string[] = this.block.headers;
    if (ci < 0 || ci >= headers.length) {
      return 76;
    }
    let maxW: number = this.estTextWidth(MarkdownParser.stripInline(headers[ci]));
    for (let ri = 0; ri < this.block.rows.length; ri++) {
      const row: string[] = this.block.rows[ri];
      const cell: string = ci < row.length ? MarkdownParser.stripInline(row[ci]) : '';
      maxW = Math.max(maxW, this.estTextWidth(cell));
    }
    return Math.min(280, Math.max(76, maxW + 20));
  }

  @Builder
  private calloutView() {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Icon({ name: this.calloutIcon(), iconSize: 15, color: this.calloutColor() })
        Text(this.block.title)
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.calloutColor())
      }
      ForEach(this.block.children, (child: MDBlock, ci: number) => {
        BlockView({ block: child, fontSize: this.fontSize })
      }, (child: MDBlock, ci: number) => `cc${ci}`)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.calloutBg())
    .borderRadius(12)
    .padding(14)
    .margin({ top: 10, bottom: 10 })
  }

  private calloutIcon(): IconName {
    if (this.block.kind === 'warning' || this.block.kind === 'danger') {
      return IconName.Alert;
    }
    if (this.block.kind === 'info' || this.block.kind === 'note' || this.block.kind === 'details') {
      return IconName.Info;
    }
    return IconName.Sparkle;
  }

  private calloutColor(): ResourceColor {
    if (this.block.kind === 'warning') {
      return $r('app.color.warn');
    }
    if (this.block.kind === 'danger') {
      return $r('app.color.danger');
    }
    return $r('app.color.brand');
  }

  private calloutBg(): ResourceColor {
    if (this.block.kind === 'warning') {
      return $r('app.color.callout_warn_bg');
    }
    if (this.block.kind === 'danger') {
      return $r('app.color.callout_danger_bg');
    }
    if (this.block.kind === 'tip') {
      return $r('app.color.callout_tip_bg');
    }
    return $r('app.color.callout_info_bg');
  }

  @Builder
  private hrView() {
    Divider()
      .color($r('app.color.divider'))
      .margin({ top: 16, bottom: 16 })
  }
}
