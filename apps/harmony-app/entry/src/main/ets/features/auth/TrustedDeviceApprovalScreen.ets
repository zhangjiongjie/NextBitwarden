import { AppTheme } from '../../app/AppTheme';
import {
  PreviewTrustedDeviceApprovalRepository,
  TrustedDeviceApprovalSession,
  TrustedDeviceApprovalStatus
} from './data/TrustedDeviceApprovalRepository';

const TRUSTED_DEVICE_APPROVAL_REPOSITORY: PreviewTrustedDeviceApprovalRepository =
  new PreviewTrustedDeviceApprovalRepository();

@Component
export struct TrustedDeviceApprovalScreen {
  onApproved?: () => void;
  onBackToSignIn?: () => void;

  @State private statusLabel: string = '等待启动登录审批。';
  @State private detailMessage: string = '首发需要支持 trusted device 登录审批，并在 Push Kit 不可用时保留前台刷新和手动刷新。';

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('登录审批')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text('这里先建立 trusted device 的审批边界。真实实现需要接入 Bitwarden 登录审批状态、Push Kit 通知和同步 fallback。')
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

        Button('等待已登录设备审批')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.startApproval();
          });

        Button('模拟审批通过')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.acceptPreviewApproval();
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

  private startApproval(): void {
    let session: TrustedDeviceApprovalSession = TRUSTED_DEVICE_APPROVAL_REPOSITORY.startApproval();
    this.statusLabel = '等待已登录设备审批';
    this.detailMessage = session.message;
  }

  private acceptPreviewApproval(): void {
    let session: TrustedDeviceApprovalSession = TRUSTED_DEVICE_APPROVAL_REPOSITORY.acceptPreviewApproval();
    this.statusLabel =
      session.status === TrustedDeviceApprovalStatus.Approved ? '登录审批 preview 已通过' : '等待已登录设备审批';
    this.detailMessage = session.message;
    if (session.status === TrustedDeviceApprovalStatus.Approved) {
      this.emitApproved();
    }
  }

  private emitApproved(): void {
    if (this.onApproved) {
      this.onApproved();
    }
  }

  private emitBackToSignIn(): void {
    if (this.onBackToSignIn) {
      this.onBackToSignIn();
    }
  }
}
