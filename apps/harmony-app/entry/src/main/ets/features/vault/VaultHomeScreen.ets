import { AppTheme } from '../../app/AppTheme';

class VaultPreviewItem {
  title: string;
  subtitle: string;
  typeLabel: string;
  favorite: boolean;

  constructor(title: string, subtitle: string, typeLabel: string, favorite: boolean) {
    this.title = title;
    this.subtitle = subtitle;
    this.typeLabel = typeLabel;
    this.favorite = favorite;
  }
}

const VAULT_ITEMS: VaultPreviewItem[] = [
  new VaultPreviewItem('Bitwarden', 'vault.bitwarden.com', '登录', true),
  new VaultPreviewItem('GitHub', 'github.com', '登录 + TOTP', true),
  new VaultPreviewItem('公司 VPN', '需要 SSO / trusted device', '登录', false),
  new VaultPreviewItem('恢复代码', '安全笔记', '安全笔记', false)
];

@Component
export struct VaultHomeScreen {
  onVerificationCodes?: () => void;
  onSystemIntegrations?: () => void;

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
        this.buildMetric('登录', '12');
        this.buildMetric('TOTP', '3');
        this.buildMetric('Send', '预留');
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

        Text('3')
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

      Button('查看验证码')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(AppTheme.primaryColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .onClick(() => {
          this.emitVerificationCodes();
        });
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
            this.emitSystemIntegrations();
          });
      }
      .width('100%');

      ForEach(VAULT_ITEMS, (item: VaultPreviewItem) => {
        this.buildVaultItem(item);
      }, (item: VaultPreviewItem) => item.title);
    }
    .width('100%');
  }

  @Builder
  private buildVaultItem(item: VaultPreviewItem): void {
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

      Text(item.typeLabel)
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
    .border({ width: 1, color: AppTheme.dividerColor });
  }

  private emitVerificationCodes(): void {
    if (this.onVerificationCodes) {
      this.onVerificationCodes();
    }
  }

  private emitSystemIntegrations(): void {
    if (this.onSystemIntegrations) {
      this.onSystemIntegrations();
    }
  }
}
