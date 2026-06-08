import { AppTheme } from '../../app/AppTheme';
import { ServerConfig } from '../../core/sdk/ServerConfigBridge';
import {
  PreviewServerConfigRepository,
  ServerConfigSaveResult,
  ServerConfigValidationStatus
} from './data/ServerConfigRepository';

const SERVER_CONFIG_REPOSITORY: PreviewServerConfigRepository = new PreviewServerConfigRepository();

@Component
export struct ServerConfigScreen {
  onBackToSignIn?: () => void;
  onSaved?: () => void;

  @State private baseUrl: string = '';
  @State private validationMessage: string = '';
  @State private savedMessage: string = '';

  private defaultConfig: ServerConfig = SERVER_CONFIG_REPOSITORY.getCurrentConfig();

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('自托管服务器')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text('一期保留自托管和 SSO 配置入口。这里先建立 UI 与 ServerConfigRepository 边界，后续由 SDK ServerCommunicationConfigRepository 接管真实持久化。')
          .fontSize(14)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(21)
          .width('100%');
      }
      .width('100%');

      this.buildDefaultConfig();

      Column({ space: 12 }) {
        Text('服务器地址')
          .fontSize(13)
          .fontColor(AppTheme.mutedColor)
          .width('100%');

        TextInput({
          placeholder: 'https://vault.example.com',
          text: this.baseUrl
        })
          .height(52)
          .fontSize(16)
          .fontColor(AppTheme.titleColor)
          .placeholderColor(AppTheme.mutedColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.baseUrl = value;
            this.validationMessage = '';
            this.savedMessage = '';
          });

        if (this.validationMessage.length > 0) {
          Text(this.validationMessage)
            .fontSize(12)
            .fontColor(AppTheme.dangerColor)
            .width('100%');
        }

        if (this.savedMessage.length > 0) {
          Text(this.savedMessage)
            .fontSize(12)
            .fontColor(AppTheme.successColor)
            .width('100%');
        }

        Button('保存自托管配置')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.saveSelfHostedConfig();
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

  @Builder
  private buildDefaultConfig(): void {
    Column({ space: 6 }) {
      Text('默认云端配置')
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Text(this.defaultConfig.baseUrl)
        .fontSize(12)
        .fontColor(AppTheme.bodyColor)
        .width('100%');

      Text(this.defaultConfig.identityUrl)
        .fontSize(12)
        .fontColor(AppTheme.bodyColor)
        .width('100%');
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(18)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  private saveSelfHostedConfig(): void {
    let result: ServerConfigSaveResult = SERVER_CONFIG_REPOSITORY.saveSelfHostedBaseUrl(this.baseUrl);
    if (result.status === ServerConfigValidationStatus.Valid) {
      this.validationMessage = '';
      this.savedMessage = result.message + '：' + result.config.baseUrl;
      this.emitSaved();
      return;
    }
    this.savedMessage = '';
    this.validationMessage = result.message;
  }

  private emitBackToSignIn(): void {
    if (this.onBackToSignIn) {
      this.onBackToSignIn();
    }
  }

  private emitSaved(): void {
    if (this.onSaved) {
      this.onSaved();
    }
  }
}
