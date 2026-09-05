import { common } from '@kit.AbilityKit';
import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { BrandLogo } from '../common/BrandLogo';
import { Safe } from '../common/Safe';

@Component
export struct GuideView {
  @State pageIdx: number = 0;
  private swiperController: SwiperController = new SwiperController();

  private finish(): void {
    const ctx = getContext(this) as common.UIAbilityContext;
    DataService.getInstance().init(ctx).then(() => {
      DataService.getInstance().setGuideDone(true);
    });
  }

  build() {
    Stack({ alignContent: Alignment.TopEnd }) {
      Column() {
        Swiper(this.swiperController) {
          this.guidePage(IconName.Chip, '昇腾之家', '昇腾智算一站式知识库', true)
          this.guidePage(IconName.Book, '体系化学习路径', '六阶段从零到昇腾 AI 工程师\n进度自动标记，随时继续', false)
          this.guidePage(IconName.Graduation, '想学 · 想查 · 想解决', '学习路径 · 全文搜索 · 问题定位\n30 秒上手，一看就会', false)
        }
        .index(this.pageIdx)
        .loop(false)
        .indicator(false)
        .onChange((idx: number) => {
          this.pageIdx = idx;
        })
        .layoutWeight(1)

        Row({ space: 8 }) {
          ForEach([0, 1, 2], (idx: number) => {
            Column()
              .width(this.pageIdx === idx ? 24 : 6)
              .height(3)
              .borderRadius(2)
              .backgroundColor(this.pageIdx === idx ? $r('app.color.brand') : $r('app.color.divider'))
              .animation({ duration: 250, curve: Curve.EaseInOut })
          }, (idx: number) => `dot${idx}`)
        }
        .margin({ bottom: 30 })

        if (this.pageIdx < 2) {
          Button('下一步')
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor(Color.Transparent)
            .border({ width: 1, color: $r('app.color.divider') })
            .borderRadius(8)
            .height(48)
            .width('100%')
            .onClick(() => {
              this.pageIdx = Math.min(2, this.pageIdx + 1);
            })
        } else {
          Button('开启昇腾之旅')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.brand'))
            .borderRadius(8)
            .height(48)
            .width('100%')
            .shadow({ radius: 18, color: '#4DC8102E', offsetY: 8 })
            .onClick(() => this.finish())
        }
      }
      .padding({ left: 32, right: 32, bottom: 40 + Safe.bottom(), top: 24 + Safe.top() })
      .width('100%')
      .height('100%')

      Text('跳过')
        .fontSize(14)
        .fontColor($r('app.color.text_tertiary'))
        .padding({ top: 16, bottom: 16, left: 16, right: 16 })
        .margin({ top: Safe.top() })
        .onClick(() => this.finish())
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [[$r('app.color.guide_bg_top'), 0], [$r('app.color.guide_bg_bottom'), 1]]
    })
  }

  @Builder
  private guidePage(icon: IconName, title: string, subtitle: string, showMark: boolean) {
    Column({ space: 0 }) {
      Blank()
      if (showMark) {
        BrandLogo({ logoWidth: 224 })
      } else {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width(104)
            .height(104)
            .borderRadius(12)
            .backgroundColor($r('app.color.card_bg'))
            .border({ width: 1, color: $r('app.color.divider') })
          Icon({ name: icon, iconSize: 48, color: $r('app.color.brand') })
        }
        .width(104)
        .height(104)
      }
      Text(title)
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ top: 30 })
      Text(subtitle)
        .fontSize(15)
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
        .lineHeight(25)
        .margin({ top: 14 })
      Blank()
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
