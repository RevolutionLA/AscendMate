import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ContentService } from '../service/ContentService';
import { DataService } from '../service/DataService';
import { Nav } from '../common/Nav';
import { Icon, IconName } from '../common/Icon';
import { BrandLogo } from '../common/BrandLogo';
import { Safe } from '../common/Safe';
import { HomeTab } from '../tabs/HomeTab';
import { KnowledgeTab } from '../tabs/KnowledgeTab';
import { TechNavTab } from '../tabs/TechNavTab';
import { MineTab } from '../tabs/MineTab';
import { GuideView } from './GuideView';
import { SearchPage } from './SearchPage';
import { DocDetailPage } from './DocDetailPage';
import { DocListPage } from './DocListPage';
import { LearningPathPage } from './LearningPathPage';
import { FavoritesPage } from './FavoritesPage';
import { HistoryPage } from './HistoryPage';
import { SettingsPage } from './SettingsPage';
import { AboutPage } from './AboutPage';

@Entry
@Component
struct Index {
  @State ready: boolean = false;
  @StorageLink('tabIndex') currentTabIdx: number = 0;
  @StorageLink('guideDone') guideDone: boolean = false;

  aboutToAppear(): void {
    const ctx = getContext(this) as common.UIAbilityContext;
    DataService.getInstance().init(ctx)
      .then((): Promise<void> => ContentService.getInstance().init(ctx))
      .then((): void => {
        this.ready = true;
      })
      .catch((err: BusinessError): void => {
        console.error(`init failed: ${err.code}`);
        this.ready = true;
      });
  }

  onBackPress(): boolean {
    if (this.ready && !this.guideDone) {
      const ctx = getContext(this) as common.UIAbilityContext;
      DataService.getInstance().init(ctx).then((): void => {
        DataService.getInstance().setGuideDone(true);
      });
      return true;
    }
    return false;
  }

  @Builder
  private tabItem(icon: IconName, label: string, idx: number) {
    Column({ space: 3 }) {
      Icon({
        name: icon,
        iconSize: 22,
        color: this.currentTabIdx === idx ? $r('app.color.brand') : $r('app.color.text_tertiary')
      })
      Text(label)
        .fontSize(10)
        .fontWeight(this.currentTabIdx === idx ? FontWeight.Bold : FontWeight.Normal)
        .fontColor(this.currentTabIdx === idx ? $r('app.color.brand') : $r('app.color.text_tertiary'))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  private glassTabBar() {
    Row({ space: 0 }) {
      Column() {
        this.tabItem(IconName.Home, '首页', 0)
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentTabIdx = 0;
      })
      Column() {
        this.tabItem(IconName.Book, '知识库', 1)
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentTabIdx = 1;
      })
      Column() {
        this.tabItem(IconName.Toc, '技术导航', 2)
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentTabIdx = 2;
      })
      Column() {
        this.tabItem(IconName.User, '我的', 3)
      }
      .layoutWeight(1)
      .onClick(() => {
        this.currentTabIdx = 3;
      })
    }
    .width('100%')
    .height(58 + Safe.bottom())
    .padding({ bottom: Safe.bottom() })
    .backgroundColor($r('app.color.bar_bg'))
    .backgroundBlurStyle(BlurStyle.Regular)
    .border({ width: { top: 0.5 }, color: $r('app.color.divider') })
  }

  @Builder
  private pagesMap(name: string) {
    if (name === 'docDetail') {
      DocDetailPage()
    } else if (name === 'docList') {
      DocListPage()
    } else if (name === 'search') {
      SearchPage()
    } else if (name === 'learning') {
      LearningPathPage()
    } else if (name === 'favorites') {
      FavoritesPage()
    } else if (name === 'history') {
      HistoryPage()
    } else if (name === 'settings') {
      SettingsPage()
    } else if (name === 'about') {
      AboutPage()
    }
  }

  @Builder
  private splashView() {
    Column({ space: 16 }) {
      BrandLogo({ logoWidth: 200 })
      Text('昇腾之家')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
      Text('昇腾智算一站式知识库')
        .fontSize(12)
        .fontColor($r('app.color.text_tertiary'))
        .letterSpacing(2)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .linearGradient({
      angle: 180,
      colors: [[$r('app.color.guide_bg_top'), 0], [$r('app.color.guide_bg_bottom'), 1]]
    })
  }

  build() {
    Stack() {
      if (!this.ready) {
        this.splashView()
      } else {
        Navigation(Nav.stack) {
          Stack({ alignContent: Alignment.TopStart }) {
            Tabs({ barPosition: BarPosition.End, index: this.currentTabIdx }) {
              TabContent() {
                HomeTab()
              }
              TabContent() {
                KnowledgeTab()
              }
              TabContent() {
                TechNavTab()
              }
              TabContent() {
                MineTab()
              }
            }
            .barHeight(0)
            .scrollable(false)
            .animationDuration(240)
            .onChange((idx: number) => {
              this.currentTabIdx = idx;
            })
            .width('100%')
            .height('100%')

            Column()
              .width('100%')
              .height(Safe.top())
              .backgroundColor($r('app.color.bar_bg'))
              .backgroundBlurStyle(BlurStyle.Regular)
              .hitTestBehavior(HitTestMode.None)

            Column() {
              Blank()
                .hitTestBehavior(HitTestMode.None)
              this.glassTabBar()
            }
            .width('100%')
            .height('100%')
            .hitTestBehavior(HitTestMode.None)
          }
          .width('100%')
          .height('100%')
        }
        .navDestination(this.pagesMap)
        .mode(NavigationMode.Stack)
        .hideTitleBar(true)
        .hideToolBar(true)
        .width('100%')
        .height('100%')
        .transition(TransitionEffect.OPACITY.animation({ duration: 350, curve: Curve.EaseOut }).combine(
          TransitionEffect.translate({ y: 16 }).animation({ duration: 350, curve: Curve.EaseOut })))

        if (!this.guideDone) {
          GuideView()
            .transition(TransitionEffect.asymmetric(
              TransitionEffect.OPACITY.animation({ duration: 300 }),
              TransitionEffect.OPACITY.animation({ duration: 450, curve: Curve.EaseInOut }).combine(
                TransitionEffect.scale({ x: 1.04, y: 1.04 }).animation({ duration: 450, curve: Curve.EaseInOut }))))
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_bg'))
  }
}
