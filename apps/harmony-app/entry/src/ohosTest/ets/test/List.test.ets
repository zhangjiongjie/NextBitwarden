import appStateReducerTest from './AppStateReducer.test';
import authRepositoryTest from './AuthRepository.test';
import authStateMachineTest from './AuthStateMachine.test';
import systemIntegrationRepositoryTest from './SystemIntegrationRepository.test';
import vaultRepositoryTest from './VaultRepository.test';
import vaultStateMachineTest from './VaultStateMachine.test';

export default function testsuite(): void {
  appStateReducerTest();
  authRepositoryTest();
  authStateMachineTest();
  systemIntegrationRepositoryTest();
  vaultRepositoryTest();
  vaultStateMachineTest();
}
