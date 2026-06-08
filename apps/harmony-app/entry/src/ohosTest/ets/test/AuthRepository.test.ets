import { describe, it, expect } from '@ohos/hypium';
import {
  AuthFlowStage,
  AuthMethod,
  AuthMethodDescriptor,
  AuthOperationStatus,
  AuthSessionPreview,
  PreviewAuthRepository
} from '../../../main/ets/features/auth/data/AuthRepository';

export default function authRepositoryTest(): void {
  describe('PreviewAuthRepository', () => {
    it('exposes the first-release auth methods in a stable order', 0, () => {
      let repository: PreviewAuthRepository = new PreviewAuthRepository();

      let methods: AuthMethodDescriptor[] = repository.getSupportedMethods();

      expect(methods.length).assertEqual(5);
      expect(methods[0].method).assertEqual(AuthMethod.Password);
      expect(methods[1].method).assertEqual(AuthMethod.TotpSecondFactor);
      expect(methods[2].method).assertEqual(AuthMethod.DevicePasskey);
      expect(methods[0].firstReleaseRequired).assertTrue();
    });

    it('starts password login only after an email is available', 0, () => {
      let repository: PreviewAuthRepository = new PreviewAuthRepository();

      let missingEmail: AuthSessionPreview = repository.startPasswordLogin('');
      let ready: AuthSessionPreview = repository.startPasswordLogin('name@example.com');

      expect(missingEmail.status).assertEqual(AuthOperationStatus.ValidationError);
      expect(missingEmail.validationMessage).assertEqual('请输入电子邮箱');
      expect(ready.stage).assertEqual(AuthFlowStage.WaitingForMasterPassword);
      expect(ready.email).assertEqual('name@example.com');
    });

    it('requires totp after the preview master password unlock step', 0, () => {
      let repository: PreviewAuthRepository = new PreviewAuthRepository();

      let session: AuthSessionPreview = repository.unlockWithMasterPassword('name@example.com', 'correct horse battery staple');

      expect(session.status).assertEqual(AuthOperationStatus.RequiresSecondFactor);
      expect(session.stage).assertEqual(AuthFlowStage.WaitingForTotp);
      expect(session.validationMessage).assertEqual('需要 TOTP 两步验证码');
    });

    it('starts device passkey through a dedicated capability stage', 0, () => {
      let repository: PreviewAuthRepository = new PreviewAuthRepository();

      let session: AuthSessionPreview = repository.startDevicePasskeyLogin();

      expect(session.status).assertEqual(AuthOperationStatus.CapabilityStart);
      expect(session.stage).assertEqual(AuthFlowStage.DevicePasskey);
    });
  });
}
