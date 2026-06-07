import { describe, it, expect } from '@ohos/hypium';
import {
  AuthAction,
  AuthEventKind,
  AuthStep,
  AuthStateMachine,
  AuthTransition,
  AuthViewState,
  createInitialAuthState
} from '../../../main/ets/features/auth/state/AuthStateMachine';

export default function authStateMachineTest(): void {
  describe('AuthStateMachine', () => {
    it('keeps email changes in the auth view state', 0, () => {
      let state: AuthViewState = createInitialAuthState();

      let next: AuthTransition = AuthStateMachine.reduce(
        state,
        AuthAction.EmailChanged,
        'name@example.com'
      );

      expect(next.state.email).assertEqual('name@example.com');
      expect(next.state.step).assertEqual(AuthStep.EnterEmail);
      expect(next.event.kind).assertEqual(AuthEventKind.None);
    });

    it('requires an email before password sign-in can continue', 0, () => {
      let state: AuthViewState = createInitialAuthState();

      let next: AuthTransition = AuthStateMachine.reduce(state, AuthAction.ContinueWithPassword);

      expect(next.state.step).assertEqual(AuthStep.EnterEmail);
      expect(next.state.validationMessage).assertEqual('请输入电子邮箱');
      expect(next.event.kind).assertEqual(AuthEventKind.RequireEmail);
    });

    it('routes password sign-in with an email to the unlock flow', 0, () => {
      let state: AuthViewState = new AuthViewState(AuthStep.EnterEmail, 'name@example.com', '');

      let next: AuthTransition = AuthStateMachine.reduce(state, AuthAction.ContinueWithPassword);

      expect(next.state.step).assertEqual(AuthStep.MasterPassword);
      expect(next.event.kind).assertEqual(AuthEventKind.NavigateToUnlock);
    });

    it('starts the device passkey login capability from auth', 0, () => {
      let state: AuthViewState = createInitialAuthState();

      let next: AuthTransition = AuthStateMachine.reduce(state, AuthAction.DevicePasskeyRequested);

      expect(next.state.step).assertEqual(AuthStep.DevicePasskey);
      expect(next.event.kind).assertEqual(AuthEventKind.StartDevicePasskeyLogin);
    });
  });
}
