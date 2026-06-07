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

    it('marks system integration navigation as a system entry state', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.Vault);

      let next: AppState = AppStateReducer.reduce(state, AppAction.OpenSystemIntegrations);

      expect(next.rootState).assertEqual(RootState.SystemEntry);
      expect(next.destination).assertEqual(AppDestination.SystemIntegrations);
    });

    it('signs out when returning to the sign-in destination', 0, () => {
      let state: AppState = new AppState(RootState.Unlocked, AppDestination.Settings);

      let next: AppState = AppStateReducer.reduce(state, AppAction.OpenSignIn);

      expect(next.rootState).assertEqual(RootState.SignedOut);
      expect(next.destination).assertEqual(AppDestination.SignIn);
    });
  });
}
