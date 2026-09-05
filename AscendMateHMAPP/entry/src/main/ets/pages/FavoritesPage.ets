import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Theme } from '../common/Theme';
import { Safe } from '../common/Safe';
import { FavoriteEntry } from '../model/Models';
import { EmptyState, PageBar } from '../components/Common';

@Component
export struct FavoritesPage {
  @StorageLink('favRev') @Watch('onRev') favRev: number = 0;
  @State favorites: FavoriteEntry[] = [];
  @State loaded: boolean = false;

  aboutToAppear(): void {
    this.reload();
  }

  private onRev(): void {
    this.reload();
  }

  private reload(): void {
    DataService.getInstance().getFavorites().then((list: FavoriteEntry[]) => {
      this.favorites = list;
      this.loaded = true;
    });
  }

  private remove(docId: string): void {
    DataService.getInstance().removeFavorite(docId).then(() => {
      this.getUIContext().getPromptAction().showToast({ message: '已取消收藏' });
    });
  }

  private timeStr(ts: number): string {
    const d = new Date(ts);
    return `${d.getMonth() + 1}月${d.getDate()}日`;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        if (this.loaded && this.favorites.length === 0) {
          Column() {
            EmptyState({
              iconName: IconName.Star,
              iconColor: $r('app.color.text_tertiary'),
              title: '还没有收藏的内容',
              desc: '浏览文章时点击底栏「收藏」即可保存',
              actionLabel: '去首页浏览',
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
                ForEach(this.favorites, (fav: FavoriteEntry, idx: number) => {
                  Column() {
                    Row({ space: 12 }) {
                      Column({ space: 4 }) {
                        Text(fav.title)
                          .fontSize(15)
                          .fontWeight(FontWeight.Medium)
                          .fontColor($r('app.color.text_primary'))
                          .maxLines(2)
                          .textOverflow({ overflow: TextOverflow.Ellipsis })
                        Row({ space: 8 }) {
                          Text(fav.catTitle)
                            .fontSize(10)
                            .fontColor($r('app.color.text_secondary'))
                            .backgroundColor($r('app.color.chip_bg'))
                            .borderRadius(4)
                            .padding({ left: 6, right: 6, top: 2, bottom: 2 })
                          Text(`收藏于 ${this.timeStr(fav.addedAt)}`)
                            .fontSize(10)
                            .fontColor($r('app.color.text_tertiary'))
                        }
                      }
                      .alignItems(HorizontalAlign.Start)
                      .layoutWeight(1)
                      Row() {
                        Icon({ name: IconName.Trash, iconSize: 16, color: $r('app.color.text_tertiary') })
                      }
                      .width(34)
                      .height(34)
                      .justifyContent(FlexAlign.Center)
                      .onClick(() => this.remove(fav.docId))
                      Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
                    }
                    .width('100%')
                    .padding({ left: 14, right: 10, top: 13, bottom: 13 })
                    .onClick(() => Nav.pushDoc(fav.docId))
                    Divider()
                      .color($r('app.color.divider'))
                      .margin({ left: 14, right: 12 })
                  }
                }, (fav: FavoriteEntry) => fav.docId)
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

        PageBar({ title: '收藏夹' })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_bg'))
    .onShown((): void => {
      this.reload();
    })
  }
}
