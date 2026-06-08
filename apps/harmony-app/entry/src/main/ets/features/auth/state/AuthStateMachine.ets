export enum AuthStep {
  EnterEmail = 'enterEmail',
  MasterPassword = 'masterPassword',
  TotpSecondFactor = 'totpSecondFactor',
  DevicePasskey = 'devicePasskey',
  TrustedDeviceApproval = 'trustedDeviceApproval',
  Sso = 'sso',
  ServerConfig = 'serverConfig'
}

export enum AuthAction {
  EmailChanged = 'emailChanged',
  ContinueWithPassword = 'continueWithPassword',
  DevicePasskeyRequested = 'devicePasskeyRequested',
  TrustedDeviceApprovalRequested = 'trustedDeviceApprovalRequested',
  SsoRequested = 'ssoRequested',
  SelfHostedRequested = 'selfHostedRequested',
  TotpSubmitted = 'totpSubmitted',
  BackToEmail = 'backToEmail'
}

export enum AuthEventKind {
  None = 'none',
  RequireEmail = 'requireEmail',
  NavigateToUnlock = 'navigateToUnlock',
  StartDevicePasskeyLogin = 'startDevicePasskeyLogin',
  StartTrustedDeviceApproval = 'startTrustedDeviceApproval',
  StartSsoLogin = 'startSsoLogin',
  OpenServerConfig = 'openServerConfig',
  SubmitTotpCode = 'submitTotpCode'
}

export class AuthViewState {
  step: AuthStep;
  email: string;
  validationMessage: string;

  constructor(step: AuthStep, email: string, validationMessage: string) {
    this.step = step;
    this.email = email;
    this.validationMessage = validationMessage;
  }
}

export class AuthEvent {
  kind: AuthEventKind;
  message: string;

  constructor(kind: AuthEventKind, message: string) {
    this.kind = kind;
    this.message = message;
  }
}

export class AuthTransition {
  state: AuthViewState;
  event: AuthEvent;

  constructor(state: AuthViewState, event: AuthEvent) {
    this.state = state;
    this.event = event;
  }
}

export function createInitialAuthState(): AuthViewState {
  return new AuthViewState(AuthStep.EnterEmail, '', '');
}

export class AuthStateMachine {
  static reduce(state: AuthViewState, action: AuthAction, payload: string = ''): AuthTransition {
    switch (action) {
      case AuthAction.EmailChanged:
        return new AuthTransition(
          new AuthViewState(state.step, payload, ''),
          AuthStateMachine.noneEvent()
        );
      case AuthAction.ContinueWithPassword:
        return AuthStateMachine.continueWithPassword(state);
      case AuthAction.DevicePasskeyRequested:
        return new AuthTransition(
          new AuthViewState(AuthStep.DevicePasskey, state.email, ''),
          new AuthEvent(AuthEventKind.StartDevicePasskeyLogin, '启动设备内置 Passkey 登录。')
        );
      case AuthAction.TrustedDeviceApprovalRequested:
        return new AuthTransition(
          new AuthViewState(AuthStep.TrustedDeviceApproval, state.email, ''),
          new AuthEvent(AuthEventKind.StartTrustedDeviceApproval, '启动 trusted device 登录审批。')
        );
      case AuthAction.SsoRequested:
        return new AuthTransition(
          new AuthViewState(AuthStep.Sso, state.email, ''),
          new AuthEvent(AuthEventKind.StartSsoLogin, '启动企业 SSO 登录。')
        );
      case AuthAction.SelfHostedRequested:
        return new AuthTransition(
          new AuthViewState(AuthStep.ServerConfig, state.email, ''),
          new AuthEvent(AuthEventKind.OpenServerConfig, '打开自托管服务器配置。')
        );
      case AuthAction.TotpSubmitted:
        return new AuthTransition(
          new AuthViewState(AuthStep.TotpSecondFactor, state.email, ''),
          new AuthEvent(AuthEventKind.SubmitTotpCode, '提交 TOTP 两步验证码。')
        );
      case AuthAction.BackToEmail:
        return new AuthTransition(
          new AuthViewState(AuthStep.EnterEmail, state.email, ''),
          AuthStateMachine.noneEvent()
        );
      default:
        return new AuthTransition(state, AuthStateMachine.noneEvent());
    }
  }

  private static continueWithPassword(state: AuthViewState): AuthTransition {
    if (AuthStateMachine.isBlank(state.email)) {
      return new AuthTransition(
        new AuthViewState(AuthStep.EnterEmail, state.email, '请输入电子邮箱'),
        new AuthEvent(AuthEventKind.RequireEmail, '继续登录前需要电子邮箱。')
      );
    }

    return new AuthTransition(
      new AuthViewState(AuthStep.MasterPassword, state.email, ''),
      new AuthEvent(AuthEventKind.NavigateToUnlock, '进入主密码解锁流程。')
    );
  }

  private static isBlank(value: string): boolean {
    return value.trim().length === 0;
  }

  private static noneEvent(): AuthEvent {
    return new AuthEvent(AuthEventKind.None, '');
  }
}
