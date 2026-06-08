import { CapabilityStatus } from '../../../core/capability/CapabilityTypes';

export enum SystemIntegrationArea {
  AutofillProvider = 'autofillProvider',
  CredentialProvider = 'credentialProvider',
  PlatformPasskeyLogin = 'platformPasskeyLogin',
  BiometricVaultUnlock = 'biometricVaultUnlock',
  PushSync = 'pushSync'
}

export class SystemIntegrationReadiness {
  area: SystemIntegrationArea;
  title: string;
  status: CapabilityStatus;
  statusLabel: string;
  routeLabel: string;
  message: string;
  firstReleaseRequired: boolean;
  requiresPrivilegedAccess: boolean;

  constructor(
    area: SystemIntegrationArea,
    title: string,
    status: CapabilityStatus,
    statusLabel: string,
    routeLabel: string,
    message: string,
    firstReleaseRequired: boolean,
    requiresPrivilegedAccess: boolean
  ) {
    this.area = area;
    this.title = title;
    this.status = status;
    this.statusLabel = statusLabel;
    this.routeLabel = routeLabel;
    this.message = message;
    this.firstReleaseRequired = firstReleaseRequired;
    this.requiresPrivilegedAccess = requiresPrivilegedAccess;
  }
}

export interface SystemIntegrationRepository {
  getReadinessItems(): SystemIntegrationReadiness[];
}

export class PreviewSystemIntegrationRepository implements SystemIntegrationRepository {
  getReadinessItems(): SystemIntegrationReadiness[] {
    return [
      new SystemIntegrationReadiness(
        SystemIntegrationArea.AutofillProvider,
        '自动填充 Provider',
        CapabilityStatus.NeedsSpike,
        '首发必做 / 高风险',
        'autoFill/password provider',
        '优先验证 AutoFillExtensionAbility / autoFill/password，hmbitwarden 是正向市场证据。',
        true,
        true
      ),
      new SystemIntegrationReadiness(
        SystemIntegrationArea.CredentialProvider,
        '凭据获取 / Passkey Provider',
        CapabilityStatus.NeedsSpike,
        '分开验证',
        'password + passkey credentials',
        '不能假设普通自动填充覆盖 Passkey，需要独立 Capability 和准入验证。',
        true,
        true
      ),
      new SystemIntegrationReadiness(
        SystemIntegrationArea.PlatformPasskeyLogin,
        '设备 Passkey 登录',
        CapabilityStatus.NeedsSpike,
        '首发必做',
        'platform authenticator',
        '先支持设备内置 Passkey 登录，不做 NFC、YubiKey、漫游认证器。',
        true,
        false
      ),
      new SystemIntegrationReadiness(
        SystemIntegrationArea.BiometricVaultUnlock,
        '生物识别 + HUKS',
        CapabilityStatus.NotConfigured,
        '首发必做',
        'userAuth + HUKS',
        'userAuth 只做认证，保险库密钥保护必须通过 HUKS 单独接入。',
        true,
        false
      ),
      new SystemIntegrationReadiness(
        SystemIntegrationArea.PushSync,
        '推送 / 实时同步 / 登录审批',
        CapabilityStatus.Available,
        '双模式',
        'foreground + manual refresh',
        'Push Kit 可行则接入；否则前台同步、手动刷新和关键路径刷新必须可用。',
        true,
        false
      )
    ];
  }
}
