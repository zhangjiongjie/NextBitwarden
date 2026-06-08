import { AppTheme } from '../../app/AppTheme';
import {
  PreviewVaultItemWriteRepository,
  VaultItemSaveResult,
  VaultItemSaveStatus,
  VaultLoginDraft
} from './data/VaultItemWriteRepository';

const VAULT_ITEM_WRITE_REPOSITORY: PreviewVaultItemWriteRepository = new PreviewVaultItemWriteRepository();

@Component
export struct VaultAddLoginScreen {
  onSaved?: (itemId: string) => void;
  onBackToVault?: () => void;

  @State private title: string = 'GitLab';
  @State private username: string = 'dev@example.com';
  @State private uri: string = 'https://gitlab.com';
  @State private hasTotp: boolean = true;
  @State private statusMessage: string = '新增登录只建立 UI / repository 边界，真实保存需要 SDK 创建 cipher。';

  build() {
    Column({ space: 16 }) {
      Row() {
        Text('新增登录')
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

      Text('Password Manager 需要支持从主应用新增登录条目。当前页面只准备草稿和校验规则，不保存真实密码，也不调用真实保险库同步。')
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');

      this.buildDraftCard();
      this.buildSecurityBoundary();
    }
    .width('100%');
  }

  @Builder
  private buildDraftCard(): void {
    Column({ space: 12 }) {
      this.buildTextInput('名称', '例如 GitHub', this.title, (value: string) => {
        this.title = value;
      });

      this.buildTextInput('用户名', 'alice@example.com', this.username, (value: string) => {
        this.username = value;
      });

      this.buildTextInput('URI', 'https://example.com', this.uri, (value: string) => {
        this.uri = value;
      });

      Button(this.hasTotp ? '已包含 TOTP 标记' : '未包含 TOTP 标记')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(44)
        .fontSize(14)
        .fontColor(this.hasTotp ? AppTheme.successColor : AppTheme.bodyColor)
        .backgroundColor(this.hasTotp ? AppTheme.warningSoftColor : AppTheme.primarySoftColor)
        .onClick(() => {
          this.hasTotp = !this.hasTotp;
        });

      Text(this.statusMessage)
        .fontSize(12)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(18)
        .width('100%');

      Button('保存登录 preview')
        .type(ButtonType.Capsule)
        .width('100%')
        .height(48)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(AppTheme.primaryColor)
        .onClick(() => {
          this.saveLoginPreview();
        });
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(20)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  @Builder
  private buildTextInput(
    label: string,
    placeholder: string,
    value: string,
    onChange: (value: string) => void
  ): void {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(12)
        .fontColor(AppTheme.mutedColor)
        .width('100%');

      TextInput({ placeholder: placeholder, text: value })
        .height(48)
        .fontSize(14)
        .fontColor(AppTheme.titleColor)
        .placeholderColor(AppTheme.mutedColor)
        .backgroundColor(AppTheme.primarySoftColor)
        .borderRadius(16)
        .padding({ left: 14, right: 14 })
        .onChange((input: string) => {
          onChange(input);
          this.statusMessage = '草稿已更新，保存 preview 前仍不会写入真实保险库。';
        });
    }
    .width('100%');
  }

  @Builder
  private buildSecurityBoundary(): void {
    Column({ space: 8 }) {
      Text('密码与保存边界')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(AppTheme.titleColor)
        .width('100%');

      Text('密码字段当前仅显示 ******** 占位。真实版本必须由 SDK / 加密层处理明文输入、cipher 创建、同步和审计，UI 不直接持久化敏感字段。')
        .fontSize(13)
        .fontColor(AppTheme.bodyColor)
        .lineHeight(20)
        .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(AppTheme.surfaceColor)
    .borderRadius(20)
    .border({ width: 1, color: AppTheme.borderColor });
  }

  private saveLoginPreview(): void {
    let draft: VaultLoginDraft = new VaultLoginDraft(this.title, this.username, this.uri, '********', this.hasTotp);
    let result: VaultItemSaveResult = VAULT_ITEM_WRITE_REPOSITORY.saveLogin(draft);
    this.statusMessage = result.message;
    if (result.status === VaultItemSaveStatus.PreviewSaved) {
      this.emitSaved(result.itemId);
    }
  }

  private emitSaved(itemId: string): void {
    if (this.onSaved) {
      this.onSaved(itemId);
    }
  }

  private emitBackToVault(): void {
    if (this.onBackToVault) {
      this.onBackToVault();
    }
  }
}
