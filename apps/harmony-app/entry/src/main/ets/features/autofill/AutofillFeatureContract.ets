export enum AutofillSurface {
  FillPassword = 'fillPassword',
  SavePassword = 'savePassword',
  UnlockBeforeFill = 'unlockBeforeFill',
  GeneratePassword = 'generatePassword'
}

export class AutofillReleaseRequirement {
  surface: AutofillSurface;
  firstReleaseRequired: boolean;
  message: string;

  constructor(surface: AutofillSurface, firstReleaseRequired: boolean, message: string) {
    this.surface = surface;
    this.firstReleaseRequired = firstReleaseRequired;
    this.message = message;
  }
}

export function getFirstReleaseAutofillRequirements(): AutofillReleaseRequirement[] {
  return [
    new AutofillReleaseRequirement(AutofillSurface.FillPassword, true, '首发必须支持账号密码自动填充。'),
    new AutofillReleaseRequirement(AutofillSurface.SavePassword, true, '保存新密码是对齐 Android 的关键场景。'),
    new AutofillReleaseRequirement(AutofillSurface.UnlockBeforeFill, true, '锁屏后解锁再填充必须走 Root 状态机。'),
    new AutofillReleaseRequirement(AutofillSurface.GeneratePassword, true, '生成密码入口需要与保存流程联动。')
  ];
}
