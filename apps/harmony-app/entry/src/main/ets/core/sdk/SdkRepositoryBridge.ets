export enum RepositoryBridgeArea {
  Auth = 'auth',
  Vault = 'vault',
  OrganizationCrypto = 'organizationCrypto',
  KeyConnector = 'keyConnector'
}

export class RepositoryBridgeReadiness {
  area: RepositoryBridgeArea;
  firstReleaseRequired: boolean;
  message: string;

  constructor(area: RepositoryBridgeArea, firstReleaseRequired: boolean, message: string) {
    this.area = area;
    this.firstReleaseRequired = firstReleaseRequired;
    this.message = message;
  }
}

export class SdkRepositoryBridge {
  getReadiness(): RepositoryBridgeReadiness[] {
    return [
      new RepositoryBridgeReadiness(RepositoryBridgeArea.Auth, true, 'Auth 首发必须完整接入。'),
      new RepositoryBridgeReadiness(RepositoryBridgeArea.Vault, true, 'Vault 首发必须完整接入。'),
      new RepositoryBridgeReadiness(RepositoryBridgeArea.OrganizationCrypto, true, '组织加密初始化纳入一期。'),
      new RepositoryBridgeReadiness(RepositoryBridgeArea.KeyConnector, true, 'Key Connector 纳入一期，但属于高风险验证项。')
    ];
  }
}
