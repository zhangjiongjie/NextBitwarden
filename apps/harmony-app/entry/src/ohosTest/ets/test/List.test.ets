import appStateReducerTest from './AppStateReducer.test';
import authRepositoryTest from './AuthRepository.test';
import authStateMachineTest from './AuthStateMachine.test';
import devicePasskeyLoginRepositoryTest from './DevicePasskeyLoginRepository.test';
import serverConfigRepositoryTest from './ServerConfigRepository.test';
import settingsRepositoryTest from './SettingsRepository.test';
import ssoWebAuthRepositoryTest from './SsoWebAuthRepository.test';
import systemIntegrationRepositoryTest from './SystemIntegrationRepository.test';
import vaultRepositoryTest from './VaultRepository.test';
import vaultStateMachineTest from './VaultStateMachine.test';

export default function testsuite(): void {
  appStateReducerTest();
  authRepositoryTest();
  authStateMachineTest();
  devicePasskeyLoginRepositoryTest();
  serverConfigRepositoryTest();
  settingsRepositoryTest();
  ssoWebAuthRepositoryTest();
  systemIntegrationRepositoryTest();
  vaultRepositoryTest();
  vaultStateMachineTest();
}
