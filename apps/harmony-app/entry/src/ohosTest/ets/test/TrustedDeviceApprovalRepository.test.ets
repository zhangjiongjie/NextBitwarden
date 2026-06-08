import { describe, it, expect } from '@ohos/hypium';
import { PushSyncMode } from '../../../main/ets/core/capability/PushSyncCapability';
import {
  PreviewTrustedDeviceApprovalRepository,
  TrustedDeviceApprovalSession,
  TrustedDeviceApprovalStatus
} from '../../../main/ets/features/auth/data/TrustedDeviceApprovalRepository';

export default function trustedDeviceApprovalRepositoryTest(): void {
  describe('PreviewTrustedDeviceApprovalRepository', () => {
    it('starts login approval with push and foreground fallback modes', 0, () => {
      let repository: PreviewTrustedDeviceApprovalRepository = new PreviewTrustedDeviceApprovalRepository();

      let session: TrustedDeviceApprovalSession = repository.startApproval();

      expect(session.status).assertEqual(TrustedDeviceApprovalStatus.WaitingForApproval);
      expect(session.preferredMode).assertEqual(PushSyncMode.PushKit);
      expect(session.fallbackMode).assertEqual(PushSyncMode.ForegroundRefresh);
      expect(session.manualRefreshAvailable).assertTrue();
    });

    it('keeps trusted device approval in the first-release scope', 0, () => {
      let repository: PreviewTrustedDeviceApprovalRepository = new PreviewTrustedDeviceApprovalRepository();

      let session: TrustedDeviceApprovalSession = repository.startApproval();

      expect(session.firstReleaseRequired).assertTrue();
      expect(session.message).assertEqual('Push Kit 可用时接入推送审批；不可用时必须保留前台刷新和手动刷新。');
    });

    it('accepts a preview approval without pretending push kit is already wired', 0, () => {
      let repository: PreviewTrustedDeviceApprovalRepository = new PreviewTrustedDeviceApprovalRepository();

      let session: TrustedDeviceApprovalSession = repository.acceptPreviewApproval();

      expect(session.status).assertEqual(TrustedDeviceApprovalStatus.Approved);
      expect(session.preferredMode).assertEqual(PushSyncMode.PushKit);
      expect(session.fallbackMode).assertEqual(PushSyncMode.ForegroundRefresh);
    });
  });
}
