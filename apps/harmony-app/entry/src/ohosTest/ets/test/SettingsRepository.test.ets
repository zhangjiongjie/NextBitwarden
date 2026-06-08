import { describe, it, expect } from '@ohos/hypium';
import {
  PremiumAccessMode,
  PremiumAccessPolicy,
  PreviewSettingsRepository,
  SettingsPolicyArea,
  SettingsPolicyItem
} from '../../../main/ets/features/settings/data/SettingsRepository';

export default function settingsRepositoryTest(): void {
  describe('PreviewSettingsRepository', () => {
    it('keeps premium open through web without app purchase or local gating', 0, () => {
      let repository: PreviewSettingsRepository = new PreviewSettingsRepository();

      let policy: PremiumAccessPolicy = repository.getPremiumAccessPolicy();

      expect(policy.mode).assertEqual(PremiumAccessMode.WebOpen);
      expect(policy.inAppPurchaseEnabled).assertFalse();
      expect(policy.localFeatureGateEnabled).assertFalse();
    });

    it('exposes settings policy areas in a stable order', 0, () => {
      let repository: PreviewSettingsRepository = new PreviewSettingsRepository();

      let items: SettingsPolicyItem[] = repository.getPolicyItems();

      expect(items.length).assertEqual(6);
      expect(items[0].area).assertEqual(SettingsPolicyArea.PremiumAccess);
      expect(items[1].area).assertEqual(SettingsPolicyArea.ServerConfig);
      expect(items[2].area).assertEqual(SettingsPolicyArea.SecurityPolicy);
      expect(items[3].area).assertEqual(SettingsPolicyArea.EnterpriseCrypto);
      expect(items[4].area).assertEqual(SettingsPolicyArea.EnterpriseCertificate);
      expect(items[5].area).assertEqual(SettingsPolicyArea.AuthenticatorExtension);
    });

    it('marks key connector as first-release high-risk enterprise work', 0, () => {
      let repository: PreviewSettingsRepository = new PreviewSettingsRepository();

      let enterprise: SettingsPolicyItem = repository.getPolicyItems()[3];

      expect(enterprise.area).assertEqual(SettingsPolicyArea.EnterpriseCrypto);
      expect(enterprise.firstReleaseRequired).assertTrue();
      expect(enterprise.highRisk).assertTrue();
      expect(enterprise.reservedForFuture).assertFalse();
    });

    it('reserves mtls and independent authenticator without making them first-release work', 0, () => {
      let repository: PreviewSettingsRepository = new PreviewSettingsRepository();

      let mtls: SettingsPolicyItem = repository.getPolicyItems()[4];
      let authenticator: SettingsPolicyItem = repository.getPolicyItems()[5];

      expect(mtls.area).assertEqual(SettingsPolicyArea.EnterpriseCertificate);
      expect(mtls.firstReleaseRequired).assertFalse();
      expect(mtls.reservedForFuture).assertTrue();
      expect(authenticator.area).assertEqual(SettingsPolicyArea.AuthenticatorExtension);
      expect(authenticator.firstReleaseRequired).assertFalse();
      expect(authenticator.reservedForFuture).assertTrue();
    });
  });
}
