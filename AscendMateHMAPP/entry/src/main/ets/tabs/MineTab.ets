import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Safe } from '../common/Safe';
import { Theme } from '../common/Theme';

@Component
export struct MineTab {
  @StorageLink('favRev') @Watch('onRev') favRev: number = 0;
  @StorageLink('histRev') @Watch('onRev') histRev: number = 0;
  @StorageLink('learnRev') @Watch('onRev') learnRev: number = 0;
  @State favCount: number = 0;
  @State readCount: number = 0;
  @State doneStages: number = 0;
  @State readHours: string = '0.0';

  aboutToAppear(): void {
    this.reload();
  }

  private onRev(): void {
    this.reload();
  }

  private reload(): void {
    const ds = DataService.getInstance();
    this.favCount = ds.favoriteCount();
    this.readCount = ds.readCount();
    this.doneStages = ds.doneStageCount();
    const hours: number = ds.getTotalReadSeconds() / 3600;
    this.readHours = hours.toFixed(1);
  }

  build() {
    Scroll() {
      Column() {
        Text('我的')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .margin({ bottom: 14 })

        Row() {
          this.statCell(IconName.Clock, '已读篇数')
          Divider().vertical(true).height(32).color($r('app.color.divider'))
          this.statCell(IconName.Star, '收藏篇数')
          Divider().vertical(true).height(32).color($r('app.color.divider'))
          this.statCell(IconName.Clock, '学习时长')
        }
        .width('100%')
        .padding({ top: 18, bottom: 18 })
        .backgroundColor($r('app.color.card_bg'))
        .borderRadius(Theme.radiusLg)
        .border({ width: 1, color: $r('app.color.divider') })

        Column() {
          this.menuRow(IconName.Star, '收藏夹', () => Nav.pushPage('favorites'))
          this.menuDivider()
          this.menuRow(IconName.Clock, '阅读历史', () => Nav.pushPage('history'))
          this.menuDivider()
          this.menuRow(IconName.Graduation, '学习进度', () => Nav.pushPage('learning'))
        }
        .width('100%')
        .backgroundColor($r('app.color.card_bg'))
        .borderRadius(Theme.radiusLg)
        .border({ width: 1, color: $r('app.color.divider') })
        .margin({ top: 12 })
        .clip(true)

        Column() {
          this.menuRow(IconName.Sliders, '设置', () => Nav.pushPage('settings'))
          this.menuDivider()
          this.menuRow(IconName.Info, '关于昇腾之家', () => Nav.pushPage('about'))
        }
        .width('100%')
        .backgroundColor($r('app.color.card_bg'))
        .borderRadius(Theme.radiusLg)
        .border({ width: 1, color: $r('app.color.divider') })
        .margin({ top: 12, bottom: 24 + Safe.bottom() + 66 })
        .clip(true)
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

  private statValue(label: string): string {
    if (label === '已读篇数') {
      return `${this.readCount}`;
    }
    if (label === '收藏篇数') {
      return `${this.favCount}`;
    }
    return `${this.readHours}h`;
  }

  @Builder
  private statCell(icon: IconName, label: string) {
    Column({ space: 6 }) {
      Text(this.statValue(label))
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_tertiary'))
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
  }

  private menuSub(title: string): string {
    if (title === '收藏夹') {
      return `${this.favCount} 篇`;
    }
    if (title === '阅读历史') {
      return `${this.readCount} 篇`;
    }
    if (title === '学习进度') {
      return `${this.doneStages}/6 阶段`;
    }
    if (title === '设置') {
      return '主题 · 字号 · 引导';
    }
    return 'v1.0.0';
  }

  @Builder
  private menuRow(icon: IconName, title: string, onTap: () => void) {
    Row({ space: 12 }) {
      Column() {
        Icon({ name: icon, iconSize: 17, color: $r('app.color.text_secondary') })
      }
      .width(34)
      .height(34)
      .borderRadius(10)
      .backgroundColor($r('app.color.chip_bg'))
      .justifyContent(FlexAlign.Center)
      Text(title)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .layoutWeight(1)
      Text(this.menuSub(title))
        .fontSize(12)
        .fontColor($r('app.color.text_tertiary'))
      Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
    }
    .width('100%')
    .padding({ left: 14, right: 12, top: 13, bottom: 13 })
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
    .onClick(() => onTap())
  }

  @Builder
  private menuDivider() {
    Divider()
      .color($r('app.color.divider'))
      .margin({ left: 60, right: 12 })
  }
}
