import { CapabilityStatus } from '../../../core/capability/CapabilityTypes';

export enum BiometricUnlockStatus {
  WaitingForUserAuth = 'waitingForUserAuth',
  Accepted = 'accepted'
}

export class BiometricUnlockSession {
  status: BiometricUnlockStatus;
  probeStatus: CapabilityStatus;
  requiresUserAuth: boolean;
  requiresHuksKeyProtection: boolean;
  message: string;

  constructor(
    status: BiometricUnlockStatus,
    probeStatus: CapabilityStatus,
    requiresUserAuth: boolean,
    requiresHuksKeyProtection: boolean,
    message: string
  ) {
    this.status = status;
    this.probeStatus = probeStatus;
    this.requiresUserAuth = requiresUserAuth;
    this.requiresHuksKeyProtection = requiresHuksKeyProtection;
    this.message = message;
  }
}

export interface BiometricUnlockRepository {
  startUnlock(): BiometricUnlockSession;

  acceptPreviewUnlock(): BiometricUnlockSession;
}

export class PreviewBiometricUnlockRepository implements BiometricUnlockRepository {
  startUnlock(): BiometricUnlockSession {
    return new BiometricUnlockSession(
      BiometricUnlockStatus.WaitingForUserAuth,
      CapabilityStatus.NotConfigured,
      true,
      true,
      '生物识别只负责用户认证，保险库密钥保护必须通过 HUKS 单独接入。'
    );
  }

  acceptPreviewUnlock(): BiometricUnlockSession {
    return new BiometricUnlockSession(
      BiometricUnlockStatus.Accepted,
      CapabilityStatus.NotConfigured,
      true,
      true,
      'preview 模式下模拟 userAuth 与 HUKS 解锁成功；真实保险库密钥解封仍待接入。'
    );
  }
}
