import { describe, it, expect } from '@ohos/hypium';
import {
  VaultAction,
  VaultEventKind,
  VaultStateMachine,
  VaultTransition,
  VaultViewState,
  VaultViewSurface,
  createInitialVaultState
} from '../../../main/ets/features/vault/state/VaultStateMachine';

export default function vaultStateMachineTest(): void {
  describe('VaultStateMachine', () => {
    it('opens verification codes from the vault home surface', 0, () => {
      let state: VaultViewState = createInitialVaultState();

      let next: VaultTransition = VaultStateMachine.reduce(state, VaultAction.OpenVerificationCodes);

      expect(next.state.surface).assertEqual(VaultViewSurface.VerificationCodes);
      expect(next.event.kind).assertEqual(VaultEventKind.NavigateToVerificationCodes);
    });

    it('opens add totp setup from the vault home surface', 0, () => {
      let state: VaultViewState = createInitialVaultState();

      let next: VaultTransition = VaultStateMachine.reduce(state, VaultAction.OpenAddTotp);

      expect(next.state.surface).assertEqual(VaultViewSurface.AddTotp);
      expect(next.event.kind).assertEqual(VaultEventKind.NavigateToAddTotp);
    });

    it('opens add login item from the vault home surface', 0, () => {
      let state: VaultViewState = createInitialVaultState();

      let next: VaultTransition = VaultStateMachine.reduce(state, VaultAction.OpenAddLogin);

      expect(next.state.surface).assertEqual(VaultViewSurface.AddLogin);
      expect(next.event.kind).assertEqual(VaultEventKind.NavigateToAddLogin);
    });

    it('opens item detail from the vault home surface', 0, () => {
      let state: VaultViewState = createInitialVaultState();

      let next: VaultTransition = VaultStateMachine.reduce(state, VaultAction.OpenItemDetail);

      expect(next.state.surface).assertEqual(VaultViewSurface.ItemDetail);
      expect(next.event.kind).assertEqual(VaultEventKind.NavigateToItemDetail);
    });

    it('returns from verification codes to the item list', 0, () => {
      let state: VaultViewState = new VaultViewState(VaultViewSurface.VerificationCodes, false);

      let next: VaultTransition = VaultStateMachine.reduce(state, VaultAction.BackToItemList);

      expect(next.state.surface).assertEqual(VaultViewSurface.ItemList);
      expect(next.event.kind).assertEqual(VaultEventKind.NavigateToItemList);
    });

    it('marks system integration navigation as a vault event', 0, () => {
      let state: VaultViewState = createInitialVaultState();

      let next: VaultTransition = VaultStateMachine.reduce(state, VaultAction.OpenSystemIntegrations);

      expect(next.state.surface).assertEqual(VaultViewSurface.SystemIntegrations);
      expect(next.event.kind).assertEqual(VaultEventKind.NavigateToSystemIntegrations);
    });

    it('requests a lock without pretending vault data is still active', 0, () => {
      let state: VaultViewState = createInitialVaultState();

      let next: VaultTransition = VaultStateMachine.reduce(state, VaultAction.LockRequested);

      expect(next.state.lockRequested).assertTrue();
      expect(next.event.kind).assertEqual(VaultEventKind.LockVault);
    });
  });
}
