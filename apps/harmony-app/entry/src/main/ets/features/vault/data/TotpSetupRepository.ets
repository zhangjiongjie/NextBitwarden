export enum TotpSetupMode {
  OtpAuthUri = 'otpAuthUri',
  Manual = 'manual'
}

export enum TotpSetupStatus {
  Empty = 'empty',
  ValidationError = 'validationError',
  ReadyToSave = 'readyToSave'
}

export class TotpSetupDraft {
  status: TotpSetupStatus;
  mode: TotpSetupMode;
  issuer: string;
  accountName: string;
  secretPreview: string;
  message: string;

  constructor(
    status: TotpSetupStatus,
    mode: TotpSetupMode,
    issuer: string,
    accountName: string,
    secretPreview: string,
    message: string
  ) {
    this.status = status;
    this.mode = mode;
    this.issuer = issuer;
    this.accountName = accountName;
    this.secretPreview = secretPreview;
    this.message = message;
  }
}

export interface TotpSetupRepository {
  previewFromUri(uri: string): TotpSetupDraft;

  createManualDraft(issuer: string, accountName: string, secret: string): TotpSetupDraft;
}

export class PreviewTotpSetupRepository implements TotpSetupRepository {
  previewFromUri(uri: string): TotpSetupDraft {
    let value: string = uri.trim();
    if (value.length === 0) {
      return this.validationError(TotpSetupMode.OtpAuthUri, '请输入 TOTP URI');
    }

    let prefix: string = 'otpauth://totp/';
    if (value.indexOf(prefix) !== 0) {
      return this.validationError(TotpSetupMode.OtpAuthUri, '请输入 otpauth://totp 开头的 URI');
    }

    let queryStart: number = value.indexOf('?');
    if (queryStart < 0) {
      return this.validationError(TotpSetupMode.OtpAuthUri, '请输入包含 secret 的 TOTP URI');
    }

    let label: string = value.substring(prefix.length, queryStart);
    let query: string = value.substring(queryStart + 1);
    let secret: string = this.queryValue(query, 'secret').toUpperCase();
    if (this.isBlank(secret)) {
      return this.validationError(TotpSetupMode.OtpAuthUri, '请输入包含 secret 的 TOTP URI');
    }

    let issuerFromQuery: string = this.queryValue(query, 'issuer');
    let issuer: string = '';
    let accountName: string = label;
    let separatorIndex: number = label.indexOf(':');
    if (separatorIndex >= 0) {
      issuer = label.substring(0, separatorIndex);
      accountName = label.substring(separatorIndex + 1);
    }
    if (!this.isBlank(issuerFromQuery)) {
      issuer = issuerFromQuery;
    }

    return this.readyDraft(
      TotpSetupMode.OtpAuthUri,
      this.fallbackName(issuer, '未命名服务'),
      this.fallbackName(accountName, '未命名账号'),
      secret
    );
  }

  createManualDraft(issuer: string, accountName: string, secret: string): TotpSetupDraft {
    let normalizedSecret: string = secret.trim().toUpperCase();
    if (this.isBlank(normalizedSecret)) {
      return this.validationError(TotpSetupMode.Manual, '请输入 TOTP secret');
    }

    return this.readyDraft(
      TotpSetupMode.Manual,
      this.fallbackName(issuer, '未命名服务'),
      this.fallbackName(accountName, '未命名账号'),
      normalizedSecret
    );
  }

  private queryValue(query: string, key: string): string {
    let parts: string[] = query.split('&');
    let prefix: string = key + '=';
    for (let index = 0; index < parts.length; index++) {
      let part: string = parts[index];
      if (part.indexOf(prefix) === 0) {
        return part.substring(prefix.length);
      }
    }
    return '';
  }

  private readyDraft(mode: TotpSetupMode, issuer: string, accountName: string, secret: string): TotpSetupDraft {
    return new TotpSetupDraft(
      TotpSetupStatus.ReadyToSave,
      mode,
      issuer,
      accountName,
      this.previewSecret(secret),
      'preview 模式下已准备保存 TOTP。'
    );
  }

  private validationError(mode: TotpSetupMode, message: string): TotpSetupDraft {
    return new TotpSetupDraft(TotpSetupStatus.ValidationError, mode, '', '', '', message);
  }

  private fallbackName(value: string, fallback: string): string {
    let normalized: string = value.trim();
    return normalized.length > 0 ? normalized : fallback;
  }

  private previewSecret(secret: string): string {
    if (secret.length <= 8) {
      return secret;
    }
    return secret.substring(0, 4) + '...' + secret.substring(secret.length - 4);
  }

  private isBlank(value: string): boolean {
    return value.trim().length === 0;
  }
}
