export enum AppDestination {
  SignIn = 'signIn',
  DevicePasskeyLogin = 'devicePasskeyLogin',
  TrustedDeviceApproval = 'trustedDeviceApproval',
  Unlock = 'unlock',
  BiometricUnlock = 'biometricUnlock',
  TotpChallenge = 'totpChallenge',
  ServerConfig = 'serverConfig',
  SsoWebAuth = 'ssoWebAuth',
  Vault = 'vault',
  ItemDetail = 'itemDetail',
  AddLogin = 'addLogin',
  AddTotp = 'addTotp',
  VerificationCodes = 'verificationCodes',
  SystemIntegrations = 'systemIntegrations',
  Settings = 'settings'
}

export function destinationTitle(destination: AppDestination): string {
  switch (destination) {
    case AppDestination.SignIn:
      return '登录';
    case AppDestination.DevicePasskeyLogin:
      return '设备 Passkey';
    case AppDestination.TrustedDeviceApproval:
      return '登录审批';
    case AppDestination.Unlock:
      return '解锁保险库';
    case AppDestination.BiometricUnlock:
      return '生物识别解锁';
    case AppDestination.TotpChallenge:
      return 'TOTP 二步验证';
    case AppDestination.ServerConfig:
      return '自托管服务器';
    case AppDestination.SsoWebAuth:
      return '企业 SSO';
    case AppDestination.Vault:
      return '保险库';
    case AppDestination.ItemDetail:
      return '条目详情';
    case AppDestination.AddLogin:
      return '新增登录';
    case AppDestination.AddTotp:
      return '添加 TOTP';
    case AppDestination.VerificationCodes:
      return '验证码';
    case AppDestination.SystemIntegrations:
      return '系统集成';
    case AppDestination.Settings:
      return '设置';
    default:
      return 'NextBitwarden';
  }
}
