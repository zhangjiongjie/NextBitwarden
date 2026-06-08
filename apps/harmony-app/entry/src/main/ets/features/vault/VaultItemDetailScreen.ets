import { AppTheme } from '../../app/AppTheme';
import {
  PreviewVaultRepository,
  VaultItemDetail,
  VaultItemDetailStatus,
  vaultItemTypeLabel
} from './data/VaultRepository';

const VAULT_REPOSITORY: PreviewVaultRepository = new PreviewVaultRepository();

@Component
export struct VaultItemDetailScreen {
  itemId: string = 'github-login';
  onBackToVault?: () => void;

  @State private statusMessage: string = '密码仍保持隐藏。真实展示必须等待 SDK 解密和本地解锁状态确认。';

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('条目详情')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(AppTheme.titleColor)
          .layoutWeight(1);

        Button('返回')
          .type(ButtonType.Capsule)
          .height(36)
          .fontSize(13)
          .fontColor(AppTheme.primaryColor)
          .backgroundColor(AppTheme.primarySoftColor)
          .onClick(() => {
            this.emitBackToVault();
          });
      }
      .width('100%');

      if (this.detail.status === VaultItemDetailStatus.Found) {
        this.buildDetailCard(this.detail);
      } else {
        Text(this.detail.message)
          .fontSize(14)
          .fontColor(AppTheme.dangerColor)
          .lineHeight(20)
          .width('100%')
          .padding(16)
          .backgroundColor(AppTheme.surfaceColor)
          .borderRadius(18)
          .border({ width: 1, color: AppTheme.borderColor });
      }
    }
    .width('100%');
  }

  @Builder
  private buildDetailCard(detail: VaultItemDetail): void {
    Column({ space: 12 }) {
      Text(detail.title)
        .fontSize(22)
        .fontWeight(FontWeight.Bold)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Text(vaultItemTypeLabel(detail.type) + (detail.hasTotp ? ' / 已配置 TOTP' : ''))
        .fontSize(13)
        .fontColor(AppTheme.primaryColor)
        .width('100%');

      this.buildField('用户名', detail.username.length > 0 ? detail.username : '未设置');
      this.buildField('密码', detail.passwordPreview.length > 0 ? detail.passwordPreview : '未设置');
      this.buildField('URI', detail.uri.length > 0 ? detail.uri : detail.subtitle);
      this.buildField('备注', detail.notes);

      Text(this.statusMessage)
        .fontSize(12)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(18)
        .width('100%');

      Button('显示密码 preview')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(AppTheme.primaryColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .onClick(() => {
          this.statusMessage = detail.canRevealPassword ?
            'preview 模式不保存真实密码。' :
            '真实密码必须由 SDK 解密后展示，当前仅保留隐藏占位。';
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(20)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  @Builder
  private buildField(label: string, value: string): void {
    Column({ space: 4 }) {
      Text(label)
        .fontSize(12)
        .fontColor(AppTheme.mutedColor)
        .width('100%');

      Text(value)
        .fontSize(15)
        .fontColor(AppTheme.titleColor)
        .lineHeight(20)
        .width('100%');
    }
    .width('100%')
    .padding(12)
    .backgroundColor(AppTheme.primarySoftColor)
    .borderRadius(14);
  }

  private get detail(): VaultItemDetail {
    return VAULT_REPOSITORY.getItemDetail(this.itemId);
  }

  private emitBackToVault(): void {
    if (this.onBackToVault) {
      this.onBackToVault();
    }
  }
}
