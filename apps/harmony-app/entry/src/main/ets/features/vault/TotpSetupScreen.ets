import { AppTheme } from '../../app/AppTheme';
import {
  PreviewTotpSetupRepository,
  TotpSetupDraft,
  TotpSetupStatus
} from './data/TotpSetupRepository';

const TOTP_SETUP_REPOSITORY: PreviewTotpSetupRepository = new PreviewTotpSetupRepository();

@Component
export struct TotpSetupScreen {
  onSaved?: () => void;
  onBackToVault?: () => void;

  @State private uri: string = '';
  @State private issuer: string = '';
  @State private accountName: string = '';
  @State private secret: string = '';
  @State private statusMessage: string = '可以粘贴 otpauth://totp URI，也可以手动录入发行方、账号和 secret。';
  @State private previewLabel: string = '等待 TOTP 数据';

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('添加 TOTP')
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

      Text('Password Manager 主应用需要支持添加 TOTP。这里先建立 URI / 手动录入和保存 preview 边界，真实保存后续由 VaultRepository / SDK bridge 接管。')
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');

      this.buildUriCard();
      this.buildManualCard();
      this.buildPreviewCard();
    }
    .width('100%');
  }

  @Builder
  private buildUriCard(): void {
    Column({ space: 10 }) {
      Text('从 URI 添加')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      TextInput({
        placeholder: 'otpauth://totp/GitHub:alice@example.com?...',
        text: this.uri
      })
        .height(52)
        .fontSize(14)
        .fontColor(AppTheme.titleColor)
        .placeholderColor(AppTheme.mutedColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.uri = value;
        });

      Button('解析 URI')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(AppTheme.primaryColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .onClick(() => {
          this.previewUri();
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(20)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  @Builder
  private buildManualCard(): void {
    Column({ space: 10 }) {
      Text('手动添加')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      TextInput({ placeholder: '发行方，例如 GitHub', text: this.issuer })
        .height(48)
        .fontSize(14)
        .fontColor(AppTheme.titleColor)
        .placeholderColor(AppTheme.mutedColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.issuer = value;
        });

      TextInput({ placeholder: '账号，例如 alice@example.com', text: this.accountName })
        .height(48)
        .fontSize(14)
        .fontColor(AppTheme.titleColor)
        .placeholderColor(AppTheme.mutedColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.accountName = value;
        });

      TextInput({ placeholder: 'TOTP secret', text: this.secret })
        .height(48)
        .fontSize(14)
        .fontColor(AppTheme.titleColor)
        .placeholderColor(AppTheme.mutedColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.secret = value;
        });

      Button('准备保存')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(AppTheme.primaryColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .onClick(() => {
          this.previewManual();
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(20)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  @Builder
  private buildPreviewCard(): void {
    Column({ space: 10 }) {
      Text(this.previewLabel)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Text(this.statusMessage)
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');

      Button('保存 preview TOTP')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(46)
        .fontSize(15)
        .fontColor(AppTheme.primaryColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .onClick(() => {
          this.emitSaved();
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(20)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  private previewUri(): void {
    this.applyDraft(TOTP_SETUP_REPOSITORY.previewFromUri(this.uri));
  }

  private previewManual(): void {
    this.applyDraft(TOTP_SETUP_REPOSITORY.createManualDraft(this.issuer, this.accountName, this.secret));
  }

  private applyDraft(draft: TotpSetupDraft): void {
    this.statusMessage = draft.message;
    if (draft.status === TotpSetupStatus.ReadyToSave) {
      this.previewLabel = draft.issuer + ' / ' + draft.accountName + ' / ' + draft.secretPreview;
    } else {
      this.previewLabel = '需要补充 TOTP 数据';
    }
  }

  private emitSaved(): void {
    if (this.onSaved) {
      this.onSaved();
    }
  }

  private emitBackToVault(): void {
    if (this.onBackToVault) {
      this.onBackToVault();
    }
  }
}
