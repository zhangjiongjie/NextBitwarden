import { AppDestination, destinationTitle } from '../core/navigation/AppDestination';
import { rootStateDescription, rootStateTitle } from '../core/navigation/RootState';
import { AuthLandingScreen } from '../features/auth/AuthLandingScreen';
import { BiometricUnlockScreen } from '../features/auth/BiometricUnlockScreen';
import { DevicePasskeyLoginScreen } from '../features/auth/DevicePasskeyLoginScreen';
import { SsoWebAuthScreen } from '../features/auth/SsoWebAuthScreen';
import { TotpLoginChallengeScreen } from '../features/auth/TotpLoginChallengeScreen';
import { VaultUnlockScreen } from '../features/auth/VaultUnlockScreen';
import { SystemIntegrationScreen } from '../features/platform/SystemIntegrationScreen';
import { ServerConfigScreen } from '../features/settings/ServerConfigScreen';
import { SettingsOverviewScreen } from '../features/settings/SettingsOverviewScreen';
import { VaultHomeScreen } from '../features/vault/VaultHomeScreen';
import { VerificationCodesScreen } from '../features/vault/VerificationCodesScreen';
import { AppAction, AppState, AppStateReducer, createInitialAppState } from './state/AppStateReducer';
import { AppTheme } from './AppTheme';

@Component
export struct AppShell {
  @State private appState: AppState = createInitialAppState();

  build() {
    Column() {
      this.buildTopBar();

      Scroll() {
        Column({ space: 18 }) {
          this.buildRootStatus();
          this.buildCurrentDestination();
        }
        .width('100%')
        .padding({
          left: 20,
          right: 20,
          top: 12,
          bottom: 18
        });
      }
      .scrollBar(BarState.Off)
      .width('100%')
      .layoutWeight(1);

      this.buildBottomNavigation();
    }
    .width('100%')
    .height('100%')
    .backgroundColor(AppTheme.backgroundColor);
  }

  @Builder
  private buildTopBar(): void {
    Column({ space: 4 }) {
      Text('NextBitwarden')
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.primaryColor)
        .width('100%');

      Text(destinationTitle(this.destination))
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.titleColor)
        .width('100%');
    }
    .width('100%')
    .padding({
      left: 20,
      right: 20,
      top: 18,
      bottom: 12
    })
    .backgroundColor(AppTheme.surfaceColor)
    .border({
      width: { bottom: 1 },
      color: AppTheme.dividerColor
    });
  }

  @Builder
  private buildRootStatus(): void {
    Column({ space: 5 }) {
      Text(rootStateTitle(this.rootState))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Text(rootStateDescription(this.rootState))
        .fontSize(12)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(18)
        .width('100%');
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppTheme.primarySoftColor)
    .borderRadius(18);
  }

  @Builder
  private buildCurrentDestination(): void {
    if (this.destination === AppDestination.SignIn) {
      AuthLandingScreen({
        onPasswordSignIn: () => {
          this.dispatch(AppAction.ContinueWithPassword);
        },
        onDevicePasskey: () => {
          this.dispatch(AppAction.DevicePasskeyRequested);
        },
        onSsoSignIn: () => {
          this.dispatch(AppAction.SsoRequested);
        },
        onSelfHostedConfig: () => {
          this.dispatch(AppAction.SelfHostedRequested);
        }
      });
    } else if (this.destination === AppDestination.SsoWebAuth) {
      SsoWebAuthScreen({
        onBackToSignIn: () => {
          this.dispatch(AppAction.OpenSignIn);
        }
      });
    } else if (this.destination === AppDestination.DevicePasskeyLogin) {
      DevicePasskeyLoginScreen({
        onPasskeyAccepted: () => {
          this.dispatch(AppAction.DevicePasskeySucceeded);
        },
        onBackToSignIn: () => {
          this.dispatch(AppAction.OpenSignIn);
        }
      });
    } else if (this.destination === AppDestination.ServerConfig) {
      ServerConfigScreen({
        onBackToSignIn: () => {
          this.dispatch(AppAction.OpenSignIn);
        },
        onSaved: () => {
          this.dispatch(AppAction.OpenSignIn);
        }
      });
    } else if (this.destination === AppDestination.Unlock) {
      VaultUnlockScreen({
        onUnlocked: () => {
          this.dispatch(AppAction.UnlockSucceeded);
        },
        onTotpRequired: () => {
          this.dispatch(AppAction.MasterPasswordRequiresTotp);
        },
        onUseBiometric: () => {
          this.dispatch(AppAction.BiometricUnlockRequested);
        },
        onBackToLogin: () => {
          this.dispatch(AppAction.BackToLogin);
        }
      });
    } else if (this.destination === AppDestination.BiometricUnlock) {
      BiometricUnlockScreen({
        onBiometricAccepted: () => {
          this.dispatch(AppAction.BiometricUnlockSucceeded);
        },
        onBackToUnlock: () => {
          this.dispatch(AppAction.ContinueWithPassword);
        }
      });
    } else if (this.destination === AppDestination.TotpChallenge) {
      TotpLoginChallengeScreen({
        onTotpAccepted: () => {
          this.dispatch(AppAction.TotpSucceeded);
        },
        onBackToUnlock: () => {
          this.dispatch(AppAction.ContinueWithPassword);
        }
      });
    } else if (this.destination === AppDestination.Vault) {
      VaultHomeScreen({
        onVerificationCodes: () => {
          this.dispatch(AppAction.OpenVerificationCodes);
        },
        onSystemIntegrations: () => {
          this.dispatch(AppAction.OpenSystemIntegrations);
        }
      });
    } else if (this.destination === AppDestination.VerificationCodes) {
      VerificationCodesScreen({
        onBackToVault: () => {
          this.dispatch(AppAction.OpenVault);
        }
      });
    } else if (this.destination === AppDestination.SystemIntegrations) {
      SystemIntegrationScreen();
    } else {
      SettingsOverviewScreen();
    }
  }

  @Builder
  private buildBottomNavigation(): void {
    Row({ space: 8 }) {
      this.buildNavButton('登录', AppDestination.SignIn);
      this.buildNavButton('保险库', AppDestination.Vault);
      this.buildNavButton('集成', AppDestination.SystemIntegrations);
      this.buildNavButton('设置', AppDestination.Settings);
    }
    .width('100%')
    .padding({
      left: 12,
      right: 12,
      top: 10,
      bottom: 14
    })
    .backgroundColor(AppTheme.surfaceColor)
    .border({
      width: { top: 1 },
      color: AppTheme.dividerColor
    });
  }

  @Builder
  private buildNavButton(label: string, target: AppDestination): void {
    Button(label)
      .type(ButtonType.Capsule)
      .layoutWeight(1)
      .height(38)
      .fontSize(12)
      .fontColor(this.destination === target ? AppTheme.primaryColor : AppTheme.bodyColor)
      .backgroundColor(this.destination === target ? AppTheme.primarySoftColor : AppTheme.surfaceColor)
      .onClick(() => {
        this.dispatch(this.actionForDestination(target));
      });
  }

  private get rootState() {
    return this.appState.rootState;
  }

  private get destination() {
    return this.appState.destination;
  }

  private dispatch(action: AppAction): void {
    this.appState = AppStateReducer.reduce(this.appState, action);
  }

  private actionForDestination(target: AppDestination): AppAction {
    switch (target) {
      case AppDestination.SignIn:
        return AppAction.OpenSignIn;
      case AppDestination.DevicePasskeyLogin:
        return AppAction.DevicePasskeyRequested;
      case AppDestination.ServerConfig:
        return AppAction.SelfHostedRequested;
      case AppDestination.SsoWebAuth:
        return AppAction.SsoRequested;
      case AppDestination.BiometricUnlock:
        return AppAction.BiometricUnlockRequested;
      case AppDestination.Vault:
        return AppAction.OpenVault;
      case AppDestination.SystemIntegrations:
        return AppAction.OpenSystemIntegrations;
      case AppDestination.Settings:
        return AppAction.OpenSettings;
      default:
        return AppAction.OpenVault;
    }
  }
}
