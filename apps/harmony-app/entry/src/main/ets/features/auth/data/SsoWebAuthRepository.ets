import {
  SsoWebAuthSession,
  SsoWebAuthStatus
} from '../../../core/sdk/SsoWebAuthCapability';

export enum SsoWebAuthStartStatus {
  ReadyForBrowser = 'readyForBrowser',
  MissingOrganizationIdentifier = 'missingOrganizationIdentifier'
}

export class SsoWebAuthStartResult {
  status: SsoWebAuthStartStatus;
  session: SsoWebAuthSession;
  launchUrl: string;
  message: string;

  constructor(status: SsoWebAuthStartStatus, session: SsoWebAuthSession, launchUrl: string, message: string) {
    this.status = status;
    this.session = session;
    this.launchUrl = launchUrl;
    this.message = message;
  }
}

export interface SsoWebAuthRepository {
  startWebAuth(organizationIdentifier: string): SsoWebAuthStartResult;
}

export class PreviewSsoWebAuthRepository implements SsoWebAuthRepository {
  startWebAuth(organizationIdentifier: string): SsoWebAuthStartResult {
    let normalizedIdentifier: string = organizationIdentifier.trim();
    if (normalizedIdentifier.length === 0) {
      return new SsoWebAuthStartResult(
        SsoWebAuthStartStatus.MissingOrganizationIdentifier,
        new SsoWebAuthSession(SsoWebAuthStatus.NotStarted, '', ''),
        '',
        '请输入企业组织标识'
      );
    }

    return new SsoWebAuthStartResult(
      SsoWebAuthStartStatus.ReadyForBrowser,
      new SsoWebAuthSession(SsoWebAuthStatus.WaitingForBrowser, 'nextbitwarden', '等待浏览器完成企业 SSO。'),
      'https://vault.bitwarden.com/#/sso?identifier=' + normalizedIdentifier,
      '已准备启动企业 SSO 浏览器授权'
    );
  }
}
