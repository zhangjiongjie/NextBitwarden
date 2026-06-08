import { describe, it, expect } from '@ohos/hypium';
import { CapabilityStatus } from '../../../main/ets/core/capability/CapabilityTypes';
import { PlatformPasskeyRole } from '../../../main/ets/core/capability/PlatformPasskeyCapability';
import {
  DevicePasskeyLoginSession,
  DevicePasskeyLoginStatus,
  PreviewDevicePasskeyLoginRepository
} from '../../../main/ets/features/auth/data/DevicePasskeyLoginRepository';

export default function devicePasskeyLoginRepositoryTest(): void {
  describe('PreviewDevicePasskeyLoginRepository', () => {
    it('starts a device built-in passkey login session without external authenticators', 0, () => {
      let repository: PreviewDevicePasskeyLoginRepository = new PreviewDevicePasskeyLoginRepository();

      let session: DevicePasskeyLoginSession = repository.startLogin();

      expect(session.status).assertEqual(DevicePasskeyLoginStatus.WaitingForPlatform);
      expect(session.platformRole).assertEqual(PlatformPasskeyRole.ClientLogin);
      expect(session.requiresExternalAuthenticator).assertFalse();
    });

    it('keeps the platform passkey capability as a first-release spike', 0, () => {
      let repository: PreviewDevicePasskeyLoginRepository = new PreviewDevicePasskeyLoginRepository();

      let session: DevicePasskeyLoginSession = repository.startLogin();

      expect(session.probeStatus).assertEqual(CapabilityStatus.NeedsSpike);
      expect(session.message).assertEqual('一期只接设备内置 Passkey 登录，不接 NFC、YubiKey 或漫游认证器。');
    });
  });
}
