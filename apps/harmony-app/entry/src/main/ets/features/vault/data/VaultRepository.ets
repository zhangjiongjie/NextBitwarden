export enum VaultItemType {
  Login = 'login',
  SecureNote = 'secureNote',
  Card = 'card',
  Identity = 'identity'
}

export class VaultSummary {
  loginCount: number;
  totpCount: number;
  sendStatus: string;

  constructor(loginCount: number, totpCount: number, sendStatus: string) {
    this.loginCount = loginCount;
    this.totpCount = totpCount;
    this.sendStatus = sendStatus;
  }
}

export class VaultListItem {
  id: string;
  title: string;
  subtitle: string;
  type: VaultItemType;
  favorite: boolean;
  hasTotp: boolean;

  constructor(
    id: string,
    title: string,
    subtitle: string,
    type: VaultItemType,
    favorite: boolean,
    hasTotp: boolean
  ) {
    this.id = id;
    this.title = title;
    this.subtitle = subtitle;
    this.type = type;
    this.favorite = favorite;
    this.hasTotp = hasTotp;
  }
}

export class VerificationCodeItem {
  itemId: string;
  issuer: string;
  accountName: string;
  codePreview: string;
  remainingLabel: string;

  constructor(itemId: string, issuer: string, accountName: string, codePreview: string, remainingLabel: string) {
    this.itemId = itemId;
    this.issuer = issuer;
    this.accountName = accountName;
    this.codePreview = codePreview;
    this.remainingLabel = remainingLabel;
  }
}

export enum VaultItemDetailStatus {
  Found = 'found',
  NotFound = 'notFound'
}

export class VaultItemDetail {
  status: VaultItemDetailStatus;
  itemId: string;
  title: string;
  subtitle: string;
  type: VaultItemType;
  username: string;
  passwordPreview: string;
  canRevealPassword: boolean;
  uri: string;
  notes: string;
  hasTotp: boolean;
  message: string;

  constructor(
    status: VaultItemDetailStatus,
    itemId: string,
    title: string,
    subtitle: string,
    type: VaultItemType,
    username: string,
    passwordPreview: string,
    canRevealPassword: boolean,
    uri: string,
    notes: string,
    hasTotp: boolean,
    message: string
  ) {
    this.status = status;
    this.itemId = itemId;
    this.title = title;
    this.subtitle = subtitle;
    this.type = type;
    this.username = username;
    this.passwordPreview = passwordPreview;
    this.canRevealPassword = canRevealPassword;
    this.uri = uri;
    this.notes = notes;
    this.hasTotp = hasTotp;
    this.message = message;
  }
}

export class VaultHomeViewState {
  summary: VaultSummary;
  items: VaultListItem[];
  verificationCodes: VerificationCodeItem[];

  constructor(summary: VaultSummary, items: VaultListItem[], verificationCodes: VerificationCodeItem[]) {
    this.summary = summary;
    this.items = items;
    this.verificationCodes = verificationCodes;
  }
}

export interface VaultRepository {
  getHomeViewState(): VaultHomeViewState;

  getVaultItems(): VaultListItem[];

  getItemDetail(itemId: string): VaultItemDetail;

  getVerificationCodes(): VerificationCodeItem[];
}

export function vaultItemTypeLabel(type: VaultItemType): string {
  switch (type) {
    case VaultItemType.Login:
      return '登录';
    case VaultItemType.SecureNote:
      return '安全笔记';
    case VaultItemType.Card:
      return '银行卡';
    case VaultItemType.Identity:
      return '身份';
    default:
      return '条目';
  }
}

export class PreviewVaultRepository implements VaultRepository {
  private items: VaultListItem[] = [
    new VaultListItem('github-login', 'GitHub', 'github.com', VaultItemType.Login, true, true),
    new VaultListItem('bitwarden-login', 'Bitwarden', 'vault.bitwarden.com', VaultItemType.Login, true, true),
    new VaultListItem('company-vpn-login', '公司 VPN', '需要 SSO / trusted device', VaultItemType.Login, false, false),
    new VaultListItem('recovery-note', '恢复代码', '安全笔记', VaultItemType.SecureNote, false, false)
  ];

  getHomeViewState(): VaultHomeViewState {
    let items: VaultListItem[] = this.getVaultItems();
    let codes: VerificationCodeItem[] = this.getVerificationCodes();
    return new VaultHomeViewState(this.getSummary(items, codes), items, codes);
  }

  getVaultItems(): VaultListItem[] {
    let result: VaultListItem[] = [];
    for (let index = 0; index < this.items.length; index++) {
      let item: VaultListItem = this.items[index];
      result.push(new VaultListItem(item.id, item.title, item.subtitle, item.type, item.favorite, item.hasTotp));
    }
    return result;
  }

  getItemDetail(itemId: string): VaultItemDetail {
    for (let index = 0; index < this.items.length; index++) {
      let item: VaultListItem = this.items[index];
      if (item.id === itemId) {
        return this.detailForItem(item);
      }
    }

    return new VaultItemDetail(
      VaultItemDetailStatus.NotFound,
      itemId,
      '',
      '',
      VaultItemType.Login,
      '',
      '',
      false,
      '',
      '',
      false,
      '未找到保险库条目'
    );
  }

  getVerificationCodes(): VerificationCodeItem[] {
    let result: VerificationCodeItem[] = [];
    for (let index = 0; index < this.items.length; index++) {
      let item: VaultListItem = this.items[index];
      if (item.type === VaultItemType.Login && item.hasTotp) {
        result.push(new VerificationCodeItem(item.id, item.title, item.subtitle, '000 000', '示例'));
      }
    }
    return result;
  }

  private getSummary(items: VaultListItem[], codes: VerificationCodeItem[]): VaultSummary {
    let loginCount: number = 0;
    for (let index = 0; index < items.length; index++) {
      if (items[index].type === VaultItemType.Login) {
        loginCount++;
      }
    }
    return new VaultSummary(loginCount, codes.length, '预留');
  }

  private detailForItem(item: VaultListItem): VaultItemDetail {
    if (item.id === 'github-login') {
      return new VaultItemDetail(
        VaultItemDetailStatus.Found,
        item.id,
        item.title,
        item.subtitle,
        item.type,
        'octocat@example.com',
        '********',
        false,
        'https://github.com',
        'preview 详情仅展示字段边界，真实密码必须由 SDK 解密后再展示。',
        item.hasTotp,
        '条目详情 preview 已就绪。'
      );
    }

    if (item.id === 'bitwarden-login') {
      return new VaultItemDetail(
        VaultItemDetailStatus.Found,
        item.id,
        item.title,
        item.subtitle,
        item.type,
        'owner@example.com',
        '********',
        false,
        'https://vault.bitwarden.com',
        '后续由 VaultRepository bridge 映射 URI、字段、自定义字段和附件。',
        item.hasTotp,
        '条目详情 preview 已就绪。'
      );
    }

    return new VaultItemDetail(
      VaultItemDetailStatus.Found,
      item.id,
      item.title,
      item.subtitle,
      item.type,
      '',
      '',
      false,
      item.subtitle,
      'preview 详情仅保留基础字段。',
      item.hasTotp,
      '条目详情 preview 已就绪。'
    );
  }
}
