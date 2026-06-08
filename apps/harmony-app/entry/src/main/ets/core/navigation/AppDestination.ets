export enum AppDestination {
  SignIn = 'signIn',
  Unlock = 'unlock',
  TotpChallenge = 'totpChallenge',
  ServerConfig = 'serverConfig',
  Vault = 'vault',
  VerificationCodes = 'verificationCodes',
  SystemIntegrations = 'systemIntegrations',
  Settings = 'settings'
}

export function destinationTitle(destination: AppDestination): string {
  switch (destination) {
    case AppDestination.SignIn:
      return '登录';
    case AppDestination.Unlock:
      return '解锁保险库';
    case AppDestination.TotpChallenge:
      return 'TOTP 二步验证';
    case AppDestination.ServerConfig:
      return '自托管服务器';
    case AppDestination.Vault:
      return '保险库';
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
