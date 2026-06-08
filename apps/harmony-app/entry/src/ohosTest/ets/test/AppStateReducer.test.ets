import { describe, it, expect } from '@ohos/hypium';
import { AppDestination } from '../../../main/ets/core/navigation/AppDestination';
import { RootState } from '../../../main/ets/core/navigation/RootState';
import {
  AppAction,
  AppState,
  AppStateReducer,
  createInitialAppState
} from '../../../main/ets/app/state/AppStateReducer';

export default function appStateReducerTest(): void {
  describe('AppStateReducer', () => {
    it('routes password sign-in to the locked unlock screen', 0, () => {
      let state: AppState = createInitialAppState();

      let next: AppState = AppStateReducer.reduce(state, AppAction.ContinueWithPassword);

      expect(next.rootState).assertEqual(RootState.Locked);
      expect(next.destination).assertEqual(AppDestination.Unlock);
    });

    it('routes successful unlock to the vault home screen', 0, () => {
      let state: AppState = new AppState(RootState.Locked, AppDestination.Unlock);

      let next: AppState = AppStateReducer.reduce(state, AppAction.UnlockSucceeded);

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.Vault);
    });

    it('routes biometric unlock requests to a dedicated userauth and huks screen', 0, () => {
      let state: AppState = new AppState(RootState.Locked, AppDestination.Unlock);

      let next: AppState = AppStateReducer.reduce(state, AppAction.BiometricUnlockRequested);

      expect(next.rootState).assertEqual(RootState.Locked);
      expect(next.destination).assertEqual(AppDestination.BiometricUnlock);
    });

    it('routes successful biometric unlock to the vault home screen', 0, () => {
      let state: AppState = new AppState(RootState.Locked, AppDestination.BiometricUnlock);

      let next: AppState = AppStateReducer.reduce(state, AppAction.BiometricUnlockSucceeded);

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.Vault);
    });

    it('routes master password success to the totp challenge before vault unlock', 0, () => {
      let state: AppState = new AppState(RootState.Locked, AppDestination.Unlock);

      let next: AppState = AppStateReducer.reduce(state, AppAction.MasterPasswordRequiresTotp);

      expect(next.rootState).assertEqual(RootState.Locked);
      expect(next.destination).assertEqual(AppDestination.TotpChallenge);
    });

    it('routes successful totp challenge to the vault home screen', 0, () => {
      let state: AppState = new AppState(RootState.Locked, AppDestination.TotpChallenge);

      let next: AppState = AppStateReducer.reduce(state, AppAction.TotpSucceeded);

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.Vault);
    });

    it('routes add totp requests to a dedicated setup screen', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.Vault);

      let next: AppState = AppStateReducer.reduce(state, AppAction.OpenAddTotp);

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.AddTotp);
    });

    it('routes saved totp setup back to verification codes', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.AddTotp);

      let next: AppState = AppStateReducer.reduce(state, AppAction.TotpSetupSaved);

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.VerificationCodes);
    });

    it('routes add login requests to a dedicated create item screen', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.Vault);

      let next: AppState = AppStateReducer.reduce(state, AppAction.OpenAddLogin);

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.AddLogin);
    });

    it('routes saved vault login drafts to item detail with the created item id', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.AddLogin);

      let next: AppState = AppStateReducer.reduce(state, AppAction.VaultItemSaved, 'preview-login-gitlab');

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.ItemDetail);
      expect(next.selectedVaultItemId).assertEqual('preview-login-gitlab');
    });

    it('routes vault item detail requests with a selected item id', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.Vault);

      let next: AppState = AppStateReducer.reduce(state, AppAction.OpenItemDetail, 'github-login');

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.ItemDetail);
      expect(next.selectedVaultItemId).assertEqual('github-login');
    });

    it('routes device passkey requests to a dedicated platform login screen', 0, () => {
      let state: AppState = createInitialAppState();

      let next: AppState = AppStateReducer.reduce(state, AppAction.DevicePasskeyRequested);

      expect(next.rootState).assertEqual(RootState.SignedOut);
      expect(next.destination).assertEqual(AppDestination.DevicePasskeyLogin);
    });

    it('routes trusted device approval requests to a dedicated login approval screen', 0, () => {
      let state: AppState = createInitialAppState();

      let next: AppState = AppStateReducer.reduce(state, AppAction.TrustedDeviceApprovalRequested);

      expect(next.rootState).assertEqual(RootState.SignedOut);
      expect(next.destination).assertEqual(AppDestination.TrustedDeviceApproval);
    });

    it('routes approved trusted device sessions to the vault home screen', 0, () => {
      let state: AppState = new AppState(RootState.SignedOut, AppDestination.TrustedDeviceApproval);

      let next: AppState = AppStateReducer.reduce(state, AppAction.TrustedDeviceApproved);

      expect(next.rootState).assertEqual(RootState.Unlocked);
      expect(next.destination).assertEqual(AppDestination.Vault);
    });

    it('marks system integration navigation as a system entry state', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.Vault);

      let next: AppState = AppStateReducer.reduce(state, AppAction.OpenSystemIntegrations);

      expect(next.rootState).assertEqual(RootState.SystemEntry);
      expect(next.destination).assertEqual(AppDestination.SystemIntegrations);
    });

    it('routes self-hosted requests to a dedicated server config screen', 0, () => {
      let state: AppState = createInitialAppState();

      let next: AppState = AppStateReducer.reduce(state, AppAction.SelfHostedRequested);

      expect(next.rootState).assertEqual(RootState.SignedOut);
      expect(next.destination).assertEqual(AppDestination.ServerConfig);
    });

    it('routes sso requests to a dedicated web auth screen', 0, () => {
      let state: AppState = createInitialAppState();

      let next: AppState = AppStateReducer.reduce(state, AppAction.SsoRequested);

      expect(next.rootState).assertEqual(RootState.SignedOut);
      expect(next.destination).assertEqual(AppDestination.SsoWebAuth);
    });

    it('signs out when returning to the sign-in destination', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.Settings);

      let next: AppState = AppStateReducer.reduce(state, AppAction.OpenSignIn);

      expect(next.rootState).assertEqual(RootState.SignedOut);
      expect(next.destination).assertEqual(AppDestination.SignIn);
    });
  });
}
