import { PushSyncMode } from '../../../core/capability/PushSyncCapability';

export enum TrustedDeviceApprovalStatus {
  WaitingForApproval = 'waitingForApproval',
  Approved = 'approved'
}

export class TrustedDeviceApprovalSession {
  status: TrustedDeviceApprovalStatus;
  preferredMode: PushSyncMode;
  fallbackMode: PushSyncMode;
  manualRefreshAvailable: boolean;
  firstReleaseRequired: boolean;
  message: string;

  constructor(
    status: TrustedDeviceApprovalStatus,
    preferredMode: PushSyncMode,
    fallbackMode: PushSyncMode,
    manualRefreshAvailable: boolean,
    firstReleaseRequired: boolean,
    message: string
  ) {
    this.status = status;
    this.preferredMode = preferredMode;
    this.fallbackMode = fallbackMode;
    this.manualRefreshAvailable = manualRefreshAvailable;
    this.firstReleaseRequired = firstReleaseRequired;
    this.message = message;
  }
}

export interface TrustedDeviceApprovalRepository {
  startApproval(): TrustedDeviceApprovalSession;

  acceptPreviewApproval(): TrustedDeviceApprovalSession;
}

export class PreviewTrustedDeviceApprovalRepository implements TrustedDeviceApprovalRepository {
  startApproval(): TrustedDeviceApprovalSession {
    return new TrustedDeviceApprovalSession(
      TrustedDeviceApprovalStatus.WaitingForApproval,
      PushSyncMode.PushKit,
      PushSyncMode.ForegroundRefresh,
      true,
      true,
      'Push Kit 可用时接入推送审批；不可用时必须保留前台刷新和手动刷新。'
    );
  }

  acceptPreviewApproval(): TrustedDeviceApprovalSession {
    return new TrustedDeviceApprovalSession(
      TrustedDeviceApprovalStatus.Approved,
      PushSyncMode.PushKit,
      PushSyncMode.ForegroundRefresh,
      true,
      true,
      'preview 模式下模拟已登录设备审批通过；真实 Push Kit 与同步轮询仍待接入。'
    );
  }
}
