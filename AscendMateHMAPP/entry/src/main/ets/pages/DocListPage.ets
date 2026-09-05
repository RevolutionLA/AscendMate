import { ContentService } from '../service/ContentService';
import { DataService } from '../service/DataService';
import { Nav } from '../common/Nav';
import { Theme } from '../common/Theme';
import { Safe } from '../common/Safe';
import { CategoryData, DocSummary } from '../model/Models';
import { DocRow, PageBar } from '../components/Common';

@Component
export struct DocListPage {
  @State catId: string = '';
  @State loaded: boolean = false;

  private cat(): CategoryData | undefined {
    return ContentService.getInstance().getCategory(this.catId);
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll() {
          Column() {
            if (this.cat() !== undefined) {
              Text((this.cat() as CategoryData).desc)
                .fontSize(13)
                .fontColor($r('app.color.text_tertiary'))
                .width('100%')
                .padding({ left: 20, right: 20, top: 14, bottom: 6 })
              Column() {
                ForEach((this.cat() as CategoryData).docs, (doc: DocSummary, idx: number) => {
                  Column() {
                    DocRow({
                      doc: doc,
                      read: DataService.getInstance().isRead(doc.id),
                      onOpen: (id: string) => Nav.pushDoc(id)
                    })
                    Divider()
                      .color($r('app.color.divider'))
                      .margin({ left: 16, right: 12 })
                  }
                }, (doc: DocSummary) => `${doc.id}-${DataService.getInstance().isRead(doc.id) ? 1 : 0}`)
              }
              .width('100%')
              .margin({ top: 8, bottom: 24, left: 16, right: 16 })
              .backgroundColor($r('app.color.card_bg'))
              .borderRadius(Theme.radiusLg)
              .clip(true)
            }
          }
          .width('100%')
          .padding({ top: 66 + Safe.top(), bottom: 24 + Safe.bottom() })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)

        PageBar({
          title: this.loaded && this.cat() !== undefined ? (this.cat() as CategoryData).title : '文档列表'
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_bg'))
    .onReady((ctx: NavDestinationContext) => {
      this.catId = ctx.pathInfo.param as string;
      this.loaded = true;
    })
  }
}
