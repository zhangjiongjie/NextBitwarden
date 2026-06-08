import { describe, it, expect } from '@ohos/hypium';
import { CapabilityStatus } from '../../../main/ets/core/capability/CapabilityTypes';
import {
  PreviewSystemIntegrationRepository,
  SystemIntegrationArea,
  SystemIntegrationReadiness
} from '../../../main/ets/features/platform/data/SystemIntegrationRepository';

export default function systemIntegrationRepositoryTest(): void {
  describe('PreviewSystemIntegrationRepository', () => {
    it('exposes first-release system integrations in a stable order', 0, () => {
      let repository: PreviewSystemIntegrationRepository = new PreviewSystemIntegrationRepository();

      let items: SystemIntegrationReadiness[] = repository.getReadinessItems();

      expect(items.length).assertEqual(5);
      expect(items[0].area).assertEqual(SystemIntegrationArea.AutofillProvider);
      expect(items[1].area).assertEqual(SystemIntegrationArea.CredentialProvider);
      expect(items[2].area).assertEqual(SystemIntegrationArea.PlatformPasskeyLogin);
      expect(items[0].firstReleaseRequired).assertTrue();
    });

    it('marks autofill provider as a high-risk public provider spike', 0, () => {
      let repository: PreviewSystemIntegrationRepository = new PreviewSystemIntegrationRepository();

      let autofill: SystemIntegrationReadiness = repository.getReadinessItems()[0];

      expect(autofill.status).assertEqual(CapabilityStatus.NeedsSpike);
      expect(autofill.requiresPrivilegedAccess).assertTrue();
      expect(autofill.routeLabel).assertEqual('autoFill/password provider');
    });

    it('keeps credential provider separate from autofill provider', 0, () => {
      let repository: PreviewSystemIntegrationRepository = new PreviewSystemIntegrationRepository();

      let credential: SystemIntegrationReadiness = repository.getReadinessItems()[1];

      expect(credential.area).assertEqual(SystemIntegrationArea.CredentialProvider);
      expect(credential.status).assertEqual(CapabilityStatus.NeedsSpike);
      expect(credential.routeLabel).assertEqual('password + passkey credentials');
    });

    it('treats push sync fallback as available without privileged access', 0, () => {
      let repository: PreviewSystemIntegrationRepository = new PreviewSystemIntegrationRepository();

      let pushSync: SystemIntegrationReadiness = repository.getReadinessItems()[4];

      expect(pushSync.area).assertEqual(SystemIntegrationArea.PushSync);
      expect(pushSync.status).assertEqual(CapabilityStatus.Available);
      expect(pushSync.requiresPrivilegedAccess).assertFalse();
    });
  });
}
