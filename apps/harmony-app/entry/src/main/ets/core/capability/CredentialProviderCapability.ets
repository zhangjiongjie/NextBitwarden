import { CapabilityProbeResult, CapabilityStatus } from './CapabilityTypes';

export enum CredentialProviderRoute {
  PasswordCredential = 'passwordCredential',
  PasskeyCredential = 'passkeyCredential',
  EquivalentCredentialPicker = 'equivalentCredentialPicker'
}

export interface CredentialProviderCapability {
  route: CredentialProviderRoute;

  probe(): Promise<CapabilityProbeResult>;
}

export class NotConfiguredCredentialProviderCapability implements CredentialProviderCapability {
  route: CredentialProviderRoute = CredentialProviderRoute.PasswordCredential;

  probe(): Promise<CapabilityProbeResult> {
    return Promise.resolve(new CapabilityProbeResult(
      CapabilityStatus.NeedsSpike,
      '凭据获取和第三方 Passkey provider 需要与普通自动填充分开验证。',
      true
    ));
  }
}
