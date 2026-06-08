import { AppDestination } from '../../core/navigation/AppDestination';
import { RootState } from '../../core/navigation/RootState';

export enum AppAction {
  ContinueWithPassword = 'continueWithPassword',
  DevicePasskeyRequested = 'devicePasskeyRequested',
  DevicePasskeySucceeded = 'devicePasskeySucceeded',
  SsoRequested = 'ssoRequested',
  SelfHostedRequested = 'selfHostedRequested',
  MasterPasswordRequiresTotp = 'masterPasswordRequiresTotp',
  TotpSucceeded = 'totpSucceeded',
  UnlockSucceeded = 'unlockSucceeded',
  BackToLogin = 'backToLogin',
  OpenSignIn = 'openSignIn',
  OpenVault = 'openVault',
  OpenVerificationCodes = 'openVerificationCodes',
  OpenSystemIntegrations = 'openSystemIntegrations',
  OpenSettings = 'openSettings'
}

export class AppState {
  rootState: RootState;
  destination: AppDestination;

  constructor(rootState: RootState, destination: AppDestination) {
    this.rootState = rootState;
    this.destination = destination;
  }
}

export function createInitialAppState(): AppState {
  return new AppState(RootState.SignedOut, AppDestination.SignIn);
}

export class AppStateReducer {
  static reduce(state: AppState, action: AppAction): AppState {
    switch (action) {
      case AppAction.ContinueWithPassword:
        return new AppState(RootState.Locked, AppDestination.Unlock);
      case AppAction.DevicePasskeyRequested:
        return new AppState(RootState.SignedOut, AppDestination.DevicePasskeyLogin);
      case AppAction.MasterPasswordRequiresTotp:
        return new AppState(RootState.Locked, AppDestination.TotpChallenge);
      case AppAction.DevicePasskeySucceeded:
      case AppAction.TotpSucceeded:
      case AppAction.UnlockSucceeded:
      case AppAction.OpenVault:
        return new AppState(RootState.Unlocked, AppDestination.Vault);
      case AppAction.OpenSettings:
        return new AppState(state.rootState, AppDestination.Settings);
      case AppAction.SsoRequested:
        return new AppState(RootState.SignedOut, AppDestination.SsoWebAuth);
      case AppAction.SelfHostedRequested:
        return new AppState(RootState.SignedOut, AppDestination.ServerConfig);
      case AppAction.OpenVerificationCodes:
        return new AppState(state.rootState, AppDestination.VerificationCodes);
      case AppAction.OpenSystemIntegrations:
        return new AppState(RootState.SystemEntry, AppDestination.SystemIntegrations);
      case AppAction.BackToLogin:
      case AppAction.OpenSignIn:
        return new AppState(RootState.SignedOut, AppDestination.SignIn);
      default:
        return state;
    }
  }
}
