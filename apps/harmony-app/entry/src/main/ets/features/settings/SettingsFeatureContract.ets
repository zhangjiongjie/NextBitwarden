export enum SettingsSurface {
  ServerConfig = 'serverConfig',
  PremiumWeb = 'premiumWeb',
  BiometricUnlock = 'biometricUnlock',
  Sync = 'sync',
  Security = 'security'
}

export class SettingsReleaseRequirement {
  surface: SettingsSurface;
  firstReleaseRequired: boolean;
  message: string;

  constructor(surface: SettingsSurface, firstReleaseRequired: boolean, message: string) {
    this.surface = surface;
    this.firstReleaseRequired = firstReleaseRequired;
    this.message = message;
  }
}

export function getFirstReleaseSettingsRequirements(): SettingsReleaseRequirement[] {
  return [
    new SettingsReleaseRequirement(SettingsSurface.ServerConfig, true, '自托管服务器配置纳入一期。'),
    new SettingsReleaseRequirement(SettingsSurface.PremiumWeb, true, 'Premium / 订阅一期完全开放，不在应用端购买或限制。'),
    new SettingsReleaseRequirement(SettingsSurface.BiometricUnlock, true, '生物识别解锁需要与 HUKS 密钥保护组合实现。'),
    new SettingsReleaseRequirement(SettingsSurface.Sync, true, '推送、前台同步、手动同步按双模式落地。'),
    new SettingsReleaseRequirement(SettingsSurface.Security, true, '剪贴板清理、自动锁定和本地安全策略必须独立配置。')
  ];
}
