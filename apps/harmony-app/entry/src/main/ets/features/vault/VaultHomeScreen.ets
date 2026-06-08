import { AppTheme } from '../../app/AppTheme';
import {
  PreviewVaultRepository,
  VaultHomeViewState,
  VaultListItem,
  vaultItemTypeLabel
} from './data/VaultRepository';
import {
  VaultAction,
  VaultEventKind,
  VaultStateMachine,
  VaultTransition,
  VaultViewState,
  createInitialVaultState
} from './state/VaultStateMachine';

const VAULT_REPOSITORY: PreviewVaultRepository = new PreviewVaultRepository();

@Component
export struct VaultHomeScreen {
  onAddTotp?: () => void;
  onItemDetail?: (itemId: string) => void;
  onVerificationCodes?: () => void;
  onSystemIntegrations?: () => void;

  @State private vaultState: VaultViewState = createInitialVaultState();
  private homeViewState: VaultHomeViewState = VAULT_REPOSITORY.getHomeViewState();

  build() {
    Column({ space: 16 }) {
      this.buildSummary();
      this.buildTotpCard();
      this.buildVaultList();
    }
    .width('100%');
  }

  @Builder
  private buildSummary(): void {
    Column({ space: 10 }) {
      Text('我的保险库')
        .fontSize(26)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Row({ space: 10 }) {
        this.buildMetric('登录', this.homeViewState.summary.loginCount.toString());
        this.buildMetric('TOTP', this.homeViewState.summary.totpCount.toString());
        this.buildMetric('Send', this.homeViewState.summary.sendStatus);
      }
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  private buildMetric(label: string, value: string): void {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.primaryColor);

      Text(label)
        .fontSize(12)
        .fontColor(AppTheme.bodyColor);
    }
    .alignItems(HorizontalAlign.Center)
    .layoutWeight(1)
    .padding(12)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(16)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  @Builder
  private buildTotpCard(): void {
    Column({ space: 8 }) {
      Row() {
        Text('验证码')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor)
          .layoutWeight(1);

        Text(this.homeViewState.summary.totpCount.toString())
          .fontSize(14)
          .fontColor(AppTheme.primaryColor)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .backgroundColor(AppTheme.primarySoftColor)
          .borderRadius(12);
      }
      .width('100%');

      Text('Password Manager 主应用需要保留添加 TOTP 和展示两步验证码的入口。')
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');

      Row({ space: 10 }) {
        Button('添加 TOTP')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.handleAddTotp();
          });

        Button('查看验证码')
          .type(ButtonType.Capsule)
          .layoutWeight(1)
          .height(44)
          .fontSize(14)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.handleVerificationCodes();
          });
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(20)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  @Builder
  private buildVaultList(): void {
    Column({ space: 10 }) {
      Row() {
        Text('收藏和类型')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor)
          .layoutWeight(1);

        Button('系统集成')
          .type(ButtonType.Capsule)
          .height(34)
          .fontSize(12)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.handleSystemIntegrations();
          });
      }
      .width('100%');

      ForEach(this.homeViewState.items, (item: VaultListItem) => {
        this.buildVaultItem(item);
      }, (item: VaultListItem) => item.id);
    }
    .width('100%');
  }

  @Builder
  private buildVaultItem(item: VaultListItem): void {
    Row({ space: 12 }) {
      Text(item.favorite ? '★' : '•')
        .fontSize(20)
        .fontColor(item.favorite ? AppTheme.warningColor : AppTheme.primaryMutedColor)
        .width(26);

      Column({ space: 3 }) {
        Text(item.title)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(AppTheme.titleColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });

        Text(item.subtitle)
          .fontSize(13)
          .fontColor(AppTheme.bodyColor)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .layoutWeight(1);

      Text(item.hasTotp ? vaultItemTypeLabel(item.type) + ' + TOTP' : vaultItemTypeLabel(item.type))
        .fontSize(12)
        .fontColor(AppTheme.primaryColor)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor(AppTheme.chipColor)
        .borderRadius(10);
    }
    .width('100%')
    .padding(14)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(16)
    .border({ width: 1, color: AppTheme.dividerColor })
    .onClick(() => {
      this.handleItemDetail(item.id);
    });
  }

  private handleVerificationCodes(): void {
    let transition: VaultTransition = VaultStateMachine.reduce(this.vaultState, VaultAction.OpenVerificationCodes);
    this.applyTransition(transition);
    if (transition.event.kind === VaultEventKind.NavigateToVerificationCodes) {
      this.emitVerificationCodes();
    }
  }

  private handleAddTotp(): void {
    let transition: VaultTransition = VaultStateMachine.reduce(this.vaultState, VaultAction.OpenAddTotp);
    this.applyTransition(transition);
    if (transition.event.kind === VaultEventKind.NavigateToAddTotp) {
      this.emitAddTotp();
    }
  }

  private handleItemDetail(itemId: string): void {
    let transition: VaultTransition = VaultStateMachine.reduce(this.vaultState, VaultAction.OpenItemDetail);
    this.applyTransition(transition);
    if (transition.event.kind === VaultEventKind.NavigateToItemDetail) {
      this.emitItemDetail(itemId);
    }
  }

  private handleSystemIntegrations(): void {
    let transition: VaultTransition = VaultStateMachine.reduce(this.vaultState, VaultAction.OpenSystemIntegrations);
    this.applyTransition(transition);
    if (transition.event.kind === VaultEventKind.NavigateToSystemIntegrations) {
      this.emitSystemIntegrations();
    }
  }

  private applyTransition(transition: VaultTransition): void {
    this.vaultState = transition.state;
  }

  private emitVerificationCodes(): void {
    if (this.onVerificationCodes) {
      this.onVerificationCodes();
    }
  }

  private emitAddTotp(): void {
    if (this.onAddTotp) {
      this.onAddTotp();
    }
  }

  private emitItemDetail(itemId: string): void {
    if (this.onItemDetail) {
      this.onItemDetail(itemId);
    }
  }

  private emitSystemIntegrations(): void {
    if (this.onSystemIntegrations) {
      this.onSystemIntegrations();
    }
  }
}
