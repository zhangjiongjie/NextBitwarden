export enum SdkBridgeMode {
  Source = 'source',
  NativeBinding = 'nativeBinding',
  Mock = 'mock'
}

export class SdkBridgeStatus {
  mode: SdkBridgeMode;
  verifiedSdkVersion: string;
  connected: boolean;
  message: string;

  constructor(mode: SdkBridgeMode, verifiedSdkVersion: string, connected: boolean, message: string) {
    this.mode = mode;
    this.verifiedSdkVersion = verifiedSdkVersion;
    this.connected = connected;
    this.message = message;
  }
}

export class SdkClientManager {
  private bridgeMode: SdkBridgeMode;
  private verifiedSdkVersion: string;

  constructor(bridgeMode: SdkBridgeMode, verifiedSdkVersion: string) {
    this.bridgeMode = bridgeMode;
    this.verifiedSdkVersion = verifiedSdkVersion;
  }

  getGlobalStatus(): SdkBridgeStatus {
    return new SdkBridgeStatus(
      this.bridgeMode,
      this.verifiedSdkVersion,
      false,
      'globalClient 边界已建立，真实 Bitwarden SDK 尚未接入。'
    );
  }

  getUserStatus(userId: string): SdkBridgeStatus {
    return new SdkBridgeStatus(
      this.bridgeMode,
      this.verifiedSdkVersion,
      false,
      `userClient(${userId}) 边界已建立，等待登录态和解密上下文接入。`
    );
  }

  createSingleUseStatus(reason: string): SdkBridgeStatus {
    return new SdkBridgeStatus(
      this.bridgeMode,
      this.verifiedSdkVersion,
      false,
      `singleUseClient(${reason}) 边界已建立，用于一次性 SDK 操作。`
    );
  }
}
