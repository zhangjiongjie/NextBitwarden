import { AppTheme } from '../../app/AppTheme';
import {
  AuthFlowStage,
  AuthOperationStatus,
  AuthSessionPreview,
  PreviewAuthRepository
} from './data/AuthRepository';

const AUTH_REPOSITORY: PreviewAuthRepository = new PreviewAuthRepository();

@Component
export struct VaultUnlockScreen {
  onUnlocked?: () => void;
  onUseBiometric?: () => void;
  onBackToLogin?: () => void;

  @State private masterPassword: string = '';
  @State private validationMessage: string = '';
  @State private nextStepMessage: string = '解锁后将进入 TOTP 二步验证码校验边界。';

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('保险库已锁定')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text('这里先承载解锁状态流。真实解密必须由 Bitwarden SDK bridge、userAuth 和 HUKS 组合完成。')
          .fontSize(14)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(21)
          .width('100%');
      }
      .width('100%');

      Column({ space: 12 }) {
        Text('主密码')
          .fontSize(13)
          .fontColor(AppTheme.mutedColor)
          .width('100%');

        TextInput({
          placeholder: '输入主密码',
          text: this.masterPassword
        })
          .type(InputType.Password)
          .height(52)
          .fontSize(16)
          .fontColor(AppTheme.titleColor)
          .placeholderColor(AppTheme.mutedColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.masterPassword = value;
            this.validationMessage = '';
          });

        if (this.validationMessage.length > 0) {
          Text(this.validationMessage)
            .fontSize(12)
            .fontColor(AppTheme.dangerColor)
            .width('100%');
        }

        Text(this.nextStepMessage)
          .fontSize(12)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(18)
          .width('100%');

        Button('解锁')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.handleUnlock();
          });

        Button('面容 / 指纹解锁')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.emitUseBiometric();
          });
      }
      .width('100%')
      .padding(18)
      .backgroundColor(AppTheme.surfaceColor)
      .borderRadius(22)
      .border({ width: 1, color: AppTheme.borderColor });

      Button('返回登录')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(AppTheme.bodyColor)
        .backgroundColor(AppTheme.surfaceColor)
        .onClick(() => {
          this.emitBackToLogin();
        });
    }
    .width('100%');
  }

  private handleUnlock(): void {
    let session: AuthSessionPreview = AUTH_REPOSITORY.unlockWithMasterPassword('preview@example.com', this.masterPassword);
    this.validationMessage = session.status === AuthOperationStatus.ValidationError ? session.validationMessage : '';
    if (session.stage === AuthFlowStage.WaitingForTotp) {
      this.nextStepMessage = session.validationMessage;
    } else if (session.stage === AuthFlowStage.VaultUnlocked) {
      this.emitUnlocked();
    }
  }

  private emitUnlocked(): void {
    if (this.onUnlocked) {
      this.onUnlocked();
    }
  }

  private emitUseBiometric(): void {
    if (this.onUseBiometric) {
      this.onUseBiometric();
    }
  }

  private emitBackToLogin(): void {
    if (this.onBackToLogin) {
      this.onBackToLogin();
    }
  }
}
