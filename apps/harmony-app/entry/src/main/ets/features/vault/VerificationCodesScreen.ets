import { AppTheme } from '../../app/AppTheme';
import { PreviewVaultRepository, VerificationCodeItem } from './data/VaultRepository';

const VAULT_REPOSITORY: PreviewVaultRepository = new PreviewVaultRepository();

@Component
export struct VerificationCodesScreen {
  onBackToVault?: () => void;
  private verificationItems: VerificationCodeItem[] = VAULT_REPOSITORY.getVerificationCodes();

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

      ForEach(this.verificationItems, (item: VerificationCodeItem) => {
        this.buildVerificationItem(item);
      }, (item: VerificationCodeItem) => item.itemId);
    }
    .width('100%');
  }

  @Builder
  private buildVerificationItem(item: VerificationCodeItem): void {
    Row({ space: 12 }) {
      Column({ space: 4 }) {
        Text(item.issuer)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor);

        Text(item.accountName)
          .fontSize(13)
          .fontColor(AppTheme.bodyColor);
      }
      .layoutWeight(1);

      Column({ space: 3 }) {
        Text(item.codePreview)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.primaryColor);

        Text(item.remainingLabel)
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
