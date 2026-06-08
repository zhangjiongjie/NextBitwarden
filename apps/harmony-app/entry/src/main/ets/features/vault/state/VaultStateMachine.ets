export enum VaultViewSurface {
  ItemList = 'itemList',
  ItemDetail = 'itemDetail',
  AddTotp = 'addTotp',
  VerificationCodes = 'verificationCodes',
  SystemIntegrations = 'systemIntegrations'
}

export enum VaultAction {
  OpenVerificationCodes = 'openVerificationCodes',
  OpenAddTotp = 'openAddTotp',
  BackToItemList = 'backToItemList',
  OpenSystemIntegrations = 'openSystemIntegrations',
  OpenItemDetail = 'openItemDetail',
  LockRequested = 'lockRequested'
}

export enum VaultEventKind {
  None = 'none',
  NavigateToVerificationCodes = 'navigateToVerificationCodes',
  NavigateToAddTotp = 'navigateToAddTotp',
  NavigateToItemList = 'navigateToItemList',
  NavigateToSystemIntegrations = 'navigateToSystemIntegrations',
  NavigateToItemDetail = 'navigateToItemDetail',
  LockVault = 'lockVault'
}

export class VaultViewState {
  surface: VaultViewSurface;
  lockRequested: boolean;

  constructor(surface: VaultViewSurface, lockRequested: boolean) {
    this.surface = surface;
    this.lockRequested = lockRequested;
  }
}

export class VaultEvent {
  kind: VaultEventKind;
  message: string;

  constructor(kind: VaultEventKind, message: string) {
    this.kind = kind;
    this.message = message;
  }
}

export class VaultTransition {
  state: VaultViewState;
  event: VaultEvent;

  constructor(state: VaultViewState, event: VaultEvent) {
    this.state = state;
    this.event = event;
  }
}

export function createInitialVaultState(): VaultViewState {
  return new VaultViewState(VaultViewSurface.ItemList, false);
}

export class VaultStateMachine {
  static reduce(state: VaultViewState, action: VaultAction): VaultTransition {
    switch (action) {
      case VaultAction.OpenVerificationCodes:
        return new VaultTransition(
          new VaultViewState(VaultViewSurface.VerificationCodes, false),
          new VaultEvent(VaultEventKind.NavigateToVerificationCodes, '打开主应用两步验证码页面。')
        );
      case VaultAction.OpenAddTotp:
        return new VaultTransition(
          new VaultViewState(VaultViewSurface.AddTotp, false),
          new VaultEvent(VaultEventKind.NavigateToAddTotp, '打开主应用 TOTP 添加页面。')
        );
      case VaultAction.BackToItemList:
        return new VaultTransition(
          new VaultViewState(VaultViewSurface.ItemList, false),
          new VaultEvent(VaultEventKind.NavigateToItemList, '返回保险库列表。')
        );
      case VaultAction.OpenSystemIntegrations:
        return new VaultTransition(
          new VaultViewState(VaultViewSurface.SystemIntegrations, false),
          new VaultEvent(VaultEventKind.NavigateToSystemIntegrations, '打开系统集成状态面板。')
        );
      case VaultAction.OpenItemDetail:
        return new VaultTransition(
          new VaultViewState(VaultViewSurface.ItemDetail, false),
          new VaultEvent(VaultEventKind.NavigateToItemDetail, '打开保险库条目详情。')
        );
      case VaultAction.LockRequested:
        return new VaultTransition(
          new VaultViewState(state.surface, true),
          new VaultEvent(VaultEventKind.LockVault, '请求锁定保险库。')
        );
      default:
        return new VaultTransition(state, new VaultEvent(VaultEventKind.None, ''));
    }
  }
}
