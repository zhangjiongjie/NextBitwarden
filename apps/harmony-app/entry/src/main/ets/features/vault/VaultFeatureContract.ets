export enum VaultSurface {
  ItemList = 'itemList',
  ItemDetail = 'itemDetail',
  AddEditLogin = 'addEditLogin',
  VerificationCode = 'verificationCode',
  Send = 'send'
}

export class VaultReleaseRequirement {
  surface: VaultSurface;
  firstReleaseRequired: boolean;
  message: string;

  constructor(surface: VaultSurface, firstReleaseRequired: boolean, message: string) {
    this.surface = surface;
    this.firstReleaseRequired = firstReleaseRequired;
    this.message = message;
  }
}

export function getFirstReleaseVaultRequirements(): VaultReleaseRequirement[] {
  return [
    new VaultReleaseRequirement(VaultSurface.ItemList, true, '主保险库列表需要对齐 Android Password Manager。'),
    new VaultReleaseRequirement(VaultSurface.ItemDetail, true, '详情页需要覆盖登录项、URI、字段和附件入口边界。'),
    new VaultReleaseRequirement(VaultSurface.AddEditLogin, true, '添加和编辑登录项必须包含 TOTP 添加入口。'),
    new VaultReleaseRequirement(VaultSurface.VerificationCode, true, '两步验证码展示页面属于主应用一期范围。'),
    new VaultReleaseRequirement(VaultSurface.Send, true, 'Send 属于 Bitwarden 主应用能力，首发按 SDK 可用性推进。')
  ];
}
