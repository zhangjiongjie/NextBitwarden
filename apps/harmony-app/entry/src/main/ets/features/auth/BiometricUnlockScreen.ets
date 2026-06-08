import { AppTheme } from '../../app/AppTheme';
import {
  BiometricUnlockSession,
  BiometricUnlockStatus,
  PreviewBiometricUnlockRepository
} from './data/BiometricUnlockRepository';

const BIOMETRIC_UNLOCK_REPOSITORY: PreviewBiometricUnlockRepository =
  new PreviewBiometricUnlockRepository();

@Component
export struct BiometricUnlockScreen {
  onBiometricAccepted?: () => void;
  onBackToUnlock?: () => void;

  @State private statusLabel: string = '等待启动生物识别。';
  @State private detailMessage: string = '真实解锁需要先通过 userAuth 完成用户认证，再由 HUKS 解封保险库密钥。';

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('生物识别解锁')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text('这里先建立生物识别解锁的能力边界。面容或指纹只证明当前用户，不能替代 HUKS 对保险库密钥的保护。')
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

        Button('准备生物识别解锁')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.startUnlock();
          });

        Button('模拟 userAuth + HUKS 成功')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.acceptPreviewUnlock();
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

  private startUnlock(): void {
    let session: BiometricUnlockSession = BIOMETRIC_UNLOCK_REPOSITORY.startUnlock();
    this.statusLabel = '等待 userAuth 认证';
    this.detailMessage = session.message;
  }

  private acceptPreviewUnlock(): void {
    let session: BiometricUnlockSession = BIOMETRIC_UNLOCK_REPOSITORY.acceptPreviewUnlock();
    this.statusLabel =
      session.status === BiometricUnlockStatus.Accepted ? '生物识别 preview 已接受' : '等待 userAuth 认证';
    this.detailMessage = session.message;
    if (session.status === BiometricUnlockStatus.Accepted) {
      this.emitBiometricAccepted();
    }
  }

  private emitBiometricAccepted(): void {
    if (this.onBiometricAccepted) {
      this.onBiometricAccepted();
    }
  }

  private emitBackToUnlock(): void {
    if (this.onBackToUnlock) {
      this.onBackToUnlock();
    }
  }
}
