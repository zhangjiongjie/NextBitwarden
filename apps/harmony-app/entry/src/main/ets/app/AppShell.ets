import { RootState, rootStateDescription, rootStateTitle } from '../core/navigation/RootState';
import { InitialMilestones } from '../features/platform/InitialMilestones';
import { AppTheme } from './AppTheme';

@Component
export struct AppShell {
  @State private rootState: RootState = RootState.SignedOut;

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('NextBitwarden')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor);

        Text('HarmonyOS NEXT Password Manager')
          .fontSize(15)
          .fontColor(AppTheme.bodyColor);
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%');

      Column({ space: 10 }) {
        Text(rootStateTitle(this.rootState))
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor);

        Text(rootStateDescription(this.rootState))
          .fontSize(14)
          .fontColor(AppTheme.bodyColor);

        Button('进入保险库框架')
          .fontSize(15)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.rootState = RootState.Unlocked;
          });
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding(18)
      .backgroundColor(AppTheme.surfaceColor)
      .borderRadius(22)
      .border({
        width: 1,
        color: AppTheme.borderColor
      });

      InitialMilestones();
    }
    .width('100%')
    .height('100%')
    .padding({
      left: 20,
      right: 20,
      top: 56,
      bottom: 24
    })
    .backgroundColor(AppTheme.backgroundColor);
  }
}
