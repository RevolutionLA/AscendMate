import { ContentService } from '../service/ContentService';
import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Safe } from '../common/Safe';
import { Theme } from '../common/Theme';
import { DocSummary, HistoryEntry } from '../model/Models';

class QuickEntry {
  icon: IconName = IconName.Doc;
  color: ResourceColor = $r('app.color.text_secondary');
  title: string = '';
  sub: string = '';
  targetKind: string = '';
  target: string = '';

  constructor(icon: IconName, color: ResourceColor, title: string, sub: string, targetKind: string, target: string) {
    this.icon = icon;
    this.color = color;
    this.title = title;
    this.sub = sub;
    this.targetKind = targetKind;
    this.target = target;
  }
}

@Component
export struct HomeTab {
  @StorageLink('histRev') @Watch('onHistRev') histRev: number = 0;
  @State recent: HistoryEntry[] = [];
  @State featureIdx: number = 0;
  private featured: DocSummary[] = [];
  private hot: DocSummary[] = [];
  private quickEntries: QuickEntry[] = [
    new QuickEntry(IconName.Graduation, $r('app.color.text_secondary'), '学 AI', '学习路径', 'page', 'learning'),
    new QuickEntry(IconName.Blocks, $r('app.color.text_secondary'), '看方案', '场景价值', 'category', 'scenes'),
    new QuickEntry(IconName.LinkBox, $r('app.color.text_secondary'), '找资源', '资源导航', 'category', 'resources'),
    new QuickEntry(IconName.Layers, $r('app.color.text_secondary'), '搭环境', '环境搭建', 'category', 'setup'),
    new QuickEntry(IconName.Question, $r('app.color.text_secondary'), '查问题', 'FAQ 速查', 'category', 'faq'),
    new QuickEntry(IconName.Server, $r('app.color.text_secondary'), '识硬件', '昇腾硬件', 'category', 'hardware')
  ];

  aboutToAppear(): void {
    const cs = ContentService.getInstance();
    const pool: DocSummary[] = [];
    const cats = cs.getCategories();
    for (let i = 0; i < cats.length; i++) {
      for (let j = 0; j < cats[i].docs.length; j++) {
        pool.push(cats[i].docs[j]);
      }
    }
    const used: Set<number> = new Set<number>();
    this.featured = [];
    while (this.featured.length < 4 && used.size < pool.length) {
      const pick: number = Math.floor(Math.random() * pool.length);
      if (!used.has(pick)) {
        used.add(pick);
        this.featured.push(pool[pick]);
      }
    }
    this.hot = ContentService.hotDocIds()
      .map((id: string): DocSummary | undefined => cs.findSummary(id))
      .filter((d: DocSummary | undefined): boolean => d !== undefined)
      .map((d: DocSummary | undefined): DocSummary => d as DocSummary);
    this.loadRecent();
  }

  private loadRecent(): void {
    DataService.getInstance().getHistory(3).then((list: HistoryEntry[]) => {
      this.recent = list;
    });
  }

  private onHistRev(): void {
    this.loadRecent();
  }

  private openQuick(entry: QuickEntry): void {
    if (entry.targetKind === 'page') {
      Nav.pushPage(entry.target);
    } else {
      Nav.pushCategory(entry.target);
    }
  }

  build() {
    Scroll() {
      Column() {
        Row({ space: 10 }) {
          Icon({ name: IconName.Search, iconSize: 18, color: $r('app.color.text_tertiary') })
          Text('搜索 npu-smi、CANN安装、FAQ…')
            .fontSize(14)
            .fontColor($r('app.color.text_tertiary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Text('搜索')
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
            .linearGradient({ angle: 90, colors: Theme.brandGradient })
            .borderRadius(6)
            .padding({ left: 14, right: 14, top: 6, bottom: 6 })
        }
        .width('100%')
        .padding({ left: 14, right: 8, top: 8, bottom: 8 })
        .backgroundColor($r('app.color.card_bg'))
        .borderRadius(10)
        .border({ width: 1, color: $r('app.color.divider') })
                      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
.onClick(() => Nav.pushPage('search'))

        Grid() {
          ForEach(this.quickEntries, (entry: QuickEntry) => {
            GridItem() {
              Column({ space: 8 }) {
                Column() {
                  Icon({ name: entry.icon, iconSize: 22, color: entry.color })
                }
                .width(44)
                .height(44)
                .borderRadius(12)
                .backgroundColor($r('app.color.chip_bg'))
                .justifyContent(FlexAlign.Center)
                Text(entry.title)
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                Text(entry.sub)
                  .fontSize(11)
                  .fontColor($r('app.color.text_tertiary'))
              }
              .width('100%')
              .padding({ top: 14, bottom: 14 })
              .borderRadius(10)
              .backgroundColor($r('app.color.card_bg'))
              .border({ width: 1, color: $r('app.color.divider') })
                            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
.onClick(() => this.openQuick(entry))
            }
          }, (entry: QuickEntry) => entry.title)
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
        .width('100%')
        .margin({ top: 16 })

        Row() {
          Text('今日推荐')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Icon({ name: IconName.Sparkle, iconSize: 16, color: $r('app.color.accent') })
        }
        .width('100%')
        .margin({ top: 24, bottom: 10 })

        Swiper() {
          ForEach(this.featured, (doc: DocSummary, idx: number) => {
            Column() {
              Row() {
                Text(doc.categoryTitle)
                  .fontSize(10)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_secondary'))
                  .border({ width: 1, color: $r('app.color.divider') })
                  .borderRadius(999)
                  .padding({ left: 10, right: 10, top: 3, bottom: 3 })
                Blank()
              }
              .width('100%')

              Text(doc.title)
                .fontSize(17)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 10 })
              Text(doc.summary)
                .fontSize(12)
                .fontColor($r('app.color.text_secondary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ top: 6 })
              Blank()
              Row() {
                Text(`${doc.readTime} 分钟阅读`)
                  .fontSize(11)
                  .fontColor($r('app.color.text_tertiary'))
              }
              .width('100%')
            }
            .width('100%')
            .height(132)
            .padding(16)
            .backgroundColor($r('app.color.card_bg'))
            .borderRadius(10)
            .border({ width: 1, color: $r('app.color.divider') })
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
            .onClick(() => Nav.pushDoc(doc.id))
          }, (doc: DocSummary) => doc.id)
        }
        .autoPlay(true)
        .interval(4200)
        .indicator(false)
        .loop(true)
        .onChange((idx: number) => {
          this.featureIdx = idx;
        })
        .width('100%')

        Row({ space: 6 }) {
          ForEach(this.featured, (doc: DocSummary, idx: number) => {
            Column()
              .width(this.featureIdx === idx ? 18 : 6)
              .height(3)
              .borderRadius(2)
              .backgroundColor(this.featureIdx === idx ? $r('app.color.brand') : $r('app.color.divider'))
          }, (doc: DocSummary, idx: number) => `fd${idx}`)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 10 })

        if (this.recent.length > 0) {
          Row() {
            Text('继续阅读')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Blank()
            Icon({ name: IconName.Clock, iconSize: 16, color: $r('app.color.accent') })
          }
          .width('100%')
          .margin({ top: 24, bottom: 10 })

          Column({ space: 10 }) {
            ForEach(this.recent, (entry: HistoryEntry) => {
              Row({ space: 12 }) {
                Column() {
                  Text(entry.title)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('app.color.text_primary'))
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
              }
              .width('100%')
              .padding(14)
              .backgroundColor($r('app.color.card_bg'))
              .borderRadius(Theme.radiusMd)
              .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
              .onClick(() => Nav.pushDoc(entry.docId))
            }, (entry: HistoryEntry) => entry.docId)
          }
        }

        Row() {
          Text('热门推荐')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
          Blank()
          Icon({ name: IconName.Flame, iconSize: 16, color: $r('app.color.warn') })
        }
        .width('100%')
        .margin({ top: 24, bottom: 10 })

        Row({ space: 10 }) {
          Column({ space: 10 }) {
            ForEach(this.hot.filter((d: DocSummary, i: number): boolean => i % 2 === 0), (doc: DocSummary) => {
              this.hotCard(doc)
            }, (doc: DocSummary) => `l${doc.id}`)
          }
          .layoutWeight(1)
          Column({ space: 10 }) {
            ForEach(this.hot.filter((d: DocSummary, i: number): boolean => i % 2 === 1), (doc: DocSummary) => {
              this.hotCard(doc)
            }, (doc: DocSummary) => `r${doc.id}`)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Top)
        .margin({ bottom: 12 })

        Column()
          .height(84 + Safe.bottom())
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 + Safe.top() })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .width('100%')
    .height('100%')
    .align(Alignment.TopStart)
  }

  @Builder
  private hotCard(doc: DocSummary) {
    Column({ space: 8 }) {
      Row({ space: 6 }) {
        Column() {
          Icon({ name: IconName.Doc, iconSize: 12, color: $r('app.color.text_secondary') })
        }
        .width(20)
        .height(20)
        .borderRadius(6)
        .backgroundColor($r('app.color.chip_bg'))
        .justifyContent(FlexAlign.Center)
        Text(doc.categoryTitle)
          .fontSize(10)
          .fontColor($r('app.color.text_tertiary'))
      }
      Text(doc.title)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .lineHeight(20)
        .minLines(2)
      Text(`${doc.readTime} 分钟阅读`)
        .fontSize(10)
        .fontColor($r('app.color.text_tertiary'))
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(14)
    .backgroundColor($r('app.color.card_bg'))
    .borderRadius(Theme.radiusMd)
                  .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
.onClick(() => Nav.pushDoc(doc.id))
  }
}
