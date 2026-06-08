import { AppTheme } from '../../app/AppTheme';
import { SsoWebAuthStatus } from '../../core/sdk/SsoWebAuthCapability';
import {
  PreviewSsoWebAuthRepository,
  SsoWebAuthStartResult,
  SsoWebAuthStartStatus
} from './data/SsoWebAuthRepository';

const SSO_WEB_AUTH_REPOSITORY: PreviewSsoWebAuthRepository = new PreviewSsoWebAuthRepository();

@Component
export struct SsoWebAuthScreen {
  onBackToSignIn?: () => void;

  @State private organizationIdentifier: string = '';
  @State private validationMessage: string = '';
  @State private launchUrl: string = '';
  @State private sessionMessage: string = '企业 SSO 一期通过独立 WebAuth 能力边界接入。';

  build() {
    Column({ space: 18 }) {
      Column({ space: 8 }) {
        Text('企业 SSO')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .width('100%');

        Text('这里先建立组织标识、浏览器授权和回调 scheme 的边界。真实浏览器启动、Cookie 和 SDK 登录回调后续由 SsoWebAuthCapability 接管。')
          .fontSize(14)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(21)
          .width('100%');
      }
      .width('100%');

      Column({ space: 12 }) {
        Text('组织标识')
          .fontSize(13)
          .fontColor(AppTheme.mutedColor)
          .width('100%');

        TextInput({
          placeholder: 'acme',
          text: this.organizationIdentifier
        })
          .height(52)
          .fontSize(16)
          .fontColor(AppTheme.titleColor)
          .placeholderColor(AppTheme.mutedColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.organizationIdentifier = value;
            this.validationMessage = '';
            this.launchUrl = '';
            this.sessionMessage = '企业 SSO 一期通过独立 WebAuth 能力边界接入。';
          });

        if (this.validationMessage.length > 0) {
          Text(this.validationMessage)
            .fontSize(12)
            .fontColor(AppTheme.dangerColor)
            .width('100%');
        }

        Text(this.sessionMessage)
          .fontSize(12)
          .fontColor(AppTheme.bodyColor)
          .lineHeight(18)
          .width('100%');

        if (this.launchUrl.length > 0) {
          Text(this.launchUrl)
            .fontSize(12)
            .fontColor(AppTheme.primaryColor)
            .lineHeight(18)
            .width('100%');
        }

        Button('准备浏览器授权')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.startWebAuth();
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

  private startWebAuth(): void {
    let result: SsoWebAuthStartResult = SSO_WEB_AUTH_REPOSITORY.startWebAuth(this.organizationIdentifier);
    if (result.status === SsoWebAuthStartStatus.MissingOrganizationIdentifier) {
      this.validationMessage = result.message;
      this.launchUrl = '';
      this.sessionMessage = '企业 SSO 一期通过独立 WebAuth 能力边界接入。';
      return;
    }
    this.validationMessage = '';
    this.launchUrl = result.launchUrl;
    if (result.session.status === SsoWebAuthStatus.WaitingForBrowser) {
      this.sessionMessage = result.session.message;
    }
  }

  private emitBackToSignIn(): void {
    if (this.onBackToSignIn) {
      this.onBackToSignIn();
    }
  }
}
