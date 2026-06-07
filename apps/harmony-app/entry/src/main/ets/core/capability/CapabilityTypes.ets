export enum CapabilityStatus {
  Available = 'available',
  NeedsSpike = 'needsSpike',
  Blocked = 'blocked',
  NotConfigured = 'notConfigured'
}

export class CapabilityProbeResult {
  status: CapabilityStatus;
  message: string;
  requiresPrivilegedAccess: boolean;

  constructor(status: CapabilityStatus, message: string, requiresPrivilegedAccess: boolean) {
    this.status = status;
    this.message = message;
    this.requiresPrivilegedAccess = requiresPrivilegedAccess;
  }
}
