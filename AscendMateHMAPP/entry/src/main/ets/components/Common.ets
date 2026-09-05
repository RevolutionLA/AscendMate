import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Safe } from '../common/Safe';
import { DocSummary, HighlightSegment } from '../model/Models';

@Component
export struct PageBar {
  title: string = '';
  actionLabel: string = '';
  onAction: () => void = () => {
  };

  build() {
    Row({ space: 4 }) {
      Row() {
        Icon({ name: IconName.Back, iconSize: 20, color: $r('app.color.text_primary') })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => Nav.pop())
      Text(this.title)
        .fontSize(17)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .margin({ left: 4 })
      if (this.actionLabel !== '') {
        Text(this.actionLabel)
          .fontSize(13)
          .fontColor($r('app.color.brand'))
          .padding({ left: 12, right: 8, top: 10, bottom: 10 })
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .height(52 + Safe.top())
    .padding({ left: 6, right: 6, top: Safe.top() })
    .backgroundColor($r('app.color.bar_bg'))
    .backgroundBlurStyle(BlurStyle.Regular)
    .border({ width: { bottom: 0.5 }, color: $r('app.color.divider') })
  }
}

@Component
export struct SectionHeader {
  title: string = '';
  actionLabel: string = '';
  onAction: () => void = () => {
  };

  build() {
    Row() {
      Column()
        .width(3)
        .height(14)
        .borderRadius(1.5)
        .backgroundColor($r('app.color.brand'))
        .margin({ right: 8 })
      Text(this.title)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Blank()
      if (this.actionLabel !== '') {
        Text(this.actionLabel)
          .fontSize(13)
          .fontColor($r('app.color.text_tertiary'))
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .padding({ left: 4, right: 4, top: 8, bottom: 10 })
  }
}

@Component
export struct EmptyState {
  iconName: IconName = IconName.Search;
  iconColor: ResourceColor = $r('app.color.text_tertiary');
  title: string = '暂无内容';
  desc: string = '';
  actionLabel: string = '';
  onAction: () => void = () => {
  };

  build() {
    Column({ space: 12 }) {
      Icon({ name: this.iconName, iconSize: 56, color: this.iconColor })
      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_secondary'))
      if (this.desc !== '') {
        Text(this.desc)
          .fontSize(13)
          .fontColor($r('app.color.text_tertiary'))
          .textAlign(TextAlign.Center)
      }
      if (this.actionLabel !== '') {
        Button(this.actionLabel)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor($r('app.color.brand'))
          .borderRadius(20)
          .height(38)
          .padding({ left: 24, right: 24 })
          .margin({ top: 4 })
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .padding({ top: 72, bottom: 72 })
    .justifyContent(FlexAlign.Center)
  }
}

export function iconForCategory(catId: string): IconName {
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
  if (catId === 'faq') {
    return IconName.Question;
  }
  if (catId === 'learning') {
    return IconName.Graduation;
  }
  if (catId === 'scenes') {
    return IconName.Blocks;
  }
  return IconName.LinkBox;
}

@Component
export struct DocRow {
  @Prop doc: DocSummary = new DocSummary();
  @Prop read: boolean = false;
  onOpen: (docId: string) => void = (docId: string) => {
  };

  build() {
    Row({ space: 12 }) {
      Column() {
        Icon({ name: iconForCategory(this.doc.category), iconSize: 18, color: $r('app.color.text_secondary') })
      }
      .width(36)
      .height(36)
      .borderRadius(11)
      .backgroundColor($r('app.color.chip_bg'))
      .justifyContent(FlexAlign.Center)
      Column({ space: 3 }) {
        Text(this.doc.title)
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.read ? $r('app.color.text_secondary') : $r('app.color.text_primary'))
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Row({ space: 8 }) {
          Text(`${this.doc.readTime} 分钟`)
            .fontSize(10)
            .fontColor($r('app.color.text_tertiary'))
          if (this.read) {
            Text('已读')
              .fontSize(10)
              .fontColor($r('app.color.accent'))
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ top: 11, bottom: 11, left: 14, right: 12 })
    .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
    .onClick(() => this.onOpen(this.doc.id))
  }
}

@Component
export struct HighlightText {
  segments: HighlightSegment[] = [];
  fontSize: number = 15;
  color: ResourceColor = $r('app.color.text_primary');
  hitColor: ResourceColor = $r('app.color.brand');
  fontWeightVal: number = 400;
  maxLinesVal: number = 100;

  build() {
    Text() {
      ForEach(this.segments, (seg: HighlightSegment, idx: number) => {
        Span(seg.text)
          .fontSize(this.fontSize)
          .fontColor(seg.hit ? this.hitColor : this.color)
          .fontWeight(seg.hit ? FontWeight.Bold : this.fontWeightVal)
      }, (seg: HighlightSegment, idx: number) => `${idx}-${seg.hit}`)
    }
    .fontSize(this.fontSize)
    .maxLines(this.maxLinesVal)
    .textOverflow({ overflow: TextOverflow.Ellipsis })
  }
}
