import { CapabilityProbeResult, CapabilityStatus } from './CapabilityTypes';

export interface BiometricVaultUnlockCapability {
  probe(): Promise<CapabilityProbeResult>;
}

export class NotConfiguredBiometricVaultUnlockCapability implements BiometricVaultUnlockCapability {
  probe(): Promise<CapabilityProbeResult> {
    return Promise.resolve(new CapabilityProbeResult(
      CapabilityStatus.NotConfigured,
      '生物识别只负责用户认证，保险库密钥保护必须通过 HUKS 单独接入。',
      false
    ));
  }
}
