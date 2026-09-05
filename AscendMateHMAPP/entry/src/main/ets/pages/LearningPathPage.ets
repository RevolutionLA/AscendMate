import { ContentService } from '../service/ContentService';
import { DataService } from '../service/DataService';
import { Icon, IconName } from '../common/Icon';
import { Nav } from '../common/Nav';
import { Theme } from '../common/Theme';
import { Safe } from '../common/Safe';
import { LearningStage } from '../model/Models';
import { PageBar } from '../components/Common';

@Component
export struct LearningPathPage {
  @StorageLink('learnRev') @Watch('onLearnRev') learnRev: number = 0;
  @State doneStages: string[] = [];
  private stages: LearningStage[] = ContentService.learningStages();

  aboutToAppear(): void {
    this.reload();
  }

  private onLearnRev(): void {
    this.reload();
  }

  private reload(): void {
    const ds = DataService.getInstance();
    this.doneStages = this.stages
      .filter((s: LearningStage): boolean => ds.isStageDone(s.docId))
      .map((s: LearningStage): string => s.docId);
  }

  private isDone(docId: string): boolean {
    return this.doneStages.indexOf(docId) >= 0;
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.TopStart }) {
        Scroll() {
          Column() {
            Row({ space: 16 }) {
              Stack({ alignContent: Alignment.Center }) {
                Progress({ value: this.doneStages.length, total: 6, type: ProgressType.Ring })
                  .width(64)
                  .height(64)
                  .color($r('app.color.accent'))
                  .style({ strokeWidth: 6 })
                Text(`${Math.round(this.doneStages.length / 6 * 100)}%`)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.accent'))
              }
              .width(64)
              .height(64)
              Column({ space: 4 }) {
                Text('从零到昇腾 AI 工程师')
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                Text('六个阶段，每篇读完自动提示标记完成')
                  .fontSize(12)
                  .fontColor($r('app.color.text_secondary'))
                Text(`已完成 ${this.doneStages.length}/6 阶段`)
                  .fontSize(12)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.accent'))
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)
            }
            .width('100%')
            .padding(18)
            .backgroundColor($r('app.color.card_bg'))
            .border({ width: 1, color: $r('app.color.divider') })
            .borderRadius(Theme.radiusLg)
            .margin({ top: 16 })

            if (this.doneStages.length === 6) {
              Row({ space: 10 }) {
                Icon({ name: IconName.Sparkle, iconSize: 18, color: $r('app.color.accent') })
                Text('恭喜完成全部学习路径，正式入门昇腾生态！')
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('app.color.accent'))
              }
              .width('100%')
              .padding(14)
              .backgroundColor($r('app.color.callout_tip_bg'))
              .borderRadius(Theme.radiusMd)
              .margin({ top: 12 })
            }

            Column({ space: 10 }) {
              ForEach(this.stages, (stage: LearningStage) => {
                Row({ space: 12 }) {
                  Column() {
                    if (this.isDone(stage.docId)) {
                      Icon({ name: IconName.Check, iconSize: 18, color: Color.White })
                    } else {
                      Text(`${stage.stage}`)
                        .fontSize(16)
                        .fontWeight(FontWeight.Bold)
                        .fontColor(Color.White)
                    }
                  }
                  .width(40)
                  .height(40)
                  .borderRadius(20)
                  .backgroundColor(this.isDone(stage.docId) ? $r('app.color.accent') :
                  Theme.stageColors[stage.stage - 1])
                  .justifyContent(FlexAlign.Center)
                  Column({ space: 3 }) {
                    Text(stage.title)
                      .fontSize(15)
                      .fontWeight(FontWeight.Bold)
                      .fontColor($r('app.color.text_primary'))
                    Text(stage.subtitle)
                      .fontSize(12)
                      .fontColor($r('app.color.text_tertiary'))
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  Text(this.isDone(stage.docId) ? '已完成' : '去学习')
                    .fontSize(11)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.isDone(stage.docId) ? $r('app.color.accent') : $r('app.color.brand'))
                  Icon({ name: IconName.ChevronRight, iconSize: 16, color: $r('app.color.text_tertiary') })
                }
                .width('100%')
                .padding(14)
                .backgroundColor($r('app.color.card_bg'))
                .borderRadius(Theme.radiusLg)
                              .clickEffect({ level: ClickEffectLevel.LIGHT, scale: 0.97 })
.onClick(() => Nav.pushDoc(stage.docId))
              }, (stage: LearningStage) => `${stage.stage}-${this.isDone(stage.docId)}`)
            }
            .width('100%')
            .margin({ top: 14, bottom: 24 })
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 66 + Safe.top(), bottom: 24 + Safe.bottom() })
        }
        .width('100%')
        .height('100%')
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
        .align(Alignment.TopStart)

        PageBar({ title: '学习路径' })
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
