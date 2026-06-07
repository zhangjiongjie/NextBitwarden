export enum ServerEnvironment {
  BitwardenCom = 'bitwardenCom',
  SelfHosted = 'selfHosted'
}

export class ServerConfig {
  environment: ServerEnvironment;
  baseUrl: string;
  identityUrl: string;
  apiUrl: string;
  iconsUrl: string;

  constructor(environment: ServerEnvironment, baseUrl: string, identityUrl: string, apiUrl: string, iconsUrl: string) {
    this.environment = environment;
    this.baseUrl = baseUrl;
    this.identityUrl = identityUrl;
    this.apiUrl = apiUrl;
    this.iconsUrl = iconsUrl;
  }
}

export class ServerConfigBridge {
  createBitwardenCom(): ServerConfig {
    return new ServerConfig(
      ServerEnvironment.BitwardenCom,
      'https://vault.bitwarden.com',
      'https://identity.bitwarden.com',
      'https://api.bitwarden.com',
      'https://icons.bitwarden.net'
    );
  }
}
