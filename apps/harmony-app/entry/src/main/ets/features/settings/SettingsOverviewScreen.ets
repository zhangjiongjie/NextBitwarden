import { AppTheme } from '../../app/AppTheme';
import { PreviewSettingsRepository, SettingsPolicyItem } from './data/SettingsRepository';

const SETTINGS_REPOSITORY: PreviewSettingsRepository = new PreviewSettingsRepository();

@Component
export struct SettingsOverviewScreen {
  private settingsItems: SettingsPolicyItem[] = SETTINGS_REPOSITORY.getPolicyItems();

  build() {
    Column({ space: 14 }) {
      Text('设置')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Text('设置页只展示已确认产品策略和后续扩展边界，真实偏好、订阅状态和企业配置后续通过 repository bridge 接入。')
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');

      ForEach(this.settingsItems, (item: SettingsPolicyItem) => {
        this.buildSettingItem(item);
      }, (item: SettingsPolicyItem) => item.area);
    }
    .width('100%');
  }

  @Builder
  private buildSettingItem(item: SettingsPolicyItem): void {
    Column({ space: 7 }) {
      Row() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor)
          .layoutWeight(1);

        Text(item.statusLabel)
          .fontSize(12)
          .fontColor(this.policyLabelColor(item))
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(this.policyLabelBackground(item))
          .borderRadius(10);
      }
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

  private policyLabelColor(item: SettingsPolicyItem): ResourceColor {
    if (item.reservedForFuture) {
      return AppTheme.bodyColor;
    }
    if (item.highRisk) {
      return AppTheme.warningColor;
    }
    return AppTheme.successColor;
  }

  private policyLabelBackground(item: SettingsPolicyItem): ResourceColor {
    if (item.reservedForFuture) {
      return AppTheme.dividerColor;
    }
    if (item.highRisk) {
      return AppTheme.warningSoftColor;
    }
    return AppTheme.primarySoftColor;
  }
}
