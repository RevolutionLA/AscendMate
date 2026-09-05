import { ContentService } from '../service/ContentService';
import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Safe } from '../common/Safe';
import { Theme } from '../common/Theme';
import { CategoryData, DocSummary, EcoItem, LearningStage } from '../model/Models';
import { DocRow } from '../components/Common';

@Component
export struct KnowledgeTab {
  @StorageLink('histRev') @Watch('onRev') histRev: number = 0;
  @StorageLink('learnRev') @Watch('onRev') learnRev: number = 0;
  @State segIdx: number = 0;
  @State doneStages: string[] = [];
  private stages: LearningStage[] = ContentService.learningStages();

  aboutToAppear(): void {
    this.reloadDone();
  }

  private onRev(): void {
    this.reloadDone();
  }

  private reloadDone(): void {
    const ds = DataService.getInstance();
    this.doneStages = this.stages
      .filter((s: LearningStage): boolean => ds.isStageDone(s.docId))
      .map((s: LearningStage): string => s.docId);
  }

  build() {
    Scroll() {
      Column() {
        Text('知识库')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .width('100%')
          .margin({ bottom: 14 })

        Row() {
          ForEach(['学习路径', '价值场景', '资源导航', '生态组件'], (label: string, idx: number) => {
            Text(label)
              .fontSize(14)
              .fontWeight(this.segIdx === idx ? FontWeight.Bold : FontWeight.Normal)
              .fontColor(this.segIdx === idx ? $r('app.color.brand') : $r('app.color.text_secondary'))
              .textAlign(TextAlign.Center)
              .layoutWeight(1)
              .padding({ top: 8, bottom: 8 })
              .backgroundColor(this.segIdx === idx ? $r('app.color.brand_soft') : Color.Transparent)
              .borderRadius(18)
              .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.95 })
              .onClick(() => {
                this.segIdx = idx;
              })
          }, (label: string, idx: number) => label)
        }
        .width('100%')
        .backgroundColor($r('app.color.chip_bg'))
        .borderRadius(22)
        .padding(4)
        .margin({ bottom: 14 })

        if (this.segIdx === 0) {
          this.learningSection()
        } else if (this.segIdx === 1) {
          this.categoryRows('scenes')
        } else if (this.segIdx === 2) {
          this.categoryRows('resources')
        } else {
          this.ecoSection()
        }

        Column()
          .height(24 + Safe.bottom() + 66)
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
  private ecoSection() {
    Column({ space: 12 }) {
      Column() {
        ForEach(ContentService.ecoItems(), (item: EcoItem, idx: number) => {
          Column() {
            Row({ space: 12 }) {
              Stack({ alignContent: Alignment.Center }) {
                Column()
                  .width(36)
                  .height(36)
                  .borderRadius(11)
                  .backgroundColor($r('app.color.chip_bg'))
                Text(item.name.substring(0, 1))
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_secondary'))
                  .fontFamily('monospace')
              }
              .width(36)
              .height(36)
              Column({ space: 3 }) {
                Text(item.name)
                  .fontSize(15)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.text_primary'))
                Text('部署实战指南')
                  .fontSize(11)
                  .fontColor($r('app.color.text_tertiary'))
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
              Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
            }
            .width('100%')
            .padding({ top: 11, bottom: 11, left: 14, right: 12 })
            .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
            .onClick(() => Nav.pushDoc(item.docId))
            if (idx < ContentService.ecoItems().length - 1) {
              Divider()
                .color($r('app.color.divider'))
                .margin({ left: 62, right: 12 })
            }
          }
        }, (item: EcoItem) => item.name)
      }
      .width('100%')
      .backgroundColor($r('app.color.card_bg'))
      .borderRadius(Theme.radiusLg)
      .border({ width: 1, color: $r('app.color.divider') })
      .clip(true)
    }
    .width('100%')
  }

  @Builder
  private learningSection() {
    Column() {
      ForEach(this.stages, (stage: LearningStage, idx: number) => {
        Column() {
          Row({ space: 12 }) {
            Stack({ alignContent: Alignment.Center }) {
              Column()
                .width(36)
                .height(36)
                .borderRadius(18)
                .backgroundColor(this.doneStages.indexOf(stage.docId) >= 0 ?
                $r('app.color.accent') : Theme.stageColors[stage.stage - 1])
              if (this.doneStages.indexOf(stage.docId) >= 0) {
                Icon({ name: IconName.Check, iconSize: 16, color: Color.White })
              } else {
                Text(`${stage.stage}`)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(Color.White)
              }
            }
            .width(36)
            .height(36)
            Column({ space: 3 }) {
              Text(stage.title)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.text_primary'))
              Text(stage.subtitle)
                .fontSize(11)
                .fontColor($r('app.color.text_tertiary'))
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
          }
          .width('100%')
          .padding({ top: 11, bottom: 11, left: 14, right: 12 })
          .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
          .onClick(() => Nav.pushDoc(stage.docId))
          if (idx < this.stages.length - 1) {
            Divider()
              .color($r('app.color.divider'))
              .margin({ left: 62, right: 12 })
          }
        }
      }, (stage: LearningStage) => `${stage.stage}-${this.doneStages.indexOf(stage.docId) >= 0}`)
    }
    .width('100%')
    .backgroundColor($r('app.color.card_bg'))
    .borderRadius(Theme.radiusLg)
    .border({ width: 1, color: $r('app.color.divider') })
    .clip(true)
  }

  @Builder
  private categoryRows(catId: string) {
    Column() {
      if (ContentService.getInstance().getCategory(catId) !== undefined) {
        ForEach((ContentService.getInstance().getCategory(catId) as CategoryData).docs,
          (doc: DocSummary, idx: number) => {
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
    }
    .width('100%')
    .backgroundColor($r('app.color.card_bg'))
    .borderRadius(Theme.radiusLg)
    .clip(true)
  }
}
