import { AppDestination, destinationTitle } from '../core/navigation/AppDestination';
import { RootState, rootStateDescription, rootStateTitle } from '../core/navigation/RootState';
import { AuthLandingScreen } from '../features/auth/AuthLandingScreen';
import { VaultUnlockScreen } from '../features/auth/VaultUnlockScreen';
import { SystemIntegrationScreen } from '../features/platform/SystemIntegrationScreen';
import { SettingsOverviewScreen } from '../features/settings/SettingsOverviewScreen';
import { VaultHomeScreen } from '../features/vault/VaultHomeScreen';
import { VerificationCodesScreen } from '../features/vault/VerificationCodesScreen';
import { AppTheme } from './AppTheme';

@Component
export struct AppShell {
  @State private rootState: RootState = RootState.SignedOut;
  @State private destination: AppDestination = AppDestination.SignIn;

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
          this.rootState = RootState.Locked;
          this.destination = AppDestination.Unlock;
        },
        onDevicePasskey: () => {
          this.rootState = RootState.Unlocked;
          this.destination = AppDestination.Vault;
        },
        onSsoSignIn: () => {
          this.destination = AppDestination.Settings;
        },
        onSelfHostedConfig: () => {
          this.destination = AppDestination.Settings;
        }
      });
    } else if (this.destination === AppDestination.Unlock) {
      VaultUnlockScreen({
        onUnlocked: () => {
          this.rootState = RootState.Unlocked;
          this.destination = AppDestination.Vault;
        },
        onUseBiometric: () => {
          this.rootState = RootState.Unlocked;
          this.destination = AppDestination.Vault;
        },
        onBackToLogin: () => {
          this.rootState = RootState.SignedOut;
          this.destination = AppDestination.SignIn;
        }
      });
    } else if (this.destination === AppDestination.Vault) {
      VaultHomeScreen({
        onVerificationCodes: () => {
          this.destination = AppDestination.VerificationCodes;
        },
        onSystemIntegrations: () => {
          this.destination = AppDestination.SystemIntegrations;
        }
      });
    } else if (this.destination === AppDestination.VerificationCodes) {
      VerificationCodesScreen({
        onBackToVault: () => {
          this.destination = AppDestination.Vault;
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
        this.destination = target;
        if (target === AppDestination.SignIn) {
          this.rootState = RootState.SignedOut;
        } else if (target === AppDestination.Vault) {
          this.rootState = RootState.Unlocked;
        } else if (target === AppDestination.SystemIntegrations) {
          this.rootState = RootState.SystemEntry;
        }
      });
  }
}
