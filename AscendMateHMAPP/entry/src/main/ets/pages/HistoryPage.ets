import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Theme } from '../common/Theme';
import { Safe } from '../common/Safe';
import { HistoryEntry } from '../model/Models';
import { EmptyState, PageBar } from '../components/Common';

@Component
export struct HistoryPage {
  @StorageLink('histRev') @Watch('onRev') histRev: number = 0;
  @State history: HistoryEntry[] = [];
  @State loaded: boolean = false;
  @State confirmClear: boolean = false;
  private confirmTimerId: number = -1;

  aboutToAppear(): void {
    this.reload();
  }

  private onRev(): void {
    this.reload();
  }

  private reload(): void {
    DataService.getInstance().getHistory(100).then((list: HistoryEntry[]) => {
      this.history = list;
      this.loaded = true;
    });
  }

  private tapClear(): void {
    if (this.confirmClear) {
      if (this.confirmTimerId >= 0) {
        clearTimeout(this.confirmTimerId);
        this.confirmTimerId = -1;
      }
      this.confirmClear = false;
      DataService.getInstance().clearHistory().then(() => {
        this.getUIContext().getPromptAction().showToast({ message: '阅读历史已清空' });
      });
    } else {
      this.confirmClear = true;
      this.confirmTimerId = setTimeout(() => {
        this.confirmClear = false;
        this.confirmTimerId = -1;
      }, 3000);
    }
  }

  private timeStr(ts: number): string {
    const diff: number = Date.now() - ts;
    if (diff < 60000) {
      return '刚刚';
    }
    if (diff < 3600000) {
      return `${Math.floor(diff / 60000)} 分钟前`;
    }
    if (diff < 86400000) {
      return `${Math.floor(diff / 3600000)} 小时前`;
    }
    const d = new Date(ts);
    return `${d.getMonth() + 1}月${d.getDate()}日`;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        if (this.loaded && this.history.length === 0) {
          Column() {
            EmptyState({
              iconName: IconName.Clock,
              iconColor: $r('app.color.text_tertiary'),
              title: '还没有阅读记录',
              desc: '阅读过的文章会自动记录进度',
              actionLabel: '去首页看看',
              onAction: (): void => {
                Nav.pop();
                Nav.goTab(0);
              }
            })
          }
          .width('100%')
          .height('100%')
          .padding({ top: 52 + Safe.top() })
        } else {
          Scroll() {
            Column() {
              Column() {
                ForEach(this.history, (entry: HistoryEntry, idx: number) => {
                  Column() {
                    Row({ space: 12 }) {
                      Column({ space: 5 }) {
                        Text(entry.title)
                          .fontSize(15)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.color.text_primary'))
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        Row({ space: 8 }) {
                          Text(entry.catTitle)
                            .fontSize(10)
                            .fontColor($r('app.color.text_secondary'))
                            .backgroundColor($r('app.color.chip_bg'))
                            .borderRadius(4)
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          Text(this.timeStr(entry.readAt))
                            .fontSize(10)
                            .fontColor($r('app.color.text_tertiary'))
                          Text(`已读`)
                            .fontSize(10)
                            .fontColor($r('app.color.accent'))
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
                    }
                    .width('100%')
                    .padding({ left: 14, right: 12, top: 13, bottom: 13 })
                    .onClick(() => Nav.pushDoc(entry.docId))
                    Divider()
                      .color($r('app.color.divider'))
                      .margin({ left: 14, right: 12 })
                  }
                }, (entry: HistoryEntry) => entry.docId)
              }
              .width('100%')
              .margin({ top: 14, bottom: 24 })
              .backgroundColor($r('app.color.card_bg'))
              .borderRadius(Theme.radiusLg)
              .clip(true)
            }
            .width('100%')
            .padding({ left: 16, right: 16, top: 66 + Safe.top(), bottom: 24 + Safe.bottom() })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
          .align(Alignment.TopStart)
        }

        PageBar({
          title: this.confirmClear ? '确认清空？' : '阅读历史',
          actionLabel: this.history.length > 0 ? (this.confirmClear ? '再点确认' : '清空') : '',
          onAction: (): void => this.tapClear()
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_bg'))
  }
}
