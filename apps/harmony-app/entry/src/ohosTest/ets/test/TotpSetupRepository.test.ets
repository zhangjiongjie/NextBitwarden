import { describe, it, expect } from '@ohos/hypium';
import {
  PreviewTotpSetupRepository,
  TotpSetupDraft,
  TotpSetupMode,
  TotpSetupStatus
} from '../../../main/ets/features/vault/data/TotpSetupRepository';

export default function totpSetupRepositoryTest(): void {
  describe('PreviewTotpSetupRepository', () => {
    it('parses otpauth totp uri into a setup draft', 0, () => {
      let repository: PreviewTotpSetupRepository = new PreviewTotpSetupRepository();

      let draft: TotpSetupDraft = repository.previewFromUri(
        'otpauth://totp/GitHub:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=GitHub'
      );

      expect(draft.status).assertEqual(TotpSetupStatus.ReadyToSave);
      expect(draft.mode).assertEqual(TotpSetupMode.OtpAuthUri);
      expect(draft.issuer).assertEqual('GitHub');
      expect(draft.accountName).assertEqual('alice@example.com');
      expect(draft.secretPreview).assertEqual('JBSW...3PXP');
    });

    it('rejects otpauth uri without a secret', 0, () => {
      let repository: PreviewTotpSetupRepository = new PreviewTotpSetupRepository();

      let draft: TotpSetupDraft = repository.previewFromUri('otpauth://totp/GitHub:alice@example.com?issuer=GitHub');

      expect(draft.status).assertEqual(TotpSetupStatus.ValidationError);
      expect(draft.message).assertEqual('请输入包含 secret 的 TOTP URI');
    });

    it('creates a manual totp setup draft from issuer account and secret', 0, () => {
      let repository: PreviewTotpSetupRepository = new PreviewTotpSetupRepository();

      let draft: TotpSetupDraft = repository.createManualDraft(
        'GitHub',
        'alice@example.com',
        'JBSWY3DPEHPK3PXP'
      );

      expect(draft.status).assertEqual(TotpSetupStatus.ReadyToSave);
      expect(draft.mode).assertEqual(TotpSetupMode.Manual);
      expect(draft.issuer).assertEqual('GitHub');
      expect(draft.accountName).assertEqual('alice@example.com');
      expect(draft.message).assertEqual('preview 模式下已准备保存 TOTP。');
    });
  });
}
