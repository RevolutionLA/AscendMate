import { curves } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit';
import { ContentService } from '../service/ContentService';
import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Safe } from '../common/Safe';
import { Theme } from '../common/Theme';
import { InlineSpan, MDBlock, MarkdownParser, MBType } from '../model/Markdown';
import { DocSummary, LearningStage } from '../model/Models';
import { BlockView } from '../components/MarkdownView';

class TocEntry {
  title: string = '';
  level: number = 0;
  index: number = 0;

  constructor(title: string, level: number, index: number) {
    this.title = title;
    this.level = level;
    this.index = index;
  }
}

@Component
export struct DocDetailPage {
  @StorageLink('fontLevel') fontLevel: string = 'M';
  @StorageLink('learnRev') @Watch('onLearnRev') learnRev: number = 0;
  @State docId: string = '';
  @State title: string = '';
  @State catTitle: string = '';
  @State readTime: number = 0;
  @State source: string = '';
  @State blocks: MDBlock[] = [];
  @State tocEntries: TocEntry[] = [];
  @State isFav: boolean = false;
  @State favScale: number = 1;
  @State showToc: boolean = false;
  @State showFontPanel: boolean = false;
  @State searchMode: boolean = false;
  @State searchTerm: string = '';
  @State matchBlocks: number[] = [];
  @State currentMatch: number = 0;
  @State isLearningStage: boolean = false;
  @State stageDone: boolean = false;
  @State prevDoc: DocSummary | undefined = undefined;
  @State nextDoc: DocSummary | undefined = undefined;
  private scroller: Scroller = new Scroller();
  private progress: number = 0;
  private progressDirty: boolean = false;
  private saveTimerId: number = -1;
  private lastTickAt: number = 0;
  private lastSavedProgress: number = 0;
  private saveDebounceId: number = -1;
  private searchDebounceId: number = -1;
  private loaded: boolean = false;

  private fontPx(): number {
    return Theme.fontPx(this.fontLevel);
  }

  private async load(): Promise<void> {
    if (this.loaded) {
      return;
    }
    this.loaded = true;
    const cs = ContentService.getInstance();
    const doc = await cs.getDoc(this.docId);
    if (doc === undefined) {
      return;
    }
    this.title = doc.title;
    this.catTitle = doc.categoryTitle;
    this.readTime = doc.readTime;
    this.source = doc.source;
    const all: MDBlock[] = MarkdownParser.parse(doc.content);
    let start: number = 0;
    if (all.length > 0 && all[0].type === MBType.Heading && all[0].level === 1) {
      start = 1;
    }
    this.blocks = all.slice(start);
    const toc: TocEntry[] = [];
    for (let i = 0; i < this.blocks.length; i++) {
      const b: MDBlock = this.blocks[i];
      if (b.type === MBType.Heading && (b.level === 2 || b.level === 3)) {
        toc.push(new TocEntry(b.text, b.level, i + 1));
      }
    }
    this.tocEntries = toc;
    const neighbors = cs.getNeighbors(this.docId);
    this.prevDoc = neighbors.prev;
    this.nextDoc = neighbors.next;
    const stageIds: LearningStage[] = ContentService.learningStages();
    this.isLearningStage = false;
    for (let i = 0; i < stageIds.length; i++) {
      if (stageIds[i].docId === this.docId) {
        this.isLearningStage = true;
        break;
      }
    }
    const ds = DataService.getInstance();
    this.stageDone = ds.isStageDone(this.docId);
    this.isFav = ds.isFavorite(this.docId);
    const savedProgress: number = await ds.getProgress(this.docId);
    await ds.recordOpen(this.docId, doc.title, doc.category, doc.categoryTitle);
    if (savedProgress >= 0.97) {
      setTimeout(() => {
        this.scroller.scrollToIndex(this.blocks.length + 1, false);
      }, 200);
    } else if (savedProgress > 0.03) {
      const idx: number = Math.max(1, Math.floor(savedProgress * this.blocks.length));
      setTimeout(() => {
        this.scroller.scrollToIndex(idx, false);
      }, 200);
    }
    this.lastTickAt = Date.now();
    this.saveTimerId = setInterval(() => this.flushProgress(), 3000);
  }

  private onLearnRev(): void {
    this.stageDone = DataService.getInstance().isStageDone(this.docId);
  }

  private flushProgress(): void {
    if (this.lastTickAt > 0) {
      const now: number = Date.now();
      const delta: number = now - this.lastTickAt;
      this.lastTickAt = now;
      if (delta > 0 && delta < 30000) {
        DataService.getInstance().addReadSeconds(delta / 1000);
      }
    }
    if (!this.progressDirty || this.docId === '') {
      return;
    }
    this.progressDirty = false;
    const p: number = Math.min(1, this.progress);
    DataService.getInstance().saveProgress(this.docId, p);
    this.lastSavedProgress = p;
  }

  private onScroll(first: number): void {
    if (this.blocks.length === 0) {
      return;
    }
    this.progress = Math.max(0, Math.min(1, (first - 1) / Math.max(1, this.blocks.length)));
    if (Math.abs(this.progress - this.lastSavedProgress) >= 0.02) {
      if (this.saveDebounceId >= 0) {
        clearTimeout(this.saveDebounceId);
      }
      this.saveDebounceId = setTimeout((): void => {
        this.flushProgress();
      }, 400);
    }
  }

  private onSearchInput(value: string): void {
    this.searchTerm = value;
    if (this.searchDebounceId >= 0) {
      clearTimeout(this.searchDebounceId);
    }
    this.searchDebounceId = setTimeout((): void => {
      this.runSearch();
    }, 300);
  }

  private runSearch(): void {
    const q: string = this.searchTerm.trim().toLowerCase();
    this.matchBlocks = [];
    this.currentMatch = 0;
    if (q === '') {
      return;
    }
    for (let i = 0; i < this.blocks.length; i++) {
      if (this.plainOf(this.blocks[i]).toLowerCase().indexOf(q) >= 0) {
        this.matchBlocks.push(i);
      }
    }
    if (this.matchBlocks.length > 0) {
      this.scroller.scrollToIndex(this.matchBlocks[0] + 1, true, ScrollAlign.START);
    }
  }

  private gotoMatch(delta: number): void {
    if (this.matchBlocks.length === 0) {
      return;
    }
    this.currentMatch =
      (this.currentMatch + delta + this.matchBlocks.length) % this.matchBlocks.length;
    this.scroller.scrollToIndex(this.matchBlocks[this.currentMatch] + 1, true, ScrollAlign.START);
  }

  private spansText(spans: InlineSpan[]): string {
    let out: string = '';
    for (let k = 0; k < spans.length; k++) {
      out += spans[k].text;
    }
    return out;
  }

  private plainOf(b: MDBlock): string {
    let out: string = '';
    if (b.type === MBType.Heading) {
      out += b.text + ' ';
    } else if (b.type === MBType.Code) {
      out += b.code + ' ';
    } else if (b.type === MBType.Table) {
      out += b.headers.join(' ') + ' ';
      for (let r = 0; r < b.rows.length; r++) {
        out += b.rows[r].join(' ') + ' ';
      }
    } else if (b.type === MBType.List) {
      for (let i = 0; i < b.items.length; i++) {
        out += this.spansText(b.items[i].spans) + ' ';
      }
    } else if (b.type === MBType.Callout) {
      out += b.title + ' ';
      for (let i = 0; i < b.children.length; i++) {
        out += this.plainOf(b.children[i]);
      }
    } else {
      out += this.spansText(b.spans) + ' ';
    }
    return out;
  }

  private markStageDone(): void {
    DataService.getInstance().markStageDone(this.docId).then(() => {
      this.stageDone = true;
      this.getUIContext().getPromptAction().showToast({ message: '本阶段学习完成，继续加油！' });
    });
  }

  private toggleFavorite(): void {
    const ds = DataService.getInstance();
    ds.toggleFavorite(this.docId, this.title, '', this.catTitle).then((fav: boolean) => {
      this.getUIContext().animateTo({ curve: curves.springMotion(0.36, 0.8) }, () => {
        this.isFav = fav;
        this.favScale = fav ? 1.35 : 0.9;
      });
      setTimeout(() => {
        this.getUIContext().animateTo({ curve: curves.springMotion(0.36, 0.8) }, () => {
          this.favScale = 1;
        });
      }, 180);
      this.getUIContext().getPromptAction().showToast({ message: fav ? '已收藏' : '已取消收藏' });
    });
  }

  private shareDoc(): void {
    const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, this.source);
    pasteboard.getSystemPasteboard().setData(data).then(() => {
      this.getUIContext().getPromptAction().showToast({ message: '文章链接已复制，可粘贴分享' });
    });
  }

  aboutToDisappear(): void {
    if (this.saveTimerId >= 0) {
      clearInterval(this.saveTimerId);
      this.saveTimerId = -1;
    }
    if (this.saveDebounceId >= 0) {
      clearTimeout(this.saveDebounceId);
      this.saveDebounceId = -1;
    }
    if (this.searchDebounceId >= 0) {
      clearTimeout(this.searchDebounceId);
      this.searchDebounceId = -1;
    }
    this.flushProgress();
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        List({ space: 0, scroller: this.scroller }) {
          ListItem() {
            this.titleBlock()
          }
          ForEach(this.blocks, (block: MDBlock, idx: number) => {
            ListItem() {
              Column() {
                BlockView({
                  block: block,
                  fontSize: this.fontPx(),
                  highlight: this.searchMode ? this.searchTerm.trim() : ''
                })
              }
              .padding({ left: 16, right: 16 })
            }
          }, (block: MDBlock, idx: number) => `${idx}-${block.type}`)
          ListItem() {
            this.prevNextBlock()
          }
            ListItem() {
              Row()
                .height(88 + Safe.bottom())
            }
        }
        .width('100%')
        .height('100%')
        .padding({ top: 54 + Safe.top() + (this.searchMode ? 46 : 0) })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .onScrollIndex((first: number, last: number) => {
          this.onScroll(first);
        })
        .onReachEnd(() => {
          this.progress = 1;
          this.progressDirty = true;
          this.flushProgress();
          if (this.isLearningStage && !this.stageDone) {
            this.markStageDone();
          }
        })

        this.topBar()

        Column() {
          Blank()
            .hitTestBehavior(HitTestMode.None)
          this.bottomBar()
        }
        .width('100%')
        .height('100%')
        .hitTestBehavior(HitTestMode.None)

        if (this.showToc) {
          this.tocOverlay()
        }
        if (this.showFontPanel) {
          this.fontOverlay()
        }
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_bg'))
    .onReady((ctx: NavDestinationContext) => {
      this.docId = ctx.pathInfo.param as string;
      this.load();
    })
  }

  @Builder
  private topBar() {
    Column() {
      Row({ space: 4 }) {
        Row() {
          Icon({ name: IconName.Back, iconSize: 20, color: $r('app.color.text_primary') })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => Nav.pop())
        Column({ space: 1 }) {
          Text(this.catTitle)
            .fontSize(10)
            .fontColor($r('app.color.text_tertiary'))
          Text(this.title)
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        .margin({ left: 4 })
        Row() {
          Icon({ name: IconName.Search, iconSize: 19, color: this.searchMode ?
            $r('app.color.brand') : $r('app.color.text_secondary') })
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .onClick(() => {
          this.searchMode = !this.searchMode;
          if (!this.searchMode) {
            this.searchTerm = '';
            this.matchBlocks = [];
            this.currentMatch = 0;
          }
        })
      }
      .width('100%')
      .height(54)

      if (this.searchMode) {
        Row({ space: 8 }) {
          Row({ space: 6 }) {
            Icon({ name: IconName.Search, iconSize: 14, color: $r('app.color.text_tertiary') })
            TextInput({ text: this.searchTerm, placeholder: '在本文中查找…' })
              .placeholderColor($r('app.color.text_tertiary'))
              .placeholderFont({ size: 13 })
              .fontSize(13)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor(Color.Transparent)
              .padding(0)
              .layoutWeight(1)
              .onChange((value: string) => this.onSearchInput(value))
            if (this.searchTerm.trim() !== '') {
              Text(`${this.matchBlocks.length === 0 ? 0 : this.currentMatch + 1}/${this.matchBlocks.length}`)
                .fontSize(11)
                .fontColor($r('app.color.text_tertiary'))
            }
          }
          .layoutWeight(1)
          .height(36)
          .padding({ left: 10, right: 10 })
          .backgroundColor($r('app.color.chip_bg'))
          .borderRadius(8)

          Text(`${this.currentMatch + 1}/${this.matchBlocks.length}`)
            .fontSize(11)
            .fontColor($r('app.color.text_secondary'))
          Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_secondary') })
            .rotate({ angle: -90 })
            .padding(6)
            .onClick(() => this.gotoMatch(-1))
          Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_secondary') })
            .rotate({ angle: 90 })
            .padding(6)
            .onClick(() => this.gotoMatch(1))
        }
        .width('100%')
        .height(46)
        .padding({ left: 6, right: 6, top: 4, bottom: 4 })
      }
    }
    .width('100%')
    .padding({ left: 6, right: 6, top: Safe.top() })
    .backgroundColor($r('app.color.bar_bg'))
    .backgroundBlurStyle(BlurStyle.Regular)
    .border({ width: { bottom: 0.5 }, color: $r('app.color.divider') })
  }

  @Builder
  private titleBlock() {
    Column() {
      Text(this.title)
        .fontSize(23)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .lineHeight(32)
        .width('100%')
      Row({ space: 4 }) {
        Row({ space: 4 }) {
          Icon({ name: IconName.Clock, iconSize: 12, color: $r('app.color.text_tertiary') })
          Text(`${this.readTime} 分钟阅读`)
            .fontSize(11)
            .fontColor($r('app.color.text_tertiary'))
        }
      }
      .width('100%')
      .margin({ top: 10 })
      Divider()
        .color($r('app.color.divider'))
        .margin({ top: 16 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16 })
  }

  @Builder
  private bottomBar() {
    Row() {
      Column({ space: 3 }) {
        Icon({ name: IconName.Star, iconSize: 20, color: this.isFav ? '#F5B301' : $r('app.color.text_secondary') })
          .scale({ x: this.favScale, y: this.favScale })
        Text(this.isFav ? '已收藏' : '收藏')
          .fontSize(10)
          .fontColor(this.isFav ? '#F5B301' : $r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.92 })
      .onClick(() => this.toggleFavorite())

      Column({ space: 3 }) {
        Icon({ name: IconName.Toc, iconSize: 20, color: $r('app.color.text_secondary') })
        Text('目录')
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.92 })
      .onClick(() => {
        this.showToc = true;
      })

      Column({ space: 3 }) {
        Icon({ name: IconName.Doc, iconSize: 20, color: $r('app.color.text_secondary') })
        Text('字号')
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.92 })
      .onClick(() => {
        this.showFontPanel = true;
      })

      Column({ space: 3 }) {
        Icon({ name: IconName.Share, iconSize: 20, color: $r('app.color.text_secondary') })
        Text('分享')
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .height('100%')
      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.92 })
      .onClick(() => this.shareDoc())
    }
    .width('100%')
    .height(56 + Safe.bottom())
    .padding({ bottom: Safe.bottom() })
    .backgroundColor($r('app.color.bar_bg'))
    .backgroundBlurStyle(BlurStyle.Regular)
    .border({ width: { top: 0.5 }, color: $r('app.color.divider') })
  }


  @Builder
  private overlayMask() {
    Column()
      .width('100%')
      .height('100%')
      .backgroundColor('#66000000')
      .onClick(() => {
        this.showToc = false;
        this.showFontPanel = false;
      })
  }

  @Builder
  private tocOverlay() {
    Stack() {
      this.overlayMask()
      Column() {
        Row() {
          Text('目录')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Icon({ name: IconName.Close, iconSize: 16, color: $r('app.color.text_tertiary') })
            .padding(8)
            .onClick(() => {
              this.showToc = false;
            })
        }
        .width('100%')

        if (this.tocEntries.length === 0) {
          Text('本文暂无章节目录')
            .fontSize(13)
            .fontColor($r('app.color.text_tertiary'))
            .width('100%')
            .margin({ top: 24, bottom: 24 })
        } else {
          Scroll() {
            Column() {
              ForEach(this.tocEntries, (entry: TocEntry) => {
                Text(entry.title)
                  .fontSize(entry.level === 2 ? 14 : 13)
                  .fontWeight(entry.level === 2 ? FontWeight.Bold : FontWeight.Normal)
                  .fontColor($r('app.color.text_secondary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .width('100%')
                  .padding({ left: entry.level === 2 ? 0 : 16, top: 11, bottom: 11 })
                  .onClick(() => {
                    this.showToc = false;
                    this.scroller.scrollToIndex(entry.index, true, ScrollAlign.START);
                  })
              }, (entry: TocEntry) => `${entry.index}`)
            }
            .width('100%')
          }
          .scrollBar(BarState.Auto)
          .align(Alignment.Top)
          .layoutWeight(1)
        }
      }
      .width('100%')
      .height('62%')
      .padding({ left: 20, right: 20, top: 18, bottom: 12 })
      .backgroundColor($r('app.color.card_bg'))
      .borderRadius({ topLeft: 20, topRight: 20 })
      .alignItems(HorizontalAlign.Start)
      .transition(TransitionEffect.asymmetric(
        TransitionEffect.translate({ y: 400 }).animation({ duration: 280, curve: Curve.Smooth }),
        TransitionEffect.translate({ y: 400 }).animation({ duration: 240, curve: Curve.Smooth })))
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Bottom)
  }

  @Builder
  private fontOverlay() {
    Stack() {
      this.overlayMask()
      Column({ space: 14 }) {
        Text('阅读字号')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
        Row({ space: 10 }) {
          ForEach(['S', 'M', 'L', 'XL'], (lv: string) => {
            Column({ space: 6 }) {
              Text('昇腾')
                .fontSize(Theme.fontPx(lv) + 2)
                .fontColor($r('app.color.text_primary'))
              Text(lv === 'S' ? '小' : lv === 'M' ? '标准' : lv === 'L' ? '大' : '超大')
                .fontSize(11)
                .fontColor($r('app.color.text_tertiary'))
            }
            .layoutWeight(1)
            .height(80)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(this.fontLevel === lv ? $r('app.color.brand_soft') : $r('app.color.chip_bg'))
            .borderRadius(12)
            .border({
              width: 1.5,
              color: this.fontLevel === lv ? $r('app.color.brand') : Color.Transparent
            })
            .onClick(() => {
              DataService.getInstance().setFontLevel(lv);
            })
          }, (lv: string) => `${lv}-${this.fontLevel}`)
        }
        .width('100%')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 18, bottom: 30 })
      .backgroundColor($r('app.color.card_bg'))
      .borderRadius({ topLeft: 20, topRight: 20 })
      .alignItems(HorizontalAlign.Start)
      .transition(TransitionEffect.asymmetric(
        TransitionEffect.translate({ y: 300 }).animation({ duration: 280, curve: Curve.Smooth }),
        TransitionEffect.translate({ y: 300 }).animation({ duration: 240, curve: Curve.Smooth })))
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Bottom)
  }

  @Builder
  private prevNextBlock() {
    Column() {
      Divider()
        .color($r('app.color.divider'))
        .margin({ top: 18, bottom: 16 })
      if (this.prevDoc !== undefined) {
        Row({ space: 10 }) {
          Column({ space: 3 }) {
            Text('上一篇')
              .fontSize(10)
              .fontColor($r('app.color.text_tertiary'))
            Text((this.prevDoc as DocSummary).title)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.brand'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Icon({ name: IconName.Back, iconSize: 14, color: $r('app.color.brand') })
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.card_bg'))
        .borderRadius(12)
        .margin({ bottom: 10 })
        .onClick(() => {
          Nav.pushDoc((this.prevDoc as DocSummary).id);
        })
      }
      if (this.nextDoc !== undefined) {
        Row({ space: 10 }) {
          Column({ space: 3 }) {
            Text('下一篇')
              .fontSize(10)
              .fontColor($r('app.color.text_tertiary'))
            Text((this.nextDoc as DocSummary).title)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.brand'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Icon({ name: IconName.ChevronRight, iconSize: 14, color: $r('app.color.brand') })
        }
        .width('100%')
        .padding(12)
        .backgroundColor($r('app.color.card_bg'))
        .borderRadius(12)
        .onClick(() => {
          Nav.pushDoc((this.nextDoc as DocSummary).id);
        })
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16 })
  }
}
