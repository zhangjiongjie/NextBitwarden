import { AppTheme } from '../../app/AppTheme';
import {
  PreviewSystemIntegrationRepository,
  SystemIntegrationReadiness
} from './data/SystemIntegrationRepository';

const SYSTEM_INTEGRATION_REPOSITORY: PreviewSystemIntegrationRepository = new PreviewSystemIntegrationRepository();

@Component
export struct SystemIntegrationScreen {
  private readinessItems: SystemIntegrationReadiness[] = SYSTEM_INTEGRATION_REPOSITORY.getReadinessItems();

  build() {
    Column({ space: 14 }) {
      Text('系统集成首发清单')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Text('这些能力不会散落在页面中，统一通过 Capability 层接入。')
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');

      ForEach(this.readinessItems, (item: SystemIntegrationReadiness) => {
        this.buildIntegrationItem(item);
      }, (item: SystemIntegrationReadiness) => item.area);
    }
    .width('100%');
  }

  @Builder
  private buildIntegrationItem(item: SystemIntegrationReadiness): void {
    Column({ space: 7 }) {
      Row() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor)
          .layoutWeight(1);

        Text(item.statusLabel)
          .fontSize(12)
          .fontColor(item.requiresPrivilegedAccess ? AppTheme.warningColor : AppTheme.successColor)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(item.requiresPrivilegedAccess ? AppTheme.warningSoftColor : AppTheme.primarySoftColor)
          .borderRadius(10);
      }
      .width('100%');

      Text(item.routeLabel)
        .fontSize(12)
        .fontColor(AppTheme.primaryColor)
        .width('100%');

      Text(item.message)
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(18)
    .border({ width: 1, color: AppTheme.borderColor });
  }
}
