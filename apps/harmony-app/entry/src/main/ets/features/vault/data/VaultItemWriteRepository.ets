export enum VaultItemSaveStatus {
  PreviewSaved = 'previewSaved',
  ValidationError = 'validationError'
}

export class VaultLoginDraft {
  title: string;
  username: string;
  uri: string;
  passwordPreview: string;
  hasTotp: boolean;

  constructor(title: string, username: string, uri: string, passwordPreview: string, hasTotp: boolean) {
    this.title = title;
    this.username = username;
    this.uri = uri;
    this.passwordPreview = passwordPreview;
    this.hasTotp = hasTotp;
  }
}

export class VaultItemSaveResult {
  status: VaultItemSaveStatus;
  itemId: string;
  title: string;
  username: string;
  uri: string;
  passwordPreview: string;
  hasTotp: boolean;
  persistedToSdk: boolean;
  requiresSdkCipherCreate: boolean;
  message: string;

  constructor(
    status: VaultItemSaveStatus,
    itemId: string,
    title: string,
    username: string,
    uri: string,
    passwordPreview: string,
    hasTotp: boolean,
    persistedToSdk: boolean,
    requiresSdkCipherCreate: boolean,
    message: string
  ) {
    this.status = status;
    this.itemId = itemId;
    this.title = title;
    this.username = username;
    this.uri = uri;
    this.passwordPreview = passwordPreview;
    this.hasTotp = hasTotp;
    this.persistedToSdk = persistedToSdk;
    this.requiresSdkCipherCreate = requiresSdkCipherCreate;
    this.message = message;
  }
}

export interface VaultItemWriteRepository {
  saveLogin(draft: VaultLoginDraft): VaultItemSaveResult;
}

export class PreviewVaultItemWriteRepository implements VaultItemWriteRepository {
  saveLogin(draft: VaultLoginDraft): VaultItemSaveResult {
    let title: string = draft.title.trim();
    if (title.length === 0) {
      return new VaultItemSaveResult(
        VaultItemSaveStatus.ValidationError,
        '',
        '',
        draft.username.trim(),
        draft.uri.trim(),
        draft.passwordPreview,
        draft.hasTotp,
        false,
        true,
        '登录条目名称不能为空'
      );
    }

    return new VaultItemSaveResult(
      VaultItemSaveStatus.PreviewSaved,
      this.previewItemIdFor(title),
      title,
      draft.username.trim(),
      draft.uri.trim(),
      draft.passwordPreview,
      draft.hasTotp,
      false,
      true,
      '登录条目 preview 已准备，真实保存需要 SDK 创建 cipher。'
    );
  }

  private previewItemIdFor(title: string): string {
    let normalized: string = title.toLowerCase();
    let slug: string = '';
    for (let index = 0; index < normalized.length; index++) {
      let character: string = normalized.charAt(index);
      if (this.isSlugCharacter(character)) {
        slug += character;
      } else if (character === ' ' || character === '_' || character === '-') {
        slug += '-';
      }
    }

    if (slug.length === 0) {
      return 'preview-login-item';
    }
    return 'preview-login-' + slug;
  }

  private isSlugCharacter(character: string): boolean {
    return (character >= 'a' && character <= 'z') || (character >= '0' && character <= '9');
  }
}
