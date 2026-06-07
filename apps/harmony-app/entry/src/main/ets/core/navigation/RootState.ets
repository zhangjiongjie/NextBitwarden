export enum RootState {
  Loading = 'loading',
  SignedOut = 'signedOut',
  Locked = 'locked',
  Unlocked = 'unlocked',
  SystemEntry = 'systemEntry'
}

export function rootStateTitle(state: RootState): string {
  switch (state) {
    case RootState.Loading:
      return '正在初始化';
    case RootState.SignedOut:
      return '等待登录';
    case RootState.Locked:
      return '保险库已锁定';
    case RootState.Unlocked:
      return '保险库框架已进入';
    case RootState.SystemEntry:
      return '系统入口处理中';
    default:
      return '未知状态';
  }
}

export function rootStateDescription(state: RootState): string {
  switch (state) {
    case RootState.Loading:
      return '准备 SDK、服务器配置和本地安全能力。';
    case RootState.SignedOut:
      return '一期将接入账号密码、TOTP 二步验证码、设备 Passkey、SSO 和 trusted device。';
    case RootState.Locked:
      return '后续接入 userAuth 与 HUKS，完成锁定和解锁流程。';
    case RootState.Unlocked:
      return '当前只是 UI 和架构骨架，真实保险库数据必须由 Bitwarden SDK bridge 提供。';
    case RootState.SystemEntry:
      return '自动填充、Passkey、凭据获取和 TOTP 外部入口统一回到 Root 状态机。';
    default:
      return '根状态需要保持可观测，避免系统回调散落在页面内。';
  }
}
