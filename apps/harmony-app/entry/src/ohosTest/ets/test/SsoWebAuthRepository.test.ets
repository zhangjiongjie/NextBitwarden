import { describe, it, expect } from '@ohos/hypium';
import { SsoWebAuthStatus } from '../../../main/ets/core/sdk/SsoWebAuthCapability';
import {
  PreviewSsoWebAuthRepository,
  SsoWebAuthStartResult,
  SsoWebAuthStartStatus
} from '../../../main/ets/features/auth/data/SsoWebAuthRepository';

export default function ssoWebAuthRepositoryTest(): void {
  describe('PreviewSsoWebAuthRepository', () => {
    it('requires an organization identifier before starting browser auth', 0, () => {
      let repository: PreviewSsoWebAuthRepository = new PreviewSsoWebAuthRepository();

      let result: SsoWebAuthStartResult = repository.startWebAuth('');

      expect(result.status).assertEqual(SsoWebAuthStartStatus.MissingOrganizationIdentifier);
      expect(result.session.status).assertEqual(SsoWebAuthStatus.NotStarted);
      expect(result.message).assertEqual('请输入企业组织标识');
    });

    it('creates a preview browser session for an organization identifier', 0, () => {
      let repository: PreviewSsoWebAuthRepository = new PreviewSsoWebAuthRepository();

      let result: SsoWebAuthStartResult = repository.startWebAuth('acme');

      expect(result.status).assertEqual(SsoWebAuthStartStatus.ReadyForBrowser);
      expect(result.session.status).assertEqual(SsoWebAuthStatus.WaitingForBrowser);
      expect(result.session.callbackScheme).assertEqual('nextbitwarden');
      expect(result.launchUrl).assertEqual('https://vault.bitwarden.com/#/sso?identifier=acme');
    });
  });
}
