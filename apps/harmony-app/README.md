# NextBitwarden HarmonyOS NEXT

这是 NextBitwarden 的 HarmonyOS NEXT 原生客户端工程。当前阶段只落地一期架构骨架，不包含真实账号登录、保险库解密、自动填充 provider 或 Passkey provider 实现。

## 当前范围

- `entry`：主应用入口，承载 Password Manager 一期能力。
- `core/navigation`：根状态和外部入口模型，对齐 Android 的 Root Nav 思路。
- `core/capability`：系统能力抽象，包括自动填充、凭据获取、Passkey、生物识别和推送同步。
- `core/sdk`：Bitwarden internal SDK 接入边界，先定义 client 生命周期和 repository bridge。
- `features`：Auth、Vault、Autofill、Passkey、Settings 的一期功能契约、首批状态模型、Auth / Vault mock repository、系统集成 readiness repository 和设置策略 repository。
- 首批 UI 状态流：登录、设备 Passkey、登录审批、企业 SSO、自托管服务器配置、解锁、生物识别解锁、TOTP 登录挑战、保险库首页、条目详情、添加 TOTP、两步验证码、系统集成和设置概览。
- `ohosTest`：首批 Hypium 测试入口，当前覆盖 App 级 reducer、Auth / Vault 状态机、Auth / Vault mock repository、TOTP setup repository、设备 Passkey login repository、trusted device approval repository、生物识别 unlock repository、SSO WebAuth repository、ServerConfig repository、系统集成 readiness repository 和设置策略 repository。

## 签名策略

仓库不提交任何本机签名材料、证书路径或加密口令。需要真机调试时，在 DevEco Studio 中生成本地调试签名，或在本机临时补充 `build-profile.json5` 的 signingConfig 后再构建。

## 当前验证状态

- 已创建 HarmonyOS NEXT Stage 模型工程骨架。
- 已建立 Root 状态、Capability、SDK Bridge 和一期 Feature Contract。
- 已加入首批 Password Manager UI 状态流，用于承接后续真实 Auth / Vault / Autofill / Passkey 实现。
- 已引入 `AppStateReducer`，将 AppShell 的页面跳转改为 `state-action` 驱动，并用 ohosTest 编译验证 reducer 测试。
- 已引入 `AuthStateMachine` 和 `VaultStateMachine`，登录页开始通过 Auth 状态机做邮箱校验与登录事件分发，保险库首页开始通过 Vault 状态机派发 TOTP 验证码和系统集成入口事件。
- 已引入 `PreviewAuthRepository`，登录页展示首发登录能力边界，解锁页通过 mock repository 表达“主密码后需要 TOTP 二步验证码”，不伪装真实解密或直接完成登录。
- 已引入 `PreviewDevicePasskeyLoginRepository` 和 `DevicePasskeyLoginScreen`，设备 Passkey 入口进入独立能力页，表达一期只接设备内置 Passkey 登录，不接 NFC、YubiKey 或漫游认证器。
- 已引入 `PreviewTrustedDeviceApprovalRepository` 和 `TrustedDeviceApprovalScreen`，trusted device 入口进入独立登录审批页，明确 Push Kit 是优先路径，前台刷新和手动刷新是首发 fallback。
- 已引入 `PreviewBiometricUnlockRepository` 和 `BiometricUnlockScreen`，保险库解锁页的生物识别入口进入独立能力页，明确区分 userAuth 用户认证和 HUKS 保险库密钥保护，不把按钮直接伪装成完整解密。
- 已引入 `PreviewSsoWebAuthRepository` 和 `SsoWebAuthScreen`，企业 SSO 入口进入独立 WebAuth 页面，支持组织标识校验、preview launch URL 和 `WaitingForBrowser` 状态，为后续真实浏览器授权与 SDK 回调预留边界。
- 已引入 `PreviewServerConfigRepository` 和 `ServerConfigScreen`，自托管入口进入独立配置页，支持 HTTPS base URL 的 preview 校验和 endpoint 派生，为后续 SDK ServerCommunicationConfigRepository 持久化预留边界。
- 已引入 `TotpLoginChallengeScreen`，主密码 preview 成功后先进入 TOTP 二步验证码挑战页，再由 mock repository 进入保险库，避免把主密码解锁误写成完整登录。
- 已引入 `PreviewVaultRepository`，保险库首页、条目详情和两步验证码页已从 mock repository 获取摘要、条目、详情和 TOTP 占位数据，为后续替换成 Bitwarden SDK / repository bridge 预留数据边界。
- 已引入 `VaultItemDetailScreen`，保险库列表点击条目可进入详情页，详情页只展示安全 preview，密码保持隐藏，避免在真实 SDK 解密前暴露敏感字段。
- 已引入 `PreviewTotpSetupRepository` 和 `TotpSetupScreen`，保险库验证码卡片提供添加 TOTP 入口，支持 `otpauth://totp` URI preview 解析和手动录入 preview，不伪装真实保险库存储或 TOTP 计算。
- 已引入 `PreviewSystemIntegrationRepository`，系统集成页从 readiness repository 读取自动填充、凭据获取、设备 Passkey、生物识别和推送同步状态，明确区分 `NeedsSpike` 和 `Available`。
- 已引入 `PreviewSettingsRepository`，设置页从策略 repository 读取 Premium Web 开放、自托管、安全策略、企业加密、mTLS 预留和 Authenticator 扩展边界，不在 UI 层硬编码产品策略。
- `ohpm install --all` 已通过。
- `hvigorw.bat --mode project assembleApp --no-daemon --stacktrace` 已通过，当前仅提示 `No signingConfig found for product default`。这符合仓库不提交签名材料的策略，后续真机安装前再补本地调试签名。
- `hvigorw.bat --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace` 已通过，当前只验证测试 HAP 可编译；运行 Hypium 测试仍需要连接设备或模拟器。
