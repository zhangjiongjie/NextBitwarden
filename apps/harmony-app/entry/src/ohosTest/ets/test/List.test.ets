import appStateReducerTest from './AppStateReducer.test';
import authStateMachineTest from './AuthStateMachine.test';
import vaultRepositoryTest from './VaultRepository.test';
import vaultStateMachineTest from './VaultStateMachine.test';

export default function testsuite(): void {
  appStateReducerTest();
  authStateMachineTest();
  vaultRepositoryTest();
  vaultStateMachineTest();
}
