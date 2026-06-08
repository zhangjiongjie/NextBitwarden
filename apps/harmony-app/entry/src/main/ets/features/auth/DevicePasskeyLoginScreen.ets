import { AppTheme } from '../../app/AppTheme';
import {
  DevicePasskeyLoginSession,
  DevicePasskeyLoginStatus,
  PreviewDevicePasskeyLoginRepository
} from './data/DevicePasskeyLoginRepository';

const DEVICE_PASSKEY_LOGIN_REPOSITORY: PreviewDevicePasskeyLoginRepository =
  new PreviewDevicePasskeyLoginRepository();

@Component
export struct DevicePasskeyLoginScreen {
  onPasskeyAccepted?: () => void;
  onBackToSignIn?: () => void;

  @State private statusLabel: string = '等待启动设备内置 Passkey。';
  @State private detailMessage: string = '一期只支持设备内置 Passkey 登录，不接外部安全密钥。';

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('设备 Passkey 登录')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text('这里先建立平台 Passkey 登录的能力边界。真实调用后续由 PlatformPasskeyCapability 与 Bitwarden SDK FIDO bridge 接管。')
          .fontSize(14)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(21)
          .width('100%');
      }
      .width('100%');

      Column({ space: 10 }) {
        Text(this.statusLabel)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text(this.detailMessage)
          .fontSize(13)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(20)
          .width('100%');

        Button('准备设备 Passkey')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.startLogin();
          });

        Button('模拟平台 Passkey 成功')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.acceptPreviewLogin();
          });

        Button('返回登录')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontColor(AppTheme.bodyColor)
          .backgroundColor(AppTheme.surfaceColor)
          .onClick(() => {
            this.emitBackToSignIn();
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

  private startLogin(): void {
    let session: DevicePasskeyLoginSession = DEVICE_PASSKEY_LOGIN_REPOSITORY.startLogin();
    this.statusLabel = '等待系统 Passkey';
    this.detailMessage = session.message;
  }

  private acceptPreviewLogin(): void {
    let session: DevicePasskeyLoginSession = DEVICE_PASSKEY_LOGIN_REPOSITORY.acceptPreviewLogin();
    this.statusLabel = session.status === DevicePasskeyLoginStatus.Accepted ? 'Passkey preview 已接受' : '等待系统 Passkey';
    this.detailMessage = session.message;
    if (session.status === DevicePasskeyLoginStatus.Accepted) {
      this.emitPasskeyAccepted();
    }
  }

  private emitPasskeyAccepted(): void {
    if (this.onPasskeyAccepted) {
      this.onPasskeyAccepted();
    }
  }

  private emitBackToSignIn(): void {
    if (this.onBackToSignIn) {
      this.onBackToSignIn();
    }
  }
}
