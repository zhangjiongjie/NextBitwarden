import { describe, it, expect } from '@ohos/hypium';
import {
  PreviewVaultRepository,
  VaultItemDetail
} from '../../../main/ets/features/vault/data/VaultRepository';
import {
  ClipboardClearPolicy,
  VaultItemActionResult,
  VaultItemActionStatus,
  VaultItemCopyTarget,
  PreviewVaultItemActionRepository
} from '../../../main/ets/features/vault/data/VaultItemActionRepository';

export default function vaultItemActionRepositoryTest(): void {
  describe('PreviewVaultItemActionRepository', () => {
    it('prepares username copy without a timed clipboard clear', 0, () => {
      let vaultRepository: PreviewVaultRepository = new PreviewVaultRepository();
      let actionRepository: PreviewVaultItemActionRepository = new PreviewVaultItemActionRepository();
      let detail: VaultItemDetail = vaultRepository.getItemDetail('github-login');

      let result: VaultItemActionResult = actionRepository.prepareCopy(detail, VaultItemCopyTarget.Username);

      expect(result.status).assertEqual(VaultItemActionStatus.PreviewReady);
      expect(result.target).assertEqual(VaultItemCopyTarget.Username);
      expect(result.valuePreview).assertEqual('octocat@example.com');
      expect(result.clearPolicy).assertEqual(ClipboardClearPolicy.None);
      expect(result.clearAfterSeconds).assertEqual(0);
    });

    it('requires decrypted password before password copy and keeps timed clear policy', 0, () => {
      let vaultRepository: PreviewVaultRepository = new PreviewVaultRepository();
      let actionRepository: PreviewVaultItemActionRepository = new PreviewVaultItemActionRepository();
      let detail: VaultItemDetail = vaultRepository.getItemDetail('github-login');

      let result: VaultItemActionResult = actionRepository.prepareCopy(detail, VaultItemCopyTarget.Password);

      expect(result.status).assertEqual(VaultItemActionStatus.RequiresDecryptedSecret);
      expect(result.target).assertEqual(VaultItemCopyTarget.Password);
      expect(result.valuePreview).assertEqual('********');
      expect(result.clearPolicy).assertEqual(ClipboardClearPolicy.TimedClear);
      expect(result.clearAfterSeconds).assertEqual(30);
      expect(result.message).assertEqual('真实密码复制必须由 SDK 解密后写入剪贴板，并安排自动清理。');
    });

    it('blocks copy actions when the vault item is missing', 0, () => {
      let vaultRepository: PreviewVaultRepository = new PreviewVaultRepository();
      let actionRepository: PreviewVaultItemActionRepository = new PreviewVaultItemActionRepository();
      let detail: VaultItemDetail = vaultRepository.getItemDetail('missing-login');

      let result: VaultItemActionResult = actionRepository.prepareCopy(detail, VaultItemCopyTarget.Username);

      expect(result.status).assertEqual(VaultItemActionStatus.Unavailable);
      expect(result.message).assertEqual('未找到可复制的保险库字段');
    });
  });
}
