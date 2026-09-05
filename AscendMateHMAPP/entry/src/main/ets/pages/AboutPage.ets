import { common, Want } from '@kit.AbilityKit';
import { ContentService } from '../service/ContentService';
import { Icon, IconName } from '../common/Icon';
import { Theme } from '../common/Theme';
import { Safe } from '../common/Safe';
import { PageBar } from '../components/Common';
import { BrandLogo } from '../common/BrandLogo';

@Component
export struct AboutPage {
  private catalogVersion: string = ContentService.getInstance().getCatalog().version;
  private builtAt: string = ContentService.getInstance().getCatalog().builtAt;

  private openInBrowser(url: string): void {
    const ctx = getContext(this) as common.UIAbilityContext;
    const want: Want = {
      action: 'ohos.want.action.viewData',
      uri: url,
      entities: ['entity.system.browser']
    };
    ctx.startAbility(want).catch(() => {
      this.getUIContext().getPromptAction().showToast({ message: '无法打开链接' });
    });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll() {
          Column() {
            Column({ space: 10 }) {
              BrandLogo({ logoWidth: 200 })
              Text('昇腾之家')
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.text_primary'))
              Text('AscendMate · v1.0.0')
                .fontSize(12)
                .fontColor($r('app.color.text_tertiary'))
            }
            .width('100%')
            .margin({ top: 24, bottom: 20 })

            Column({ space: 10 }) {
              Text('昇腾智算生态一站式知识库：学习路径、环境搭建、模型训练推理、算子开发、运维监控、场景价值与算力运营。')
                .fontSize(13)
                .fontColor($r('app.color.text_secondary'))
                .lineHeight(22)
            }
            .width('100%')
            .padding(16)
            .backgroundColor($r('app.color.card_bg'))
            .borderRadius(Theme.radiusLg)

            Column() {
              this.infoRow(IconName.LinkBox, '内容版本', `v${this.catalogVersion} · ${this.builtAt}`)
              this.infoDivider()
              this.infoRow(IconName.Check, '数据安全', '数据仅存本机 · 无账号 · 卸载即清除')
              this.infoDivider()
              this.infoRow(IconName.User, '作者', '薄文慧 · revolutionla.github.io')
              this.infoDivider()
              this.infoRow(IconName.Doc, '开源仓库', 'github.com/RevolutionLA/AscendMate')
            }
            .width('100%')
            .margin({ top: 12 })
            .backgroundColor($r('app.color.card_bg'))
            .borderRadius(Theme.radiusLg)
            .clip(true)

            Button('检查更新')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.brand'))
              .backgroundColor($r('app.color.brand_soft'))
              .borderRadius(22)
              .height(42)
              .width('100%')
              .margin({ top: 16 })
              .onClick(() => {
                const ctx = getContext(this) as common.UIAbilityContext;
                const want: Want = {
                  uri: 'store://appgallery.huawei.com/app/detail?id=com.BWH.AscendMate'
                };
                ctx.startAbility(want).catch(() => {
                  this.getUIContext().getPromptAction().showToast({ message: '未检测到应用市场' });
                });
              })

            Text('昇腾万里，让智能无所不及')
              .fontSize(11)
              .fontColor($r('app.color.text_tertiary'))
              .margin({ top: 20, bottom: 28 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 66 + Safe.top(), bottom: 24 + Safe.bottom() })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)

        PageBar({ title: '关于昇腾之家' })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('app.color.page_bg'))
  }

  @Builder
  private infoRow(icon: IconName, title: string, value: string) {
    Row({ space: 12 }) {
      Icon({ name: icon, iconSize: 17, color: $r('app.color.brand') })
      Text(title)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
      Blank()
      Text(value)
        .fontSize(11)
        .fontColor($r('app.color.text_tertiary'))
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .padding({ left: 14, right: 12, top: 13, bottom: 13 })
    .onClick(() => {
      if (title === '开源仓库') {
        this.openInBrowser('https://github.com/RevolutionLA/AscendMate');
      } else if (title === '作者') {
        this.openInBrowser('https://revolutionla.github.io/');
      }
    })
  }

  @Builder
  private infoDivider() {
    Divider()
      .color($r('app.color.divider'))
      .margin({ left: 43, right: 12 })
  }
}
