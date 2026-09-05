import { ContentService } from '../service/ContentService';
import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Safe } from '../common/Safe';
import { Theme } from '../common/Theme';
import { CategoryData, DocSummary } from '../model/Models';

@Component
export struct TechNavTab {
  @StorageLink('histRev') @Watch('onRev') histRev: number = 0;
  @State expandedCat: string = '';
  private techNavIds: string[] = ['guide', 'setup', 'training', 'inference', 'ops', 'tools',
    'monitoring', 'operations', 'hardware', 'faq'];

  private onRev(): void {
  }

  private categoryIcon(catId: string): IconName {
    if (catId === 'guide') {
      return IconName.Compass;
    }
    if (catId === 'setup') {
      return IconName.Layers;
    }
    if (catId === 'training') {
      return IconName.Flame;
    }
    if (catId === 'inference') {
      return IconName.Rocket;
    }
    if (catId === 'ops') {
      return IconName.Chip;
    }
    if (catId === 'tools') {
      return IconName.ToolBox;
    }
    if (catId === 'monitoring') {
      return IconName.Pulse;
    }
    if (catId === 'operations') {
      return IconName.Chart;
    }
    if (catId === 'hardware') {
      return IconName.Server;
    }
    return IconName.Question;
  }

  build() {
    Scroll() {
      Column() {
        Row({ space: 10 }) {
          Text('技术导航')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .layoutWeight(1)
          Row() {
            Icon({ name: IconName.Search, iconSize: 18, color: $r('app.color.text_secondary') })
          }
          .width(38)
          .height(38)
          .borderRadius(19)
          .backgroundColor($r('app.color.card_bg'))
          .border({ width: 1, color: $r('app.color.divider') })
          .justifyContent(FlexAlign.Center)
          .onClick(() => Nav.pushPage('search'))
        }
        .width('100%')
        .margin({ bottom: 6 })

        Text('10 大专题 · 快速定位环境、训练、推理与运维文档')
          .fontSize(12)
          .fontColor($r('app.color.text_tertiary'))
          .width('100%')
          .margin({ bottom: 14 })

        Column({ space: 10 }) {
          ForEach(this.techNavIds, (catId: string) => {
            this.techNavCard(catId)
          }, (catId: string) => catId)
        }
        .width('100%')
        .margin({ bottom: 24 + Safe.bottom() + 66 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 + Safe.top() })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
    .align(Alignment.TopStart)
    .width('100%')
    .height('100%')
  }

  @Builder
  private techNavCard(catId: string) {
    Column() {
        Row({ space: 12 }) {
          Column() {
            Icon({ name: this.categoryIcon(catId), iconSize: 18, color: $r('app.color.text_secondary') })
          }
          .width(36)
          .height(36)
          .borderRadius(11)
          .backgroundColor($r('app.color.chip_bg'))
          .justifyContent(FlexAlign.Center)
          Column({ space: 2 }) {
            Text((ContentService.getInstance().getCategory(catId) as CategoryData).title)
              .fontSize(15)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.text_primary'))
            Text(`${(ContentService.getInstance().getCategory(catId) as CategoryData).docs.length} 篇文章`)
              .fontSize(11)
              .fontColor($r('app.color.text_tertiary'))
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
          Icon({ name: IconName.ChevronRight, iconSize: 18, color: $r('app.color.text_tertiary') })
            .rotate({ angle: this.expandedCat === catId ? 90 : 0 })
            .animation({ duration: 200, curve: Curve.EaseInOut })
        }
      .width('100%')
      .padding({ left: 14, right: 12, top: 12, bottom: 12 })
      .onClick(() => {
        this.expandedCat = this.expandedCat === catId ? '' : catId;
      })

      if (this.expandedCat === catId) {
        Column() {
          ForEach((ContentService.getInstance().getCategory(catId) as CategoryData).docs, (doc: DocSummary) => {
            Row({ space: 8 }) {
              Text(doc.title)
                .fontSize(13)
                .fontColor($r('app.color.text_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
              Text(`${doc.readTime} 分钟`)
                .fontSize(10)
                .fontColor($r('app.color.text_tertiary'))
            }
            .width('100%')
            .padding({ left: 18, right: 14, top: 10, bottom: 10 })
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
            .onClick(() => Nav.pushDoc(doc.id))
          }, (doc: DocSummary) => doc.id)
          Row({ space: 6 }) {
            Text('查看全部')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.brand'))
            Icon({ name: IconName.ChevronRight, iconSize: 14, color: $r('app.color.brand') })
          }
          .padding({ left: 18, right: 14, top: 12, bottom: 12 })
          .onClick(() => Nav.pushCategory(catId))
        }
        .width('100%')
        .transition(TransitionEffect.OPACITY.animation({ duration: 200 }).combine(
          TransitionEffect.translate({ y: -8 }).animation({ duration: 200 })))
      }
    }
    .width('100%')
    .backgroundColor($r('app.color.card_bg'))
    .borderRadius(Theme.radiusLg)
    .clip(true)
  }
}
