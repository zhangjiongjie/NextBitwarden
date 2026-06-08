import { CapabilityStatus } from '../../../core/capability/CapabilityTypes';
import {
  DeviceLoginPasskeyCapability,
  PlatformPasskeyRole
} from '../../../core/capability/PlatformPasskeyCapability';

export enum DevicePasskeyLoginStatus {
  WaitingForPlatform = 'waitingForPlatform',
  Accepted = 'accepted'
}

export class DevicePasskeyLoginSession {
  status: DevicePasskeyLoginStatus;
  platformRole: PlatformPasskeyRole;
  probeStatus: CapabilityStatus;
  requiresExternalAuthenticator: boolean;
  message: string;

  constructor(
    status: DevicePasskeyLoginStatus,
    platformRole: PlatformPasskeyRole,
    probeStatus: CapabilityStatus,
    requiresExternalAuthenticator: boolean,
    message: string
  ) {
    this.status = status;
    this.platformRole = platformRole;
    this.probeStatus = probeStatus;
    this.requiresExternalAuthenticator = requiresExternalAuthenticator;
    this.message = message;
  }
}

export interface DevicePasskeyLoginRepository {
  startLogin(): DevicePasskeyLoginSession;

  acceptPreviewLogin(): DevicePasskeyLoginSession;
}

export class PreviewDevicePasskeyLoginRepository implements DevicePasskeyLoginRepository {
  private capability: DeviceLoginPasskeyCapability = new DeviceLoginPasskeyCapability();

  startLogin(): DevicePasskeyLoginSession {
    return new DevicePasskeyLoginSession(
      DevicePasskeyLoginStatus.WaitingForPlatform,
      this.capability.role,
      CapabilityStatus.NeedsSpike,
      false,
      '一期只接设备内置 Passkey 登录，不接 NFC、YubiKey 或漫游认证器。'
    );
  }

  acceptPreviewLogin(): DevicePasskeyLoginSession {
    return new DevicePasskeyLoginSession(
      DevicePasskeyLoginStatus.Accepted,
      this.capability.role,
      CapabilityStatus.NeedsSpike,
      false,
      'preview 模式下模拟平台 Passkey 登录成功。'
    );
  }
}
