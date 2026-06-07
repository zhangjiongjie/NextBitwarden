import { AppTheme } from '../../app/AppTheme';

class MilestoneItem {
  title: string;
  body: string;

  constructor(title: string, body: string) {
    this.title = title;
    this.body = body;
  }
}

const MILESTONES: MilestoneItem[] = [
  new MilestoneItem('一期范围', '只做 Password Manager 主应用，首发对齐 Android 的登录、Vault、TOTP、自动填充、Passkey 和凭据获取。'),
  new MilestoneItem('Bitwarden SDK', '优先接入官方 internal SDK，应用层只通过 SdkClientManager 和 SdkRepositoryBridge 访问。'),
  new MilestoneItem('自动填充', '优先验证 AutoFillExtensionAbility / autoFill/password，hmbitwarden 是重要市场侧正向证据。'),
  new MilestoneItem('Passkey', '设备内置 Passkey 登录必须首发；第三方 Passkey provider 与普通自动填充分开验证。'),
  new MilestoneItem('安全能力', '生物识别、HUKS、剪贴板清理和自动锁定都必须在 Capability 层隔离。')
];

@Component
export struct InitialMilestones {
  build() {
    Column({ space: 12 }) {
      Text('首批开发里程碑')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      ForEach(MILESTONES, (item: MilestoneItem) => {
        Column({ space: 4 }) {
          Text(item.title)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor(AppTheme.titleColor);

          Text(item.body)
            .fontSize(13)
            .fontColor(AppTheme.bodyColor)
            .lineHeight(20);
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .padding(14)
        .backgroundColor(AppTheme.surfaceColor)
        .borderRadius(18)
        .border({
          width: 1,
          color: AppTheme.borderColor
        });
      }, (item: MilestoneItem) => item.title);
    }
    .width('100%');
  }
}
