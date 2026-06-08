export enum AuthMethod {
  Password = 'password',
  TotpSecondFactor = 'totpSecondFactor',
  DevicePasskey = 'devicePasskey',
  Sso = 'sso',
  TrustedDevice = 'trustedDevice'
}

export enum AuthFlowStage {
  SignedOut = 'signedOut',
  WaitingForMasterPassword = 'waitingForMasterPassword',
  WaitingForTotp = 'waitingForTotp',
  VaultUnlocked = 'vaultUnlocked',
  DevicePasskey = 'devicePasskey',
  TrustedDeviceApproval = 'trustedDeviceApproval',
  Sso = 'sso',
  ServerConfig = 'serverConfig'
}

export enum AuthOperationStatus {
  Ready = 'ready',
  ValidationError = 'validationError',
  RequiresSecondFactor = 'requiresSecondFactor',
  Unlocked = 'unlocked',
  CapabilityStart = 'capabilityStart'
}

export class AuthMethodDescriptor {
  method: AuthMethod;
  firstReleaseRequired: boolean;
  label: string;
  message: string;

  constructor(method: AuthMethod, firstReleaseRequired: boolean, label: string, message: string) {
    this.method = method;
    this.firstReleaseRequired = firstReleaseRequired;
    this.label = label;
    this.message = message;
  }
}

export class AuthSessionPreview {
  email: string;
  stage: AuthFlowStage;
  status: AuthOperationStatus;
  validationMessage: string;

  constructor(email: string, stage: AuthFlowStage, status: AuthOperationStatus, validationMessage: string) {
    this.email = email;
    this.stage = stage;
    this.status = status;
    this.validationMessage = validationMessage;
  }
}

export interface AuthRepository {
  getSupportedMethods(): AuthMethodDescriptor[];

  startPasswordLogin(email: string): AuthSessionPreview;

  unlockWithMasterPassword(email: string, masterPassword: string): AuthSessionPreview;

  submitTotpSecondFactor(email: string, code: string): AuthSessionPreview;

  startDevicePasskeyLogin(): AuthSessionPreview;

  startTrustedDeviceApproval(): AuthSessionPreview;

  startSsoLogin(): AuthSessionPreview;

  openSelfHostedConfig(): AuthSessionPreview;
}

export class PreviewAuthRepository implements AuthRepository {
  getSupportedMethods(): AuthMethodDescriptor[] {
    return [
      new AuthMethodDescriptor(
        AuthMethod.Password,
        true,
        '主密码',
        '账号密码登录是一期开门能力，后续由 Bitwarden SDK bridge 接管。'
      ),
      new AuthMethodDescriptor(
        AuthMethod.TotpSecondFactor,
        true,
        'TOTP 二步验证码',
        '一期必须支持用户使用 TOTP 完成登录。'
      ),
      new AuthMethodDescriptor(
        AuthMethod.DevicePasskey,
        true,
        '设备 Passkey',
        '一期支持设备内置 Passkey 登录，不包含外部安全密钥。'
      ),
      new AuthMethodDescriptor(
        AuthMethod.Sso,
        true,
        '企业 SSO / 自托管',
        'SSO 与自托管服务器配置纳入一期登录边界。'
      ),
      new AuthMethodDescriptor(
        AuthMethod.TrustedDevice,
        true,
        'Trusted device',
        '登录审批和 trusted device 进入首发范围。'
      )
    ];
  }

  startPasswordLogin(email: string): AuthSessionPreview {
    if (this.isBlank(email)) {
      return new AuthSessionPreview('', AuthFlowStage.SignedOut, AuthOperationStatus.ValidationError, '请输入电子邮箱');
    }
    return new AuthSessionPreview(email, AuthFlowStage.WaitingForMasterPassword, AuthOperationStatus.Ready, '');
  }

  unlockWithMasterPassword(email: string, masterPassword: string): AuthSessionPreview {
    if (this.isBlank(masterPassword)) {
      return new AuthSessionPreview(
        email,
        AuthFlowStage.WaitingForMasterPassword,
        AuthOperationStatus.ValidationError,
        '请输入主密码'
      );
    }

    return new AuthSessionPreview(
      email,
      AuthFlowStage.WaitingForTotp,
      AuthOperationStatus.RequiresSecondFactor,
      '需要 TOTP 两步验证码'
    );
  }

  submitTotpSecondFactor(email: string, code: string): AuthSessionPreview {
    if (this.isBlank(code)) {
      return new AuthSessionPreview(
        email,
        AuthFlowStage.WaitingForTotp,
        AuthOperationStatus.ValidationError,
        '请输入 TOTP 两步验证码'
      );
    }

    return new AuthSessionPreview(email, AuthFlowStage.VaultUnlocked, AuthOperationStatus.Unlocked, '');
  }

  startDevicePasskeyLogin(): AuthSessionPreview {
    return new AuthSessionPreview('', AuthFlowStage.DevicePasskey, AuthOperationStatus.CapabilityStart, '');
  }

  startTrustedDeviceApproval(): AuthSessionPreview {
    return new AuthSessionPreview(
      '',
      AuthFlowStage.TrustedDeviceApproval,
      AuthOperationStatus.CapabilityStart,
      '等待已登录设备审批。'
    );
  }

  startSsoLogin(): AuthSessionPreview {
    return new AuthSessionPreview('', AuthFlowStage.Sso, AuthOperationStatus.CapabilityStart, '');
  }

  openSelfHostedConfig(): AuthSessionPreview {
    return new AuthSessionPreview('', AuthFlowStage.ServerConfig, AuthOperationStatus.Ready, '');
  }

  private isBlank(value: string): boolean {
    return value.trim().length === 0;
  }
}
