import { AppTheme } from '../../app/AppTheme';

class IntegrationItem {
  title: string;
  status: string;
  body: string;
  warning: boolean;

  constructor(title: string, status: string, body: string, warning: boolean) {
    this.title = title;
    this.status = status;
    this.body = body;
    this.warning = warning;
  }
}

const INTEGRATIONS: IntegrationItem[] = [
  new IntegrationItem('自动填充 Provider', '首发必做', '优先验证 AutoFillExtensionAbility / autoFill/password，hmbitwarden 是正向市场证据。', true),
  new IntegrationItem('凭据获取 / Passkey Provider', '分开验证', '不能假设普通自动填充覆盖 Passkey，需要独立 Capability。', true),
  new IntegrationItem('设备 Passkey 登录', '首发必做', '先支持 platform authenticator，不做 NFC、YubiKey、漫游认证器。', false),
  new IntegrationItem('生物识别 + HUKS', '首发必做', 'userAuth 只做认证，密钥保护独立落到 HUKS。', false),
  new IntegrationItem('推送 / 实时同步 / 登录审批', '双模式', 'Push Kit 可行则接入，否则前台同步、手动刷新和关键路径刷新必须可用。', false)
];

@Component
export struct SystemIntegrationScreen {
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

      ForEach(INTEGRATIONS, (item: IntegrationItem) => {
        this.buildIntegrationItem(item);
      }, (item: IntegrationItem) => item.title);
    }
    .width('100%');
  }

  @Builder
  private buildIntegrationItem(item: IntegrationItem): void {
    Column({ space: 7 }) {
      Row() {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor)
          .layoutWeight(1);

        Text(item.status)
          .fontSize(12)
          .fontColor(item.warning ? AppTheme.warningColor : AppTheme.successColor)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .backgroundColor(item.warning ? AppTheme.warningSoftColor : AppTheme.primarySoftColor)
          .borderRadius(10);
      }
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
