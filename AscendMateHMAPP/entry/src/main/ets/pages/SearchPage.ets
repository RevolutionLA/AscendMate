import { ContentService } from '../service/ContentService';
import { DataService } from '../service/DataService';
import { SearchService } from '../service/SearchService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Safe } from '../common/Safe';
import { SearchHit } from '../model/Models';
import { EmptyState, HighlightText } from '../components/Common';

class FilterChip {
  id: string = '';
  label: string = '';

  constructor(id: string, label: string) {
    this.id = id;
    this.label = label;
  }
}

@Component
export struct SearchPage {
  @State query: string = '';
  @State committed: string = '';
  @State suggestions: string[] = [];
  @State results: SearchHit[] = [];
  @State filterChips: FilterChip[] = [];
  @State catFilter: string = '';
  @State historyKws: string[] = [];
  private debounceId: number = -1;
  private hotKws: string[] = ContentService.hotKeywords();

  aboutToAppear(): void {
    this.loadHistory();
  }

  private loadHistory(): void {
    DataService.getInstance().getSearchHistory().then((list: string[]) => {
      this.historyKws = list;
    });
  }

  private onInput(value: string): void {
    this.query = value;
    if (this.debounceId >= 0) {
      clearTimeout(this.debounceId);
    }
    if (value.trim() === '') {
      this.suggestions = [];
      this.results = [];
      this.committed = '';
      return;
    }
    this.debounceId = setTimeout(() => {
      this.suggestions = SearchService.getInstance().suggest(value);
    }, 150);
  }

  private commit(kw: string): void {
    const q: string = kw.trim();
    if (q === '') {
      return;
    }
    this.query = q;
    this.committed = q;
    this.suggestions = [];
    this.runSearch();
    DataService.getInstance().addSearchHistory(q).then(() => this.loadHistory());
  }

  private runSearch(): void {
    this.results = SearchService.getInstance().search(this.committed, this.catFilter);
    const chips: FilterChip[] = [new FilterChip('', '全部')];
    const seen: Set<string> = new Set<string>();
    for (let i = 0; i < this.results.length && chips.length < 7; i++) {
      const catId: string = this.results[i].catId;
      if (!seen.has(catId)) {
        seen.add(catId);
        const cat = ContentService.getInstance().getCategory(catId);
        if (cat !== undefined) {
          chips.push(new FilterChip(catId, cat.title));
        }
      }
    }
    this.filterChips = chips;
  }

  private pickFilter(id: string): void {
    this.catFilter = id;
    if (this.committed !== '') {
      this.runSearch();
    }
  }

  private clearInput(): void {
    this.query = '';
    this.committed = '';
    this.suggestions = [];
    this.results = [];
  }

  private clearHistory(): void {
    DataService.getInstance().clearSearchHistory().then(() => {
      this.historyKws = [];
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll() {
          Column() {
            if (this.query === '') {
              this.idleView()
            } else if (this.committed === '' && this.suggestions.length > 0) {
              this.suggestView()
            } else if (this.committed !== '') {
              this.resultView()
            }
          }
          .width('100%')
          .padding({ top: 76 + Safe.top(), left: 16, right: 16, bottom: 24 + Safe.bottom() })
        }
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)
        .width('100%')
        .height('100%')

        Row({ space: 10 }) {
          Row() {
            Icon({ name: IconName.Back, iconSize: 20, color: $r('app.color.text_primary') })
          }
          .width(38)
          .height(38)
          .justifyContent(FlexAlign.Center)
          .onClick(() => Nav.pop())

          Row({ space: 8 }) {
            Icon({ name: IconName.Search, iconSize: 16, color: $r('app.color.text_tertiary') })
            TextInput({ placeholder: '搜索 npu-smi、CANN安装、FAQ…', text: this.query })
              .placeholderColor($r('app.color.text_tertiary'))
              .placeholderFont({ size: 14 })
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .backgroundColor(Color.Transparent)
              .padding(0)
              .layoutWeight(1)
              .id('searchInput')
              .defaultFocus(true)
              .onChange((value: string) => this.onInput(value))
              .onSubmit(() => this.commit(this.query))
            if (this.query !== '') {
              Icon({ name: IconName.Close, iconSize: 14, color: $r('app.color.text_tertiary') })
                .onClick(() => this.clearInput())
            }
          }
          .layoutWeight(1)
          .height(40)
          .padding({ left: 12, right: 10 })
          .backgroundColor($r('app.color.chip_bg'))
          .borderRadius(10)
        }
        .width('100%')
        .height(54 + Safe.top())
        .padding({ left: 12, right: 12, top: Safe.top() })
        .backgroundColor($r('app.color.bar_bg'))
        .backgroundBlurStyle(BlurStyle.Regular)
        .border({ width: { bottom: 0.5 }, color: $r('app.color.divider') })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_bg'))
    .onShown((): void => {
      setTimeout((): void => {
        this.getUIContext().getFocusController().requestFocus('searchInput');
      }, 120);
    })
  }

  @Builder
  private chipRow(label: string, kws: string[], closable: boolean) {
    Column({ space: 10 }) {
      Row() {
        Text(label)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
        Blank()
        if (closable) {
          Row() {
            Icon({ name: IconName.Trash, iconSize: 15, color: $r('app.color.text_tertiary') })
          }
          .padding(6)
          .onClick(() => this.clearHistory())
        }
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(kws, (kw: string) => {
          Text(kw)
            .fontSize(13)
            .fontColor($r('app.color.text_secondary'))
            .backgroundColor($r('app.color.chip_bg'))
            .borderRadius(16)
            .padding({ left: 14, right: 14, top: 8, bottom: 8 })
            .margin({ right: 8, bottom: 8 })
            .onClick(() => this.commit(kw))
        }, (kw: string) => kw)
      }
      .width('100%')
    }
    .width('100%')
    .margin({ bottom: 20 })
  }

  @Builder
  private idleView() {
    Column() {
      this.chipRow('热门搜索', this.hotKws, false)
      if (this.historyKws.length > 0) {
        this.chipRow('搜索历史', this.historyKws, true)
      }

    }
    .width('100%')
  }

  @Builder
  private suggestView() {
    Column() {
      ForEach(this.suggestions, (sug: string) => {
        Row({ space: 10 }) {
          Icon({ name: IconName.Search, iconSize: 14, color: $r('app.color.text_tertiary') })
          Text(sug)
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          Icon({ name: IconName.ChevronRight, iconSize: 14, color: $r('app.color.text_tertiary') })
        }
        .width('100%')
        .padding({ top: 12, bottom: 12, left: 6, right: 6 })
        .borderRadius(10)
                      .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
.onClick(() => this.commit(sug))
      }, (sug: string) => sug)
    }
    .width('100%')
  }

  @Builder
  private resultView() {
    Column() {
      if (this.filterChips.length > 1) {
        Scroll() {
          Row({ space: 8 }) {
            ForEach(this.filterChips, (chip: FilterChip) => {
              Text(chip.label)
                .fontSize(12)
                .fontWeight(this.catFilter === chip.id ? FontWeight.Bold : FontWeight.Normal)
                .fontColor(this.catFilter === chip.id ? Color.White : $r('app.color.text_secondary'))
                .backgroundColor(this.catFilter === chip.id ? $r('app.color.brand') : $r('app.color.chip_bg'))
                .borderRadius(14)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .onClick(() => this.pickFilter(chip.id))
            }, (chip: FilterChip) => `${chip.id}-${this.catFilter}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
        .margin({ bottom: 6 })
      }

      if (this.results.length === 0) {
        EmptyState({
          iconName: IconName.Search,
          title: '未找到相关内容',
          desc: `没有匹配「${this.committed}」的结果，换个关键词试试\n或点击下方热门词直接搜索`
        })
        this.chipRow('试试这些', this.hotKws.slice(0, 5), false)
      } else {
        Text(`找到 ${this.results.length} 条结果`)
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .width('100%')
          .margin({ bottom: 4 })
        Column() {
          ForEach(this.results, (hit: SearchHit, idx: number) => {
            Column({ space: 6 }) {
              Row({ space: 8 }) {
                Text(hit.breadcrumb)
                  .fontSize(10)
                  .fontColor($r('app.color.brand'))
                  .backgroundColor($r('app.color.brand_soft'))
                  .borderRadius(4)
                  .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                Blank()
              }
              .width('100%')
              HighlightText({
                segments: hit.title,
                fontSize: 15,
                fontWeightVal: 600
              })
              HighlightText({
                segments: hit.excerpt,
                fontSize: 12,
                color: $r('app.color.text_tertiary')
              })
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding({ top: 12, bottom: 12, left: 4, right: 4 })
            .borderRadius(12)
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
            .onClick(() => Nav.pushDoc(hit.docId))
            .transition(TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.animation({
                duration: 280,
                curve: Curve.Friction,
                delay: Math.min(idx, 10) * 45
              }).combine(TransitionEffect.translate({
                y: 18
              }).animation({
                duration: 280,
                curve: Curve.Friction,
                delay: Math.min(idx, 10) * 45
              })),
              TransitionEffect.OPACITY.animation({ duration: 100 })))
            .margin({ bottom: 2 })
          }, (hit: SearchHit) => hit.docId)
        }
        .width('100%')
      }
    }
    .width('100%')
  }
}
