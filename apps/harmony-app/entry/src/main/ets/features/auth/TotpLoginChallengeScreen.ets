import { AppTheme } from '../../app/AppTheme';
import {
  AuthFlowStage,
  AuthOperationStatus,
  AuthSessionPreview,
  PreviewAuthRepository
} from './data/AuthRepository';

const AUTH_REPOSITORY: PreviewAuthRepository = new PreviewAuthRepository();

@Component
export struct TotpLoginChallengeScreen {
  onTotpAccepted?: () => void;
  onBackToUnlock?: () => void;

  @State private totpCode: string = '';
  @State private validationMessage: string = '';

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('输入 TOTP 两步验证码')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text('这一步承接主密码后的二步验证边界。当前仍是 preview repository，后续会接入 Bitwarden SDK 的真实登录挑战。')
          .fontSize(14)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(21)
          .width('100%');
      }
      .width('100%');

      Column({ space: 12 }) {
        Text('验证码')
          .fontSize(13)
          .fontColor(AppTheme.mutedColor)
          .width('100%');

        TextInput({
          placeholder: '输入 6 位验证码',
          text: this.totpCode
        })
          .height(52)
          .fontSize(18)
          .fontColor(AppTheme.titleColor)
          .placeholderColor(AppTheme.mutedColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.totpCode = value;
            this.validationMessage = '';
          });

        if (this.validationMessage.length > 0) {
          Text(this.validationMessage)
            .fontSize(12)
            .fontColor(AppTheme.dangerColor)
            .width('100%');
        }

        Button('验证并进入保险库')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.submitTotp();
          });

        Button('返回主密码')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontColor(AppTheme.bodyColor)
          .backgroundColor(AppTheme.surfaceColor)
          .onClick(() => {
            this.emitBackToUnlock();
          });
      }
      .width('100%')
      .padding(18)
      .backgroundColor(AppTheme.surfaceColor)
      .borderRadius(22)
      .border({ width: 1, color: AppTheme.borderColor });
    }
    .width('100%');
  }

  private submitTotp(): void {
    let session: AuthSessionPreview = AUTH_REPOSITORY.submitTotpSecondFactor('preview@example.com', this.totpCode);
    this.validationMessage = session.status === AuthOperationStatus.ValidationError ? session.validationMessage : '';
    if (session.stage === AuthFlowStage.VaultUnlocked) {
      this.emitTotpAccepted();
    }
  }

  private emitTotpAccepted(): void {
    if (this.onTotpAccepted) {
      this.onTotpAccepted();
    }
  }

  private emitBackToUnlock(): void {
    if (this.onBackToUnlock) {
      this.onBackToUnlock();
    }
  }
}
