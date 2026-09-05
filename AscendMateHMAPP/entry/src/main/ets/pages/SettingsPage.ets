import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Theme } from '../common/Theme';
import { Safe } from '../common/Safe';
import { PageBar } from '../components/Common';

@Component
export struct SettingsPage {
  @StorageLink('themeMode') @Watch('onModeChange') themeMode: number = 0;
  @StorageLink('fontLevel') fontLevel: string = 'M';

  private onModeChange(): void {
  }

  private modeLabel(mode: number): string {
    if (mode === 1) {
      return '浅色';
    }
    if (mode === 2) {
      return '深色';
    }
    return '跟随系统';
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll() {
          Column() {
            Text('外观主题')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
              .margin({ top: 16, bottom: 8 })
              .padding({ left: 6 })

            Column() {
              this.modeRow(0, IconName.Sun, '跟随系统', '与系统深浅色自动保持一致')
              this.modeDivider()
              this.modeRow(1, IconName.Sun, '浅色模式', '白天阅读更清晰')
              this.modeDivider()
              this.modeRow(2, IconName.Moon, '深色模式', '夜间阅读更护眼')
            }
            .width('100%')
            .backgroundColor($r('app.color.card_bg'))
            .borderRadius(Theme.radiusLg)
            .clip(true)

            Text('阅读字号')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
              .margin({ top: 20, bottom: 8 })
              .padding({ left: 6 })

            Column({ space: 12 }) {
              Row({ space: 10 }) {
                ForEach(['S', 'M', 'L', 'XL'], (lv: string) => {
                  Column({ space: 6 }) {
                    Text('昇腾之家')
                      .fontSize(Theme.fontPx(lv))
                      .fontColor($r('app.color.text_primary'))
                      .maxLines(1)
                    Text(lv === 'S' ? '小' : lv === 'M' ? '标准' : lv === 'L' ? '大' : '超大')
                      .fontSize(11)
                      .fontColor($r('app.color.text_tertiary'))
                  }
                  .layoutWeight(1)
                  .height(84)
                  .justifyContent(FlexAlign.Center)
                  .backgroundColor(this.fontLevel === lv ? $r('app.color.brand_soft') : $r('app.color.chip_bg'))
                  .borderRadius(12)
                  .border({ width: 1.5, color: this.fontLevel === lv ? $r('app.color.brand') : Color.Transparent })
                  .onClick(() => {
                    DataService.getInstance().setFontLevel(lv);
                  })
                }, (lv: string) => `${lv}-${this.fontLevel}`)
              }
              .width('100%')
            }
            .width('100%')
            .padding(14)
            .backgroundColor($r('app.color.card_bg'))
            .borderRadius(Theme.radiusLg)

            Text('通用')
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
              .margin({ top: 20, bottom: 8 })
              .padding({ left: 6 })

            Column() {
              Row({ space: 12 }) {
                Icon({ name: IconName.Play, iconSize: 17, color: '#C8102E' })
                Column({ space: 2 }) {
                  Text('重新播放引导页')
                    .fontSize(15)
                    .fontColor($r('app.color.text_primary'))
                  Text('回顾三大核心功能介绍')
                    .fontSize(11)
                    .fontColor($r('app.color.text_tertiary'))
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1)
                Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
              }
              .width('100%')
              .padding({ left: 14, right: 12, top: 13, bottom: 13 })
              .onClick(() => {
                Nav.pop();
                DataService.getInstance().setGuideDone(false);
              })
            }
            .width('100%')
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

        PageBar({ title: '设置' })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_bg'))
  }

  @Builder
  private modeRow(mode: number, icon: IconName, title: string, desc: string) {
    Row({ space: 12 }) {
      Icon({ name: icon, iconSize: 18, color: $r('app.color.brand') })
      Column({ space: 2 }) {
        Text(title)
          .fontSize(15)
          .fontColor($r('app.color.text_primary'))
        Text(desc)
          .fontSize(11)
          .fontColor($r('app.color.text_tertiary'))
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      if (this.themeMode === mode) {
        Icon({ name: IconName.Check, iconSize: 18, color: $r('app.color.brand') })
      }
    }
    .width('100%')
    .padding({ left: 14, right: 12, top: 13, bottom: 13 })
    .onClick(() => {
      DataService.getInstance().setThemeMode(mode);
    })
  }

  @Builder
  private modeDivider() {
    Divider()
      .color($r('app.color.divider'))
      .margin({ left: 44, right: 12 })
  }
}
