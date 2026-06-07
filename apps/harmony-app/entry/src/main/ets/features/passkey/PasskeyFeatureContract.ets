export enum PasskeySurface {
  DeviceLogin = 'deviceLogin',
  AssertionForOtherApp = 'assertionForOtherApp',
  RegistrationForOtherApp = 'registrationForOtherApp'
}

export class PasskeyReleaseRequirement {
  surface: PasskeySurface;
  firstReleaseRequired: boolean;
  message: string;

  constructor(surface: PasskeySurface, firstReleaseRequired: boolean, message: string) {
    this.surface = surface;
    this.firstReleaseRequired = firstReleaseRequired;
    this.message = message;
  }
}

export function getFirstReleasePasskeyRequirements(): PasskeyReleaseRequirement[] {
  return [
    new PasskeyReleaseRequirement(PasskeySurface.DeviceLogin, true, '一期必须支持设备内置 Passkey 登录。'),
    new PasskeyReleaseRequirement(PasskeySurface.AssertionForOtherApp, true, '作为三方凭据提供方响应其他 App 的 Passkey 请求是首发目标。'),
    new PasskeyReleaseRequirement(PasskeySurface.RegistrationForOtherApp, true, 'Passkey 保存 / 注册能力需要与 Credential Provider 边界一起验证。')
  ];
}
