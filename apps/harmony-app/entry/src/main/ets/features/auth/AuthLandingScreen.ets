import { AppTheme } from '../../app/AppTheme';
import { AuthMethodDescriptor, PreviewAuthRepository } from './data/AuthRepository';
import {
  AuthAction,
  AuthEventKind,
  AuthStateMachine,
  AuthTransition,
  AuthViewState,
  createInitialAuthState
} from './state/AuthStateMachine';

const AUTH_REPOSITORY: PreviewAuthRepository = new PreviewAuthRepository();

@Component
export struct AuthLandingScreen {
  onPasswordSignIn?: () => void;
  onDevicePasskey?: () => void;
  onSsoSignIn?: () => void;
  onSelfHostedConfig?: () => void;

  @State private authState: AuthViewState = createInitialAuthState();
  private authMethods: AuthMethodDescriptor[] = AUTH_REPOSITORY.getSupportedMethods();

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
          text: this.authState.email
        })
          .height(52)
          .fontSize(16)
          .fontColor(AppTheme.titleColor)
          .placeholderColor(AppTheme.mutedColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .borderRadius(16)
          .padding({ left: 14, right: 14 })
          .onChange((value: string) => {
            this.applyTransition(AuthStateMachine.reduce(this.authState, AuthAction.EmailChanged, value));
          });

        if (this.authState.validationMessage.length > 0) {
          Text(this.authState.validationMessage)
            .fontSize(12)
            .fontColor(AppTheme.dangerColor)
            .width('100%');
        }

        Button('继续使用主密码')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(AppTheme.primaryColor)
          .onClick(() => {
            this.handlePasswordSignIn();
          });

        Button('使用设备 Passkey 登录')
          .type(ButtonType.Capsule)
          .width('100%')
          .height(46)
          .fontSize(15)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.handleDevicePasskey();
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
            this.handleSsoSignIn();
          });

        Button('自托管')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor(AppTheme.titleColor)
          .backgroundColor(AppTheme.surfaceColor)
          .onClick(() => {
            this.handleSelfHostedConfig();
          });
      }
      .width('100%');

      this.buildMethodSummary();
    }
    .width('100%');
  }

  @Builder
  private buildMethodSummary(): void {
    Column({ space: 8 }) {
      Text('一期登录能力边界')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      ForEach(this.authMethods, (method: AuthMethodDescriptor) => {
        Row({ space: 8 }) {
          Text(method.firstReleaseRequired ? '必做' : '预留')
            .fontSize(11)
            .fontColor(AppTheme.primaryColor)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor(AppTheme.primarySoftColor)
            .borderRadius(10);

          Column({ space: 2 }) {
            Text(method.label)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor(AppTheme.titleColor);

            Text(method.message)
              .fontSize(12)
              .fontColor(AppTheme.bodyColor)
              .lineHeight(18);
          }
          .layoutWeight(1);
        }
        .width('100%')
        .padding(12)
        .backgroundColor(AppTheme.surfaceColor)
        .borderRadius(16)
        .border({ width: 1, color: AppTheme.dividerColor });
      }, (method: AuthMethodDescriptor) => method.method);
    }
    .width('100%');
  }

  private handlePasswordSignIn(): void {
    AUTH_REPOSITORY.startPasswordLogin(this.authState.email);
    let transition: AuthTransition = AuthStateMachine.reduce(this.authState, AuthAction.ContinueWithPassword);
    this.applyTransition(transition);
    if (transition.event.kind === AuthEventKind.NavigateToUnlock) {
      this.emitPasswordSignIn();
    }
  }

  private handleDevicePasskey(): void {
    AUTH_REPOSITORY.startDevicePasskeyLogin();
    let transition: AuthTransition = AuthStateMachine.reduce(this.authState, AuthAction.DevicePasskeyRequested);
    this.applyTransition(transition);
    if (transition.event.kind === AuthEventKind.StartDevicePasskeyLogin) {
      this.emitDevicePasskey();
    }
  }

  private handleSsoSignIn(): void {
    AUTH_REPOSITORY.startSsoLogin();
    let transition: AuthTransition = AuthStateMachine.reduce(this.authState, AuthAction.SsoRequested);
    this.applyTransition(transition);
    if (transition.event.kind === AuthEventKind.StartSsoLogin) {
      this.emitSsoSignIn();
    }
  }

  private handleSelfHostedConfig(): void {
    AUTH_REPOSITORY.openSelfHostedConfig();
    let transition: AuthTransition = AuthStateMachine.reduce(this.authState, AuthAction.SelfHostedRequested);
    this.applyTransition(transition);
    if (transition.event.kind === AuthEventKind.OpenServerConfig) {
      this.emitSelfHostedConfig();
    }
  }

  private applyTransition(transition: AuthTransition): void {
    this.authState = transition.state;
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
