import { CapabilityProbeResult, CapabilityStatus } from './CapabilityTypes';

export enum PushSyncMode {
  PushKit = 'pushKit',
  ForegroundRefresh = 'foregroundRefresh',
  ManualRefresh = 'manualRefresh'
}

export interface PushSyncCapability {
  mode: PushSyncMode;

  probe(): Promise<CapabilityProbeResult>;
}

export class ForegroundRefreshPushSyncCapability implements PushSyncCapability {
  mode: PushSyncMode = PushSyncMode.ForegroundRefresh;

  probe(): Promise<CapabilityProbeResult> {
    return Promise.resolve(new CapabilityProbeResult(
      CapabilityStatus.Available,
      'Push Kit 不作为首发阻塞项，前台同步和手动刷新必须可用。',
      false
    ));
  }
}
