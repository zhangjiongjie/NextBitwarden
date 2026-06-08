export enum PremiumAccessMode {
  WebOpen = 'webOpen'
}

export enum SettingsPolicyArea {
  PremiumAccess = 'premiumAccess',
  ServerConfig = 'serverConfig',
  SecurityPolicy = 'securityPolicy',
  EnterpriseCrypto = 'enterpriseCrypto',
  EnterpriseCertificate = 'enterpriseCertificate',
  AuthenticatorExtension = 'authenticatorExtension'
}

export class PremiumAccessPolicy {
  mode: PremiumAccessMode;
  inAppPurchaseEnabled: boolean;
  localFeatureGateEnabled: boolean;
  message: string;

  constructor(
    mode: PremiumAccessMode,
    inAppPurchaseEnabled: boolean,
    localFeatureGateEnabled: boolean,
    message: string
  ) {
    this.mode = mode;
    this.inAppPurchaseEnabled = inAppPurchaseEnabled;
    this.localFeatureGateEnabled = localFeatureGateEnabled;
    this.message = message;
  }
}

export class SettingsPolicyItem {
  area: SettingsPolicyArea;
  title: string;
  statusLabel: string;
  message: string;
  firstReleaseRequired: boolean;
  highRisk: boolean;
  reservedForFuture: boolean;

  constructor(
    area: SettingsPolicyArea,
    title: string,
    statusLabel: string,
    message: string,
    firstReleaseRequired: boolean,
    highRisk: boolean,
    reservedForFuture: boolean
  ) {
    this.area = area;
    this.title = title;
    this.statusLabel = statusLabel;
    this.message = message;
    this.firstReleaseRequired = firstReleaseRequired;
    this.highRisk = highRisk;
    this.reservedForFuture = reservedForFuture;
  }
}

export interface SettingsRepository {
  getPremiumAccessPolicy(): PremiumAccessPolicy;

  getPolicyItems(): SettingsPolicyItem[];
}

export class PreviewSettingsRepository implements SettingsRepository {
  getPremiumAccessPolicy(): PremiumAccessPolicy {
    return new PremiumAccessPolicy(
      PremiumAccessMode.WebOpen,
      false,
      false,
      '一期 Premium / 订阅统一走 Web 开放，应用端不做购买，也不做本地功能门禁。'
    );
  }

  getPolicyItems(): SettingsPolicyItem[] {
    return [
      new SettingsPolicyItem(
        SettingsPolicyArea.PremiumAccess,
        'Premium / 订阅',
        'Web 开放',
        this.getPremiumAccessPolicy().message,
        true,
        false,
        false
      ),
      new SettingsPolicyItem(
        SettingsPolicyArea.ServerConfig,
        '自托管服务器',
        '首发必做',
        '保留 baseUrl、identityUrl、apiUrl、iconsUrl 等 ServerConfigBridge 配置入口。',
        true,
        false,
        false
      ),
      new SettingsPolicyItem(
        SettingsPolicyArea.SecurityPolicy,
        '安全策略',
        '首发必做',
        '剪贴板清理、自动锁定、解锁方式和本地密钥保护需要独立设置。',
        true,
        false,
        false
      ),
      new SettingsPolicyItem(
        SettingsPolicyArea.EnterpriseCrypto,
        '企业加密能力',
        '首发高风险',
        'trusted device、组织加密初始化和 key connector 纳入一期，其中 key connector 单列高风险验证。',
        true,
        true,
        false
      ),
      new SettingsPolicyItem(
        SettingsPolicyArea.EnterpriseCertificate,
        '企业证书 / mTLS',
        '预留',
        '一期不做证书导入、证书别名选择或 mTLS 网络闭环，但 ServerConfigBridge 保留扩展位。',
        false,
        true,
        true
      ),
      new SettingsPolicyItem(
        SettingsPolicyArea.AuthenticatorExtension,
        '独立 Authenticator / Bridge',
        '预留',
        '一期和二期都不实现独立 Authenticator 或 authenticatorbridge，只保留 TOTP 域扩展边界。',
        false,
        false,
        true
      )
    ];
  }
}
