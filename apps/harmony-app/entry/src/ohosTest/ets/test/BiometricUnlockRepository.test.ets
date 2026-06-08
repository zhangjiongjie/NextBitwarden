import { describe, it, expect } from '@ohos/hypium';
import { CapabilityStatus } from '../../../main/ets/core/capability/CapabilityTypes';
import {
  BiometricUnlockSession,
  BiometricUnlockStatus,
  PreviewBiometricUnlockRepository
} from '../../../main/ets/features/auth/data/BiometricUnlockRepository';

export default function biometricUnlockRepositoryTest(): void {
  describe('PreviewBiometricUnlockRepository', () => {
    it('starts biometric unlock with userauth and huks boundaries', 0, () => {
      let repository: PreviewBiometricUnlockRepository = new PreviewBiometricUnlockRepository();

      let session: BiometricUnlockSession = repository.startUnlock();

      expect(session.status).assertEqual(BiometricUnlockStatus.WaitingForUserAuth);
      expect(session.requiresUserAuth).assertTrue();
      expect(session.requiresHuksKeyProtection).assertTrue();
    });

    it('keeps biometric unlock not configured until userauth and huks are wired', 0, () => {
      let repository: PreviewBiometricUnlockRepository = new PreviewBiometricUnlockRepository();

      let session: BiometricUnlockSession = repository.startUnlock();

      expect(session.probeStatus).assertEqual(CapabilityStatus.NotConfigured);
      expect(session.message).assertEqual('生物识别只负责用户认证，保险库密钥保护必须通过 HUKS 单独接入。');
    });

    it('accepts only the preview biometric unlock session', 0, () => {
      let repository: PreviewBiometricUnlockRepository = new PreviewBiometricUnlockRepository();

      let session: BiometricUnlockSession = repository.acceptPreviewUnlock();

      expect(session.status).assertEqual(BiometricUnlockStatus.Accepted);
      expect(session.probeStatus).assertEqual(CapabilityStatus.NotConfigured);
    });
  });
}
