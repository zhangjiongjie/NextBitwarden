import { describe, it, expect } from '@ohos/hypium';
import {
  PreviewVaultRepository,
  VaultHomeViewState,
  VaultItemType,
  VaultListItem,
  VerificationCodeItem
} from '../../../main/ets/features/vault/data/VaultRepository';

export default function vaultRepositoryTest(): void {
  describe('PreviewVaultRepository', () => {
    it('builds vault summary from seeded login and totp items', 0, () => {
      let repository: PreviewVaultRepository = new PreviewVaultRepository();

      let state: VaultHomeViewState = repository.getHomeViewState();

      expect(state.summary.loginCount).assertEqual(3);
      expect(state.summary.totpCount).assertEqual(2);
      expect(state.summary.sendStatus).assertEqual('预留');
    });

    it('keeps vault list items typed for later SDK mapping', 0, () => {
      let repository: PreviewVaultRepository = new PreviewVaultRepository();

      let items: VaultListItem[] = repository.getVaultItems();

      expect(items.length).assertEqual(4);
      expect(items[0].type).assertEqual(VaultItemType.Login);
      expect(items[1].hasTotp).assertTrue();
    });

    it('derives verification codes only from login items with totp', 0, () => {
      let repository: PreviewVaultRepository = new PreviewVaultRepository();

      let codes: VerificationCodeItem[] = repository.getVerificationCodes();

      expect(codes.length).assertEqual(2);
      expect(codes[0].issuer).assertEqual('GitHub');
      expect(codes[0].codePreview).assertEqual('000 000');
    });
  });
}
