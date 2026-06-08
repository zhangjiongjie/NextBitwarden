import {
  VaultItemDetail,
  VaultItemDetailStatus
} from './VaultRepository';

export enum ClipboardClearPolicy {
  None = 'none',
  TimedClear = 'timedClear'
}

export enum VaultItemCopyTarget {
  Username = 'username',
  Password = 'password',
  Uri = 'uri'
}

export enum VaultItemActionStatus {
  PreviewReady = 'previewReady',
  RequiresDecryptedSecret = 'requiresDecryptedSecret',
  Unavailable = 'unavailable'
}

export class VaultItemActionResult {
  status: VaultItemActionStatus;
  target: VaultItemCopyTarget;
  valuePreview: string;
  clearPolicy: ClipboardClearPolicy;
  clearAfterSeconds: number;
  message: string;

  constructor(
    status: VaultItemActionStatus,
    target: VaultItemCopyTarget,
    valuePreview: string,
    clearPolicy: ClipboardClearPolicy,
    clearAfterSeconds: number,
    message: string
  ) {
    this.status = status;
    this.target = target;
    this.valuePreview = valuePreview;
    this.clearPolicy = clearPolicy;
    this.clearAfterSeconds = clearAfterSeconds;
    this.message = message;
  }
}

export interface VaultItemActionRepository {
  prepareCopy(detail: VaultItemDetail, target: VaultItemCopyTarget): VaultItemActionResult;
}

export class PreviewVaultItemActionRepository implements VaultItemActionRepository {
  prepareCopy(detail: VaultItemDetail, target: VaultItemCopyTarget): VaultItemActionResult {
    if (detail.status !== VaultItemDetailStatus.Found) {
      return new VaultItemActionResult(
        VaultItemActionStatus.Unavailable,
        target,
        '',
        ClipboardClearPolicy.None,
        0,
        '未找到可复制的保险库字段'
      );
    }

    if (target === VaultItemCopyTarget.Username) {
      return new VaultItemActionResult(
        VaultItemActionStatus.PreviewReady,
        target,
        detail.username,
        ClipboardClearPolicy.None,
        0,
        '用户名复制 preview 已准备。'
      );
    }

    if (target === VaultItemCopyTarget.Password) {
      return new VaultItemActionResult(
        VaultItemActionStatus.RequiresDecryptedSecret,
        target,
        detail.passwordPreview,
        ClipboardClearPolicy.TimedClear,
        30,
        '真实密码复制必须由 SDK 解密后写入剪贴板，并安排自动清理。'
      );
    }

    if (target === VaultItemCopyTarget.Uri) {
      return new VaultItemActionResult(
        VaultItemActionStatus.PreviewReady,
        target,
        detail.uri,
        ClipboardClearPolicy.None,
        0,
        'URI 复制 preview 已准备。'
      );
    }

    return new VaultItemActionResult(
      VaultItemActionStatus.Unavailable,
      target,
      '',
      ClipboardClearPolicy.None,
      0,
      '不支持的复制目标'
    );
  }
}
