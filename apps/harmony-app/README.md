# NextBitwarden HarmonyOS NEXT

这是 NextBitwarden 的 HarmonyOS NEXT 原生客户端工程。当前阶段只落地一期架构骨架，不包含真实账号登录、保险库解密、自动填充 provider 或 Passkey provider 实现。

## 当前范围

- `entry`：主应用入口，承载 Password Manager 一期能力。
- `core/navigation`：根状态和外部入口模型，对齐 Android 的 Root Nav 思路。
- `core/capability`：系统能力抽象，包括自动填充、凭据获取、Passkey、生物识别和推送同步。
- `core/sdk`：Bitwarden internal SDK 接入边界，先定义 client 生命周期和 repository bridge。
- `features`：Auth、Vault、Autofill、Passkey、Settings 的一期功能契约、首批状态模型和 Auth / Vault mock repository。
- 首批 UI 状态流：登录、解锁、保险库首页、两步验证码、系统集成和设置概览。
- `ohosTest`：首批 Hypium 测试入口，当前覆盖 App 级 reducer、Auth / Vault 状态机和 Auth / Vault mock repository。

## 签名策略

仓库不提交任何本机签名材料、证书路径或加密口令。需要真机调试时，在 DevEco Studio 中生成本地调试签名，或在本机临时补充 `build-profile.json5` 的 signingConfig 后再构建。

## 当前验证状态

- 已创建 HarmonyOS NEXT Stage 模型工程骨架。
- 已建立 Root 状态、Capability、SDK Bridge 和一期 Feature Contract。
- 已加入首批 Password Manager UI 状态流，用于承接后续真实 Auth / Vault / Autofill / Passkey 实现。
- 已引入 `AppStateReducer`，将 AppShell 的页面跳转改为 `state-action` 驱动，并用 ohosTest 编译验证 reducer 测试。
- 已引入 `AuthStateMachine` 和 `VaultStateMachine`，登录页开始通过 Auth 状态机做邮箱校验与登录事件分发，保险库首页开始通过 Vault 状态机派发 TOTP 验证码和系统集成入口事件。
- 已引入 `PreviewAuthRepository`，登录页展示首发登录能力边界，解锁页通过 mock repository 表达“主密码后需要 TOTP 二步验证码”，不伪装真实解密或直接完成登录。
- 已引入 `PreviewVaultRepository`，保险库首页和两步验证码页已从 mock repository 获取摘要、条目和 TOTP 占位数据，为后续替换成 Bitwarden SDK / repository bridge 预留数据边界。
- `ohpm install --all` 已通过。
- `hvigorw.bat --mode project assembleApp --no-daemon --stacktrace` 已通过，当前仅提示 `No signingConfig found for product default`。这符合仓库不提交签名材料的策略，后续真机安装前再补本地调试签名。
- `hvigorw.bat --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace` 已通过，当前只验证测试 HAP 可编译；运行 Hypium 测试仍需要连接设备或模拟器。
