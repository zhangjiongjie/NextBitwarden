import appStateReducerTest from './AppStateReducer.test';
import authRepositoryTest from './AuthRepository.test';
import authStateMachineTest from './AuthStateMachine.test';
import biometricUnlockRepositoryTest from './BiometricUnlockRepository.test';
import devicePasskeyLoginRepositoryTest from './DevicePasskeyLoginRepository.test';
import serverConfigRepositoryTest from './ServerConfigRepository.test';
import settingsRepositoryTest from './SettingsRepository.test';
import ssoWebAuthRepositoryTest from './SsoWebAuthRepository.test';
import systemIntegrationRepositoryTest from './SystemIntegrationRepository.test';
import totpSetupRepositoryTest from './TotpSetupRepository.test';
import trustedDeviceApprovalRepositoryTest from './TrustedDeviceApprovalRepository.test';
import vaultItemActionRepositoryTest from './VaultItemActionRepository.test';
import vaultItemWriteRepositoryTest from './VaultItemWriteRepository.test';
import vaultRepositoryTest from './VaultRepository.test';
import vaultStateMachineTest from './VaultStateMachine.test';

export default function testsuite(): void {
  appStateReducerTest();
  authRepositoryTest();
  authStateMachineTest();
  biometricUnlockRepositoryTest();
  devicePasskeyLoginRepositoryTest();
  serverConfigRepositoryTest();
  settingsRepositoryTest();
  ssoWebAuthRepositoryTest();
  systemIntegrationRepositoryTest();
  totpSetupRepositoryTest();
  trustedDeviceApprovalRepositoryTest();
  vaultItemActionRepositoryTest();
  vaultItemWriteRepositoryTest();
  vaultRepositoryTest();
  vaultStateMachineTest();
}
