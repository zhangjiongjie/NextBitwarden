import { AppTheme } from '../../app/AppTheme';

class SettingPreviewItem {
  title: string;
  body: string;

  constructor(title: string, body: string) {
    this.title = title;
    this.body = body;
  }
}

const SETTINGS: SettingPreviewItem[] = [
  new SettingPreviewItem('Premium / 订阅', '一期完全开放，不在应用端购买，也不在应用端限制相关功能。'),
  new SettingPreviewItem('自托管服务器', '保留 baseUrl、identityUrl、apiUrl、iconsUrl 的 ServerConfigBridge。'),
  new SettingPreviewItem('安全策略', '剪贴板清理、自动锁定、解锁方式和本地密钥保护需要独立设置。'),
  new SettingPreviewItem('企业能力', 'trusted device、组织加密初始化和 key connector 纳入一期；mTLS 不纳入一期。')
];

@Component
export struct SettingsOverviewScreen {
  build() {
    Column({ space: 14 }) {
      Text('设置')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      ForEach(SETTINGS, (item: SettingPreviewItem) => {
        this.buildSettingItem(item);
      }, (item: SettingPreviewItem) => item.title);
    }
    .width('100%');
  }

  @Builder
  private buildSettingItem(item: SettingPreviewItem): void {
    Column({ space: 6 }) {
      Text(item.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Text(item.body)
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
