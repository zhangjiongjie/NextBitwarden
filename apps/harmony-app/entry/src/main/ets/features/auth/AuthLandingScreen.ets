import { AppTheme } from '../../app/AppTheme';

@Component
export struct AuthLandingScreen {
  onPasswordSignIn?: () => void;
  onDevicePasskey?: () => void;
  onSsoSignIn?: () => void;
  onSelfHostedConfig?: () => void;

  @State private email: string = '';

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('登录到 Bitwarden')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text('首发目标包含账号密码、TOTP 二步验证码、设备 Passkey、SSO、自托管和 trusted device。')
          .fontSize(14)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(21)
          .width('100%');
      }
      .width('100%');

      Column({ space: 12 }) {
        Text('电子邮箱')
          .fontSize(13)
          .fontColor(AppTheme.mutedColor)
          .width('100%');

        TextInput({
          placeholder: 'name@example.com',
          text: this.email
        })
          .height(52)
          .fontSize(16)
          .fontColor(AppTheme.titleColor)
          .placeholderColor(AppTheme.mutedColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.email = value;
          });

        Button('继续使用主密码')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.emitPasswordSignIn();
          });

        Button('使用设备 Passkey 登录')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.emitDevicePasskey();
          });
      }
      .width('100%')
      .padding(18)
      .backgroundColor(AppTheme.surfaceColor)
      .borderRadius(22)
      .border({ width: 1, color: AppTheme.borderColor });

      Row({ space: 12 }) {
        Button('企业 SSO')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor(AppTheme.titleColor)
          .backgroundColor(AppTheme.surfaceColor)
          .onClick(() => {
            this.emitSsoSignIn();
          });

        Button('自托管')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor(AppTheme.titleColor)
          .backgroundColor(AppTheme.surfaceColor)
          .onClick(() => {
            this.emitSelfHostedConfig();
          });
      }
      .width('100%');
    }
    .width('100%');
  }

  private emitPasswordSignIn(): void {
    if (this.onPasswordSignIn) {
      this.onPasswordSignIn();
    }
  }

  private emitDevicePasskey(): void {
    if (this.onDevicePasskey) {
      this.onDevicePasskey();
    }
  }

  private emitSsoSignIn(): void {
    if (this.onSsoSignIn) {
      this.onSsoSignIn();
    }
  }

  private emitSelfHostedConfig(): void {
    if (this.onSelfHostedConfig) {
      this.onSelfHostedConfig();
    }
  }
}
