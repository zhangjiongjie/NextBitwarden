import { AppTheme } from '../../app/AppTheme';

class VerificationPreviewItem {
  issuer: string;
  account: string;
  codePreview: string;
  remaining: string;

  constructor(issuer: string, account: string, codePreview: string, remaining: string) {
    this.issuer = issuer;
    this.account = account;
    this.codePreview = codePreview;
    this.remaining = remaining;
  }
}

const VERIFICATION_ITEMS: VerificationPreviewItem[] = [
  new VerificationPreviewItem('GitHub', 'name@example.com', '000 000', '示例'),
  new VerificationPreviewItem('Bitwarden', 'work@example.com', '000 000', '示例'),
  new VerificationPreviewItem('公司 VPN', 'employee', '000 000', '示例')
];

@Component
export struct VerificationCodesScreen {
  onBackToVault?: () => void;

  build() {
    Column({ space: 14 }) {
      Row() {
        Text('两步验证码')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .layoutWeight(1);

        Button('返回')
          .type(ButtonType.Capsule)
          .height(36)
          .fontSize(13)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.emitBackToVault();
          });
      }
      .width('100%');

      Text('这里展示的是 UI 骨架用的占位码。真实 TOTP 必须由 VaultRepository / SDK flow 提供，并遵守锁定状态。')
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');

      ForEach(VERIFICATION_ITEMS, (item: VerificationPreviewItem) => {
        this.buildVerificationItem(item);
      }, (item: VerificationPreviewItem) => item.issuer + item.account);
    }
    .width('100%');
  }

  @Builder
  private buildVerificationItem(item: VerificationPreviewItem): void {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(item.issuer)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor);

        Text(item.account)
          .fontSize(13)
          .fontColor(AppTheme.bodyColor);
      }
      .layoutWeight(1);

      Column({ space: 3 }) {
        Text(item.codePreview)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.primaryColor);

        Text(item.remaining)
          .fontSize(12)
          .fontColor(AppTheme.mutedColor);
      }
      .alignItems(HorizontalAlign.End);
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(18)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  private emitBackToVault(): void {
    if (this.onBackToVault) {
      this.onBackToVault();
    }
  }
}
