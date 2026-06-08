import { describe, it, expect } from '@ohos/hypium';
import {
  PreviewVaultItemWriteRepository,
  VaultItemSaveResult,
  VaultItemSaveStatus,
  VaultLoginDraft
} from '../../../main/ets/features/vault/data/VaultItemWriteRepository';

export default function vaultItemWriteRepositoryTest(): void {
  describe('PreviewVaultItemWriteRepository', () => {
    it('rejects login drafts without a name', 0, () => {
      let repository: PreviewVaultItemWriteRepository = new PreviewVaultItemWriteRepository();
      let draft: VaultLoginDraft = new VaultLoginDraft('', 'owner@example.com', 'https://example.com', '********', false);

      let result: VaultItemSaveResult = repository.saveLogin(draft);

      expect(result.status).assertEqual(VaultItemSaveStatus.ValidationError);
      expect(result.itemId).assertEqual('');
      expect(result.message).assertEqual('登录条目名称不能为空');
    });

    it('prepares a login draft for sdk cipher creation without pretending local persistence', 0, () => {
      let repository: PreviewVaultItemWriteRepository = new PreviewVaultItemWriteRepository();
      let draft: VaultLoginDraft = new VaultLoginDraft(
        'GitLab',
        'dev@example.com',
        'https://gitlab.com',
        '********',
        true
      );

      let result: VaultItemSaveResult = repository.saveLogin(draft);

      expect(result.status).assertEqual(VaultItemSaveStatus.PreviewSaved);
      expect(result.itemId).assertEqual('preview-login-gitlab');
      expect(result.title).assertEqual('GitLab');
      expect(result.username).assertEqual('dev@example.com');
      expect(result.uri).assertEqual('https://gitlab.com');
      expect(result.hasTotp).assertTrue();
      expect(result.persistedToSdk).assertFalse();
      expect(result.requiresSdkCipherCreate).assertTrue();
    });
  });
}
