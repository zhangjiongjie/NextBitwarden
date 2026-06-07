export enum AuthEntryPoint {
  Password = 'password',
  TotpSecondFactor = 'totpSecondFactor',
  DevicePasskey = 'devicePasskey',
  Sso = 'sso',
  TrustedDevice = 'trustedDevice'
}

export class AuthReleaseRequirement {
  entryPoint: AuthEntryPoint;
  firstReleaseRequired: boolean;
  message: string;

  constructor(entryPoint: AuthEntryPoint, firstReleaseRequired: boolean, message: string) {
    this.entryPoint = entryPoint;
    this.firstReleaseRequired = firstReleaseRequired;
    this.message = message;
  }
}

export function getFirstReleaseAuthRequirements(): AuthReleaseRequirement[] {
  return [
    new AuthReleaseRequirement(AuthEntryPoint.Password, true, '账号密码登录是一期开门能力。'),
    new AuthReleaseRequirement(AuthEntryPoint.TotpSecondFactor, true, '必须支持用户使用 TOTP 两步验证码登录。'),
    new AuthReleaseRequirement(AuthEntryPoint.DevicePasskey, true, '必须支持设备内置 Passkey 登录。'),
    new AuthReleaseRequirement(AuthEntryPoint.Sso, true, 'SSO 和自托管路径纳入一期架构。'),
    new AuthReleaseRequirement(AuthEntryPoint.TrustedDevice, true, 'trusted device 纳入一期。')
  ];
}
