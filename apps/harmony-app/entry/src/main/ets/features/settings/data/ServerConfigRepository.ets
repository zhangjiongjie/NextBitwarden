import { ServerConfig, ServerConfigBridge } from '../../../core/sdk/ServerConfigBridge';

export enum ServerConfigValidationStatus {
  Valid = 'valid',
  MissingBaseUrl = 'missingBaseUrl',
  RequiresHttps = 'requiresHttps'
}

export class ServerConfigSaveResult {
  status: ServerConfigValidationStatus;
  config: ServerConfig;
  message: string;

  constructor(status: ServerConfigValidationStatus, config: ServerConfig, message: string) {
    this.status = status;
    this.config = config;
    this.message = message;
  }
}

export interface ServerConfigRepository {
  getCurrentConfig(): ServerConfig;

  saveSelfHostedBaseUrl(baseUrl: string): ServerConfigSaveResult;
}

export class PreviewServerConfigRepository implements ServerConfigRepository {
  private bridge: ServerConfigBridge = new ServerConfigBridge();

  getCurrentConfig(): ServerConfig {
    return this.bridge.createBitwardenCom();
  }

  saveSelfHostedBaseUrl(baseUrl: string): ServerConfigSaveResult {
    let normalizedBaseUrl: string = this.normalizeBaseUrl(baseUrl);
    if (normalizedBaseUrl.length === 0) {
      return new ServerConfigSaveResult(
        ServerConfigValidationStatus.MissingBaseUrl,
        this.getCurrentConfig(),
        '请输入自托管服务器地址'
      );
    }
    if (!normalizedBaseUrl.startsWith('https://')) {
      return new ServerConfigSaveResult(
        ServerConfigValidationStatus.RequiresHttps,
        this.getCurrentConfig(),
        '自托管服务器地址必须使用 HTTPS'
      );
    }
    return new ServerConfigSaveResult(
      ServerConfigValidationStatus.Valid,
      this.bridge.createSelfHosted(normalizedBaseUrl),
      '自托管服务器配置已准备好'
    );
  }

  private normalizeBaseUrl(baseUrl: string): string {
    let trimmed: string = baseUrl.trim();
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.slice(0, trimmed.length - 1);
    }
    return trimmed;
  }
}
