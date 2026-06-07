import { CapabilityProbeResult, CapabilityStatus } from './CapabilityTypes';

export enum PlatformPasskeyRole {
  ClientLogin = 'clientLogin',
  ThirdPartyProvider = 'thirdPartyProvider'
}

export interface PlatformPasskeyCapability {
  role: PlatformPasskeyRole;

  probe(): Promise<CapabilityProbeResult>;
}

export class DeviceLoginPasskeyCapability implements PlatformPasskeyCapability {
  role: PlatformPasskeyRole = PlatformPasskeyRole.ClientLogin;

  probe(): Promise<CapabilityProbeResult> {
    return Promise.resolve(new CapabilityProbeResult(
      CapabilityStatus.NeedsSpike,
      '一期优先验证设备内置 Passkey 登录，不包含 NFC、YubiKey 或漫游认证器。',
      false
    ));
  }
}
