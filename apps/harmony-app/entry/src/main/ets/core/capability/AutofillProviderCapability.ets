import { CapabilityProbeResult, CapabilityStatus } from './CapabilityTypes';

export enum AutofillProviderRoute {
  PublicProvider = 'publicProvider',
  PrivilegedProvider = 'privilegedProvider',
  EquivalentIntegration = 'equivalentIntegration'
}

export interface AutofillProviderCapability {
  preferredRoute: AutofillProviderRoute;

  probe(): Promise<CapabilityProbeResult>;
}

export class NotConfiguredAutofillProviderCapability implements AutofillProviderCapability {
  preferredRoute: AutofillProviderRoute = AutofillProviderRoute.PublicProvider;

  probe(): Promise<CapabilityProbeResult> {
    return Promise.resolve(new CapabilityProbeResult(
      CapabilityStatus.NeedsSpike,
      '验证 AutoFillExtensionAbility / autoFill/password 是否允许普通 AppGallery 三方密码管理器接入。',
      true
    ));
  }
}
