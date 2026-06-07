export enum SsoWebAuthStatus {
  NotStarted = 'notStarted',
  WaitingForBrowser = 'waitingForBrowser',
  Completed = 'completed',
  Failed = 'failed'
}

export class SsoWebAuthSession {
  status: SsoWebAuthStatus;
  callbackScheme: string;
  message: string;

  constructor(status: SsoWebAuthStatus, callbackScheme: string, message: string) {
    this.status = status;
    this.callbackScheme = callbackScheme;
    this.message = message;
  }
}

export interface SsoWebAuthCapability {
  createSession(organizationIdentifier: string): SsoWebAuthSession;
}
