export enum SpecialCircumstance {
  None = 'none',
  AddTotpLoginItem = 'addTotpLoginItem',
  AutofillRequest = 'autofillRequest',
  PasskeyAssertion = 'passkeyAssertion',
  CredentialRequest = 'credentialRequest',
  AuthRequestApproval = 'authRequestApproval'
}

export class SpecialCircumstanceContext {
  circumstance: SpecialCircumstance;
  source: string;
  payloadSummary: string;

  constructor(circumstance: SpecialCircumstance, source: string, payloadSummary: string) {
    this.circumstance = circumstance;
    this.source = source;
    this.payloadSummary = payloadSummary;
  }
}
