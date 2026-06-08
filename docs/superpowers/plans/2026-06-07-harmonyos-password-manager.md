# HarmonyOS Password Manager 实现计划

> **面向 AI 代理的工作者：** 必需子技能：使用 superpowers:subagent-driven-development（推荐）或 superpowers:executing-plans 逐任务实现此计划。步骤使用复选框（`- [ ]`）语法来跟踪进度。

**目标：** 按 `docs/harmonyos-porting-notes.md` 的一期范围开发 HarmonyOS NEXT 原生 Password Manager，功能尽量对齐 Bitwarden Android 主应用，UI 尽量相似。

**架构：** 一期采用单 `entry` 模块启动，先建立 Root 状态机、Feature Contract、系统能力 Capability 和 Bitwarden SDK Bridge 四层边界。系统集成能力（自动填充、Passkey、凭据获取、生物识别、推送同步）全部通过 Capability 接口接入，避免业务层直接依赖 HarmonyOS API。SDK 侧优先按源码或 native bridge 接入准备，应用层只依赖 `SdkClientManager` 和 `SdkRepositoryBridge`。

**技术栈：** HarmonyOS NEXT、ArkTS、ArkUI、Stage Model、Ability Kit、HUKS / userAuth / AutoFill / FIDO2 Capability 适配层、Bitwarden internal SDK bridge。

---

## 文件结构

- 创建：`apps/harmony-app/README.md`，说明 Harmony 工程定位、调试签名策略和首批边界。
- 创建：`apps/harmony-app/build-profile.json5`，定义 HarmonyOS NEXT 默认产品，不提交签名材料。
- 创建：`apps/harmony-app/AppScope/app.json5`，定义 `com.zhangjiongjie.nextbitwarden` 应用信息。
- 创建：`apps/harmony-app/entry/src/main/module.json5`，定义 `EntryAbility`、页面入口和一期基础权限。
- 创建：`apps/harmony-app/entry/src/main/ets/entryability/EntryAbility.ets`，加载 ArkUI 页面并保留生命周期入口。
- 创建：`apps/harmony-app/entry/src/main/ets/pages/Index.ets`，应用首屏入口。
- 创建：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`，承载根状态和首批开发里程碑。
- 创建：`apps/harmony-app/entry/src/main/ets/core/navigation/*.ets`，定义 Root 状态和外部特殊入口。
- 创建：`apps/harmony-app/entry/src/main/ets/core/capability/*.ets`，定义系统能力抽象。
- 创建：`apps/harmony-app/entry/src/main/ets/core/sdk/*.ets`，定义 SDK 客户端与 repository bridge。
- 创建：`apps/harmony-app/entry/src/main/ets/features/**/*.ets`，定义 Auth、Vault、Autofill、Passkey、Settings 的一期 Contract。
- 修改：`.gitignore`，继续忽略 `android/`，并忽略 Harmony 构建输出和依赖目录。

## 任务 1：建立 HarmonyOS NEXT 工程骨架

**文件：**
- 创建：`apps/harmony-app/oh-package.json5`
- 创建：`apps/harmony-app/hvigorfile.ts`
- 创建：`apps/harmony-app/hvigor/hvigor-config.json5`
- 创建：`apps/harmony-app/build-profile.json5`
- 创建：`apps/harmony-app/AppScope/app.json5`
- 创建：`apps/harmony-app/AppScope/resources/base/element/string.json`
- 创建：`apps/harmony-app/AppScope/resources/zh_CN/element/string.json`
- 创建：`apps/harmony-app/AppScope/resources/base/media/app_icon.svg`
- 创建：`apps/harmony-app/entry/build-profile.json5`
- 创建：`apps/harmony-app/entry/hvigorfile.ts`
- 创建：`apps/harmony-app/entry/oh-package.json5`
- 创建：`apps/harmony-app/entry/src/main/module.json5`
- 创建：`apps/harmony-app/entry/src/main/resources/base/profile/main_pages.json`
- 创建：`apps/harmony-app/entry/src/main/resources/base/element/string.json`
- 创建：`apps/harmony-app/entry/src/main/resources/base/element/color.json`
- 创建：`apps/harmony-app/entry/src/main/resources/zh_CN/element/string.json`
- 修改：`.gitignore`

- [ ] **步骤 1：创建无签名材料的默认产品配置**

```json5
{
  "app": {
    "signingConfigs": [],
    "products": [
      {
        "name": "default",
        "compatibleSdkVersion": "6.0.2(22)",
        "targetSdkVersion": "6.0.2(22)",
        "runtimeOS": "HarmonyOS"
      }
    ],
    "buildModeSet": [
      {
        "name": "debug"
      },
      {
        "name": "release"
      }
    ],
    "modules": [
      {
        "name": "entry",
        "srcPath": "./entry",
        "targets": [
          {
            "name": "default",
            "applyToProducts": ["default"]
          }
        ]
      }
    ]
  }
}
```

- [ ] **步骤 2：创建入口模块清单**

```json5
{
  "module": {
    "name": "entry",
    "type": "entry",
    "description": "$string:module_desc",
    "mainElement": "EntryAbility",
    "deviceTypes": ["phone", "tablet"],
    "deliveryWithInstall": true,
    "installationFree": false,
    "pages": "$profile:main_pages",
    "requestPermissions": [
      {
        "name": "ohos.permission.INTERNET"
      },
      {
        "name": "ohos.permission.ACCESS_BIOMETRIC"
      }
    ],
    "abilities": [
      {
        "name": "EntryAbility",
        "srcEntry": "./ets/entryability/EntryAbility.ets",
        "description": "$string:EntryAbility_desc",
        "icon": "$media:app_icon",
        "label": "$string:EntryAbility_label",
        "startWindowIcon": "$media:app_icon",
        "startWindowBackground": "$color:start_window_background",
        "exported": true,
        "skills": [
          {
            "entities": ["entity.system.home"],
            "actions": ["ohos.want.action.home"]
          }
        ]
      }
    ]
  }
}
```

- [ ] **步骤 3：运行结构验证**

运行：`Test-Path .\apps\harmony-app\entry\src\main\module.json5`

预期：输出 `True`。

- [ ] **步骤 4：Commit**

```bash
git add .gitignore apps/harmony-app
git commit -m "feat(鸿蒙): 初始化 HarmonyOS NEXT 工程骨架"
```

## 任务 2：建立 Root 状态和外部入口模型

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/core/navigation/RootState.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/navigation/SpecialCircumstance.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/entryability/EntryAbility.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/pages/Index.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`

- [ ] **步骤 1：定义 Root 状态**

```typescript
export enum RootState {
  Loading = 'loading',
  SignedOut = 'signedOut',
  Locked = 'locked',
  Unlocked = 'unlocked',
  SystemEntry = 'systemEntry'
}
```

- [ ] **步骤 2：定义 Android 特殊入口的 Harmony 映射**

```typescript
export enum SpecialCircumstance {
  None = 'none',
  AddTotpLoginItem = 'addTotpLoginItem',
  AutofillRequest = 'autofillRequest',
  PasskeyAssertion = 'passkeyAssertion',
  CredentialRequest = 'credentialRequest',
  AuthRequestApproval = 'authRequestApproval'
}
```

- [ ] **步骤 3：创建可进入的 ArkUI 首屏**

```typescript
import { AppShell } from '../app/AppShell';

@Entry
@Component
struct Index {
  build() {
    AppShell();
  }
}
```

- [ ] **步骤 4：运行源码存在性验证**

运行：`rg "RootState|SpecialCircumstance|AppShell" .\apps\harmony-app\entry\src\main\ets`

预期：能命中 Root 状态、特殊入口和首屏引用。

- [ ] **步骤 5：Commit**

```bash
git add apps/harmony-app/entry/src/main/ets
git commit -m "feat(鸿蒙): 建立根状态和入口模型"
```

## 任务 3：建立系统能力 Capability 边界

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/core/capability/CapabilityTypes.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/capability/AutofillProviderCapability.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/capability/CredentialProviderCapability.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/capability/PlatformPasskeyCapability.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/capability/BiometricVaultUnlockCapability.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/capability/PushSyncCapability.ets`

- [ ] **步骤 1：定义统一探测结果**

```typescript
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
```

- [ ] **步骤 2：自动填充优先按 provider 路径抽象**

```typescript
export enum AutofillProviderRoute {
  PublicProvider = 'publicProvider',
  PrivilegedProvider = 'privilegedProvider',
  EquivalentIntegration = 'equivalentIntegration'
}

export interface AutofillProviderCapability {
  preferredRoute: AutofillProviderRoute;
  probe(): Promise<CapabilityProbeResult>;
}
```

- [ ] **步骤 3：Passkey 和 Credential Provider 分开建模**

```typescript
export enum PlatformPasskeyRole {
  ClientLogin = 'clientLogin',
  ThirdPartyProvider = 'thirdPartyProvider'
}

export enum CredentialProviderRoute {
  PasswordCredential = 'passwordCredential',
  PasskeyCredential = 'passkeyCredential',
  EquivalentCredentialPicker = 'equivalentCredentialPicker'
}
```

- [ ] **步骤 4：运行边界扫描**

运行：`rg "Capability|AutofillProviderRoute|PlatformPasskeyRole|CredentialProviderRoute" .\apps\harmony-app\entry\src\main\ets\core`

预期：能命中所有 Capability 文件。

- [ ] **步骤 5：Commit**

```bash
git add apps/harmony-app/entry/src/main/ets/core/capability
git commit -m "feat(鸿蒙): 定义系统能力适配边界"
```

## 任务 4：建立 Bitwarden SDK Bridge 边界

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/core/sdk/SdkClientManager.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/sdk/SdkRepositoryBridge.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/sdk/ServerConfigBridge.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/core/sdk/SsoWebAuthCapability.ets`

- [ ] **步骤 1：定义 SDK client 生命周期**

```typescript
export enum SdkBridgeMode {
  Source = 'source',
  NativeBinding = 'nativeBinding',
  Mock = 'mock'
}

export class SdkClientManager {
  private bridgeMode: SdkBridgeMode;
  private verifiedSdkVersion: string;

  constructor(bridgeMode: SdkBridgeMode, verifiedSdkVersion: string) {
    this.bridgeMode = bridgeMode;
    this.verifiedSdkVersion = verifiedSdkVersion;
  }
}
```

- [ ] **步骤 2：定义 repository bridge 责任边界**

```typescript
export enum RepositoryBridgeArea {
  Auth = 'auth',
  Vault = 'vault',
  OrganizationCrypto = 'organizationCrypto',
  KeyConnector = 'keyConnector'
}
```

- [ ] **步骤 3：定义自托管和 SSO 配置入口**

```typescript
export enum ServerEnvironment {
  BitwardenCom = 'bitwardenCom',
  SelfHosted = 'selfHosted'
}

export enum SsoWebAuthStatus {
  NotStarted = 'notStarted',
  WaitingForBrowser = 'waitingForBrowser',
  Completed = 'completed',
  Failed = 'failed'
}
```

- [ ] **步骤 4：运行 SDK 边界扫描**

运行：`rg "SdkClientManager|RepositoryBridgeArea|ServerEnvironment|SsoWebAuthStatus" .\apps\harmony-app\entry\src\main\ets\core\sdk`

预期：能命中所有 SDK Bridge 文件。

- [ ] **步骤 5：Commit**

```bash
git add apps/harmony-app/entry/src/main/ets/core/sdk
git commit -m "feat(鸿蒙): 定义 Bitwarden SDK 桥接边界"
```

## 任务 5：建立一期 Feature Contract

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/AuthFeatureContract.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/vault/VaultFeatureContract.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/autofill/AutofillFeatureContract.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/passkey/PasskeyFeatureContract.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/settings/SettingsFeatureContract.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/platform/InitialMilestones.ets`

- [ ] **步骤 1：Auth Contract 必须覆盖登录首发范围**

```typescript
export enum AuthEntryPoint {
  Password = 'password',
  TotpSecondFactor = 'totpSecondFactor',
  DevicePasskey = 'devicePasskey',
  Sso = 'sso',
  TrustedDevice = 'trustedDevice'
}
```

- [ ] **步骤 2：Vault Contract 必须覆盖主保险库和 TOTP**

```typescript
export enum VaultSurface {
  ItemList = 'itemList',
  ItemDetail = 'itemDetail',
  AddEditLogin = 'addEditLogin',
  VerificationCode = 'verificationCode',
  Send = 'send'
}
```

- [ ] **步骤 3：系统集成 Contract 必须覆盖自动填充和凭据获取**

```typescript
export enum AutofillSurface {
  FillPassword = 'fillPassword',
  SavePassword = 'savePassword',
  UnlockBeforeFill = 'unlockBeforeFill',
  GeneratePassword = 'generatePassword'
}

export enum PasskeySurface {
  DeviceLogin = 'deviceLogin',
  AssertionForOtherApp = 'assertionForOtherApp',
  RegistrationForOtherApp = 'registrationForOtherApp'
}
```

- [ ] **步骤 4：在首屏展示里程碑**

运行：`rg "首发|自动填充|Passkey|TOTP|Bitwarden SDK" .\apps\harmony-app\entry\src\main\ets\features\platform\InitialMilestones.ets`

预期：能命中一期关键能力。

- [ ] **步骤 5：Commit**

```bash
git add apps/harmony-app/entry/src/main/ets/features
git commit -m "feat(鸿蒙): 建立一期功能契约"
```

## 任务 6：编译和验证

**文件：**
- 修改：`apps/harmony-app/README.md`

- [ ] **步骤 1：安装依赖**

运行：`ohpm install --all`

预期：生成或更新 `oh_modules`，该目录被 `.gitignore` 忽略。

- [ ] **步骤 2：执行 Harmony 构建**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode project assembleApp --no-daemon --stacktrace`

预期：输出 `BUILD SUCCESSFUL`。未配置签名时允许出现 `No signingConfig found for product default` 警告，但不应出现 ArkTS 语法错误、资源错误或 module 清单错误。

- [ ] **步骤 3：执行静态验证**

运行：`git diff --check`

预期：无输出，退出码为 0。

- [ ] **步骤 4：记录验证结果**

将实际构建结果写入 `apps/harmony-app/README.md` 的「当前验证状态」小节。若后续真机安装被签名阻塞，记录为「签名配置缺失」，不要把它写成 ArkTS 失败。

- [ ] **步骤 5：Commit**

```bash
git add apps/harmony-app/README.md
git commit -m "docs(鸿蒙): 记录初始工程验证状态"
```

## 任务 7：首批 Password Manager UI 状态流

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/core/navigation/AppDestination.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppTheme.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/AuthLandingScreen.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/VaultUnlockScreen.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/vault/VaultHomeScreen.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/vault/VerificationCodesScreen.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/platform/SystemIntegrationScreen.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/settings/SettingsOverviewScreen.ets`

- [x] **步骤 1：建立应用内目的地**

```typescript
export enum AppDestination {
  SignIn = 'signIn',
  Unlock = 'unlock',
  Vault = 'vault',
  VerificationCodes = 'verificationCodes',
  SystemIntegrations = 'systemIntegrations',
  Settings = 'settings'
}
```

- [x] **步骤 2：将 AppShell 从工程控制台改为主应用状态流**

`AppShell` 现在承载顶部栏、Root 状态提示、滚动内容区和底部导航，并能在登录、解锁、保险库、验证码、系统集成和设置之间切换。

- [x] **步骤 3：建立首批页面骨架**

首批页面覆盖：

- 登录：账号密码、设备 Passkey、企业 SSO、自托管入口。
- 解锁：主密码、生物识别解锁入口。
- 保险库：首页摘要、TOTP 入口、收藏和类型列表。
- 验证码：主应用内两步验证码展示页，占位码明确标注为 UI 骨架。
- 系统集成：自动填充、凭据获取、Passkey、生物识别、推送同步能力清单。
- 设置：Premium 开放、自托管、安全策略、企业能力概览。

- [x] **步骤 4：运行构建验证**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode project assembleApp --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 8：App 级 `state-action` reducer

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/app/state/AppStateReducer.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/module.json5`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/AppStateReducer.test.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/testability/TestAbility.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/testrunner/OpenHarmonyTestRunner.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/resources/**`

- [x] **步骤 1：先写 reducer 测试**

测试覆盖：

- 账号密码登录进入 `Locked / Unlock`。
- 解锁成功进入 `Unlocked / Vault`。
- 系统集成入口进入 `SystemEntry / SystemIntegrations`。
- 返回登录进入 `SignedOut / SignIn`。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为 `Cannot find module '../../../main/ets/app/state/AppStateReducer'`，证明测试正在约束尚未实现的 reducer。

- [x] **步骤 3：实现最小 reducer**

`AppStateReducer` 定义 `AppState`、`AppAction`、`createInitialAppState()` 和 `reduce()`，并让 `AppShell` 的跳转统一通过 `dispatch(AppAction)` 完成。

- [x] **步骤 4：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

说明：当前命令证明测试 HAP 可编译；真正执行 Hypium 测试需要连接 HarmonyOS 设备或模拟器。

## 任务 9：Auth / Vault feature 级状态模型

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/state/AuthStateMachine.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/vault/state/VaultStateMachine.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/AuthStateMachine.test.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/VaultStateMachine.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/auth/AuthLandingScreen.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/vault/VaultHomeScreen.ets`

- [x] **步骤 1：先写 Auth / Vault 状态机测试**

测试覆盖：

- Auth 邮箱输入会更新登录视图状态。
- 账号密码登录在缺少邮箱时停留在邮箱输入状态，并产生校验事件。
- 账号密码登录在已有邮箱时进入主密码解锁事件。
- 设备内置 Passkey 登录会产生独立 capability 启动事件。
- Vault 首页可以进入两步验证码页面。
- 两步验证码页面可以回到保险库列表。
- Vault 首页可以进入系统集成状态面板。
- 锁定请求会显式标记 `lockRequested`，不伪装保险库仍处于可用状态。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为找不到 `features/auth/state/AuthStateMachine` 和 `features/vault/state/VaultStateMachine`，证明测试正在约束尚未实现的 feature 状态模型。

- [x] **步骤 3：实现最小状态模型**

`AuthStateMachine` 定义 `AuthViewState / AuthAction / AuthEventKind / AuthTransition`，覆盖邮箱校验、账号密码登录、设备 Passkey、SSO、自托管配置和 TOTP 提交事件。

`VaultStateMachine` 定义 `VaultViewState / VaultAction / VaultEventKind / VaultTransition`，覆盖保险库列表、条目详情、两步验证码、系统集成和锁定请求。

- [x] **步骤 4：接入首批页面**

`AuthLandingScreen` 现在使用 Auth 状态机驱动邮箱输入、校验提示和登录入口事件；`VaultHomeScreen` 使用 Vault 状态机驱动两步验证码和系统集成入口事件。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode project assembleApp --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 10：Vault domain 与 mock repository 数据边界

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/features/vault/data/VaultRepository.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/VaultRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/vault/VaultHomeScreen.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/vault/VerificationCodesScreen.ets`

- [x] **步骤 1：先写 Vault repository 测试**

测试覆盖：

- 保险库摘要必须由 seeded login / TOTP 条目计算。
- Vault 列表条目必须保留类型、收藏和 TOTP 标记，方便后续映射 SDK 数据模型。
- 两步验证码列表只能来自带 TOTP 的登录项。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为找不到 `features/vault/data/VaultRepository`，证明测试正在约束尚未实现的 Vault 数据边界。

- [x] **步骤 3：实现最小 mock repository**

`VaultRepository.ets` 定义：

- `VaultItemType`
- `VaultSummary`
- `VaultListItem`
- `VerificationCodeItem`
- `VaultHomeViewState`
- `VaultRepository`
- `PreviewVaultRepository`

当前 repository 只提供 mock 数据，不做真实同步、解密、TOTP 计算或 SDK 调用。

- [x] **步骤 4：接入首批 Vault 页面**

`VaultHomeScreen` 现在从 `PreviewVaultRepository` 读取摘要和条目列表；`VerificationCodesScreen` 从同一 repository 读取带 TOTP 的登录项并生成占位验证码列表。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 11：Auth domain 与 mock repository 数据边界

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/data/AuthRepository.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/AuthRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/auth/AuthLandingScreen.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/auth/VaultUnlockScreen.ets`

- [x] **步骤 1：先写 Auth repository 测试**

测试覆盖：

- 首发登录方式必须按稳定顺序暴露：主密码、TOTP 二步验证码、设备 Passkey、SSO、trusted device。
- 账号密码登录必须先校验邮箱，缺少邮箱时返回 validation error。
- 主密码解锁的 preview 结果必须进入 `WaitingForTotp`，并返回“需要 TOTP 两步验证码”。
- 设备 Passkey 登录必须走独立 capability 启动阶段。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为找不到 `features/auth/data/AuthRepository`，证明测试正在约束尚未实现的 Auth 数据边界。

- [x] **步骤 3：实现最小 mock repository**

`AuthRepository.ets` 定义：

- `AuthMethod`
- `AuthFlowStage`
- `AuthOperationStatus`
- `AuthMethodDescriptor`
- `AuthSessionPreview`
- `AuthRepository`
- `PreviewAuthRepository`

当前 repository 只表达登录流程边界，不做真实账号登录、主密码校验、保险库解密、Passkey 调用或 TOTP 校验。

- [x] **步骤 4：接入首批 Auth 页面**

`AuthLandingScreen` 现在从 `PreviewAuthRepository` 展示首发登录能力边界；`VaultUnlockScreen` 使用 repository 处理主密码空值校验，并在主密码后停留到 TOTP 二步验证码边界，不直接伪装登录完成。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode project assembleApp --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 12：系统集成 readiness 数据边界

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/features/platform/data/SystemIntegrationRepository.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/SystemIntegrationRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/platform/SystemIntegrationScreen.ets`

- [x] **步骤 1：先写系统集成 readiness 测试**

测试覆盖：

- 系统集成首发清单必须按稳定顺序暴露：自动填充 provider、凭据 provider、设备 Passkey 登录、生物识别、推送同步。
- 自动填充 provider 必须标记为 `NeedsSpike`，并保留 `autoFill/password provider` 路线。
- 凭据 provider 必须与自动填充 provider 分开建模，不能混为一条能力。
- 推送同步 fallback 必须标记为 `Available`，且不需要特权访问。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为找不到 `features/platform/data/SystemIntegrationRepository`，证明测试正在约束尚未实现的系统集成数据边界。

- [x] **步骤 3：实现最小 readiness repository**

`SystemIntegrationRepository.ets` 定义：

- `SystemIntegrationArea`
- `SystemIntegrationReadiness`
- `SystemIntegrationRepository`
- `PreviewSystemIntegrationRepository`

当前 repository 只表达系统集成 readiness，不调用真实 AutoFill、Credential Provider、Passkey、userAuth、HUKS 或 Push Kit API。

- [x] **步骤 4：接入系统集成页**

`SystemIntegrationScreen` 现在从 `PreviewSystemIntegrationRepository` 读取 readiness 列表，并基于 `requiresPrivilegedAccess` 展示高风险能力提示。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode project assembleApp --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 13：Settings policy 数据边界

**文件：**
- 创建：`apps/harmony-app/entry/src/main/ets/features/settings/data/SettingsRepository.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/SettingsRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/settings/SettingsOverviewScreen.ets`
- 修改：`apps/harmony-app/README.md`

- [x] **步骤 1：先写 Settings repository 测试**

测试覆盖：

- `Premium / 订阅` 一期统一走 Web 开放。
- 应用端不启用应用内购买，也不启用本地功能门禁。
- 设置策略按稳定顺序暴露：Premium、自托管、安全策略、企业加密、企业证书 / mTLS、独立 Authenticator / Bridge 扩展边界。
- `key connector` 所在的企业加密能力仍是一期开工项，但标记为高风险。
- 企业证书 / `mTLS` 和独立 `Authenticator / Bridge` 都是预留边界，不是一期开工项。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为找不到 `features/settings/data/SettingsRepository`，证明测试正在约束尚未实现的 Settings 数据边界。

- [x] **步骤 3：实现最小 settings policy repository**

`SettingsRepository.ets` 定义：

- `PremiumAccessMode`
- `SettingsPolicyArea`
- `PremiumAccessPolicy`
- `SettingsPolicyItem`
- `SettingsRepository`
- `PreviewSettingsRepository`

当前 repository 只表达已确认的产品策略和扩展边界，不做真实订阅查询、购买、企业证书、mTLS、key connector 或独立 Authenticator 实现。

- [x] **步骤 4：接入设置页**

`SettingsOverviewScreen` 现在从 `PreviewSettingsRepository` 读取策略清单，并用标签区分 Web 开放、首发必做、首发高风险和预留项。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 14：TOTP 登录挑战页和导航边界

**文件：**
- 修改：`apps/harmony-app/entry/src/main/ets/core/navigation/AppDestination.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/state/AppStateReducer.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/auth/data/AuthRepository.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/auth/VaultUnlockScreen.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/TotpLoginChallengeScreen.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AppStateReducer.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AuthRepository.test.ets`
- 修改：`apps/harmony-app/README.md`

- [x] **步骤 1：先写 App / Auth 红灯测试**

测试覆盖：

- 主密码 preview 成功后不能直接进入保险库，必须先进入 `TotpChallenge`。
- TOTP 挑战成功后才进入 `Unlocked / Vault`。
- 空 TOTP 码返回 validation error，并停留在 `WaitingForTotp`。
- 非空 TOTP 码在 preview repository 中进入 `VaultUnlocked`。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为缺少 `AppAction.MasterPasswordRequiresTotp`、`AppAction.TotpSucceeded`、`AppDestination.TotpChallenge` 和 `submitTotpSecondFactor()`，证明测试正在约束尚未实现的 TOTP 登录挑战边界。

- [x] **步骤 3：实现最小 TOTP 登录挑战边界**

本轮新增 / 调整：

- `AppDestination.TotpChallenge`
- `AppAction.MasterPasswordRequiresTotp`
- `AppAction.TotpSucceeded`
- `PreviewAuthRepository.submitTotpSecondFactor()`
- `TotpLoginChallengeScreen`

当前仍是 preview repository，不做真实 TOTP 校验、服务器登录挑战或保险库解密。后续真实实现必须由 Bitwarden SDK Auth bridge 接管。

- [x] **步骤 4：接入解锁页和 AppShell**

`VaultUnlockScreen` 在主密码 preview 成功后派发 `onTotpRequired`，`AppShell` 进入 `TotpLoginChallengeScreen`；验证码提交成功后才派发 `TotpSucceeded` 进入保险库。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 15：自托管服务器配置页和数据边界

**文件：**
- 修改：`apps/harmony-app/entry/src/main/ets/core/sdk/ServerConfigBridge.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/core/navigation/AppDestination.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/state/AppStateReducer.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/settings/data/ServerConfigRepository.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/settings/ServerConfigScreen.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/ServerConfigRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AppStateReducer.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/README.md`

- [x] **步骤 1：先写自托管配置红灯测试**

测试覆盖：

- `SelfHostedRequested` 必须进入独立 `ServerConfig` 目的地，不再复用设置概览页。
- 默认服务器配置仍是 Bitwarden cloud。
- 自托管 base URL 可以派生 `identity / api / icons` endpoint。
- 空地址和非 HTTPS 地址必须返回明确 validation 状态与中文提示。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为缺少 `AppDestination.ServerConfig` 和 `features/settings/data/ServerConfigRepository`，证明测试正在约束尚未实现的自托管配置边界。

- [x] **步骤 3：实现最小 ServerConfig repository**

本轮新增 / 调整：

- `ServerConfigBridge.createSelfHosted()`
- `ServerConfigValidationStatus`
- `ServerConfigSaveResult`
- `ServerConfigRepository`
- `PreviewServerConfigRepository`

当前只做 preview 校验和 endpoint 派生，不做真实持久化、网络切换、SSO Cookie 或 SDK client 重建。

- [x] **步骤 4：接入独立配置页**

`AuthLandingScreen` 的“自托管”入口现在通过 `SelfHostedRequested` 进入 `ServerConfigScreen`；页面保存成功后返回登录页，为后续真实 SDK 配置落盘和 client lifecycle 重建预留接线点。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 16：企业 SSO WebAuth 页面和数据边界

**文件：**
- 修改：`apps/harmony-app/entry/src/main/ets/core/navigation/AppDestination.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/state/AppStateReducer.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/data/SsoWebAuthRepository.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/SsoWebAuthScreen.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/SsoWebAuthRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AppStateReducer.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/README.md`

- [x] **步骤 1：先写 SSO WebAuth 红灯测试**

测试覆盖：

- `SsoRequested` 必须进入独立 `SsoWebAuth` 目的地，不再复用设置概览页。
- 组织标识为空时返回 validation 状态和中文提示。
- 组织标识有效时生成等待浏览器的 `SsoWebAuthSession`。
- preview launch URL 必须包含组织标识，为后续真实浏览器授权入口预留形态。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为缺少 `AppDestination.SsoWebAuth` 和 `features/auth/data/SsoWebAuthRepository`，证明测试正在约束尚未实现的企业 SSO WebAuth 边界。

- [x] **步骤 3：实现最小 SSO WebAuth repository**

本轮新增：

- `SsoWebAuthStartStatus`
- `SsoWebAuthStartResult`
- `SsoWebAuthRepository`
- `PreviewSsoWebAuthRepository`

当前只做组织标识校验、preview launch URL 生成和 `WaitingForBrowser` 状态，不启动真实浏览器、不处理 Cookie、token、回调 scheme 或 SDK auth session。

- [x] **步骤 4：接入独立 SSO 页面**

`AuthLandingScreen` 的“企业 SSO”入口现在通过 `SsoRequested` 进入 `SsoWebAuthScreen`；页面展示组织标识输入、浏览器授权准备状态和返回登录入口。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 17：设备内置 Passkey 登录页面和数据边界

**文件：**
- 修改：`apps/harmony-app/entry/src/main/ets/core/navigation/AppDestination.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/state/AppStateReducer.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/data/DevicePasskeyLoginRepository.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/DevicePasskeyLoginScreen.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/DevicePasskeyLoginRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AppStateReducer.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/README.md`

- [x] **步骤 1：先写设备 Passkey 红灯测试**

测试覆盖：

- `DevicePasskeyRequested` 必须进入独立 `DevicePasskeyLogin` 目的地，不能在登录页点击后直接进入保险库。
- Passkey login session 必须声明 `PlatformPasskeyRole.ClientLogin`。
- 一期 preview session 必须明确不需要外部认证器。
- capability 仍标记为 `NeedsSpike`，不能误写成已完成真实平台接入。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为缺少 `AppAction.DevicePasskeyRequested`、`AppDestination.DevicePasskeyLogin` 和 `features/auth/data/DevicePasskeyLoginRepository`，证明测试正在约束尚未实现的设备 Passkey 登录边界。

- [x] **步骤 3：实现最小设备 Passkey repository**

本轮新增：

- `DevicePasskeyLoginStatus`
- `DevicePasskeyLoginSession`
- `DevicePasskeyLoginRepository`
- `PreviewDevicePasskeyLoginRepository`

当前只表达设备内置 Passkey 登录边界，不调用真实 Harmony Passkey / FIDO2 API，不接 NFC、YubiKey 或漫游认证器。

- [x] **步骤 4：接入独立 Passkey 登录页**

`AuthLandingScreen` 的“使用设备 Passkey 登录”入口现在通过 `DevicePasskeyRequested` 进入 `DevicePasskeyLoginScreen`；页面展示能力状态，并提供 preview 模拟成功入口用于状态流闭环。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 18：生物识别 + HUKS 解锁页面和数据边界

**文件：**
- 修改：`apps/harmony-app/entry/src/main/ets/core/navigation/AppDestination.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/state/AppStateReducer.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/data/BiometricUnlockRepository.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/BiometricUnlockScreen.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/BiometricUnlockRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AppStateReducer.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/README.md`

- [x] **步骤 1：先写生物识别解锁红灯测试**

测试覆盖：

- `BiometricUnlockRequested` 必须从锁定态进入独立 `BiometricUnlock` 目的地，不能从解锁页直接进入保险库。
- `BiometricUnlockSucceeded` 才能进入保险库首页。
- preview session 必须同时声明需要 userAuth 用户认证和 HUKS 密钥保护。
- capability 仍标记为 `NotConfigured`，不能误写成已完成真实平台接入。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为缺少 `AppAction.BiometricUnlockRequested`、`AppAction.BiometricUnlockSucceeded`、`AppDestination.BiometricUnlock` 和 `features/auth/data/BiometricUnlockRepository`，证明测试正在约束尚未实现的生物识别解锁边界。

- [x] **步骤 3：实现最小生物识别解锁 repository**

本轮新增：

- `BiometricUnlockStatus`
- `BiometricUnlockSession`
- `BiometricUnlockRepository`
- `PreviewBiometricUnlockRepository`

当前只表达 userAuth 与 HUKS 的能力边界，不调用真实 `@ohos.userIAM.userAuth`，不创建 HUKS 密钥，也不解封真实保险库密钥。

- [x] **步骤 4：接入独立生物识别解锁页**

`VaultUnlockScreen` 的“面容 / 指纹解锁”入口现在通过 `BiometricUnlockRequested` 进入 `BiometricUnlockScreen`；页面展示 userAuth 与 HUKS 的职责边界，并提供 preview 模拟成功入口用于状态流闭环。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 19：trusted device 登录审批页面和数据边界

**文件：**
- 修改：`apps/harmony-app/entry/src/main/ets/core/navigation/AppDestination.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/state/AppStateReducer.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/auth/AuthLandingScreen.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/auth/state/AuthStateMachine.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/auth/data/AuthRepository.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/data/TrustedDeviceApprovalRepository.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/auth/TrustedDeviceApprovalScreen.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/TrustedDeviceApprovalRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AppStateReducer.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AuthRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AuthStateMachine.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/README.md`

- [x] **步骤 1：先写 trusted device 红灯测试**

测试覆盖：

- `TrustedDeviceApprovalRequested` 必须从登录态进入独立 `TrustedDeviceApproval` 目的地。
- `TrustedDeviceApproved` 才能进入保险库首页。
- Auth repository 必须暴露 `TrustedDevice` 为首发登录方式，并通过独立 capability stage 启动。
- Auth state machine 必须产生 `StartTrustedDeviceApproval` 事件。
- 登录审批 repository 必须记录 PushKit 优先、前台刷新 fallback 和手动刷新可用。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为缺少 `AppAction.TrustedDeviceApprovalRequested`、`AppAction.TrustedDeviceApproved`、`AppDestination.TrustedDeviceApproval`、`AuthFlowStage.TrustedDeviceApproval`、`AuthAction.TrustedDeviceApprovalRequested`、`AuthEventKind.StartTrustedDeviceApproval` 和 `features/auth/data/TrustedDeviceApprovalRepository`，证明测试正在约束尚未实现的登录审批边界。

- [x] **步骤 3：实现最小 trusted device approval repository**

本轮新增：

- `TrustedDeviceApprovalStatus`
- `TrustedDeviceApprovalSession`
- `TrustedDeviceApprovalRepository`
- `PreviewTrustedDeviceApprovalRepository`

当前只表达登录审批状态、PushKit 优先路径、前台刷新 fallback 和手动刷新能力，不调用真实 Push Kit，不轮询 Bitwarden 服务端，也不处理真实 trusted device approval token。

- [x] **步骤 4：接入独立登录审批页**

`AuthLandingScreen` 新增“通过已登录设备审批”入口，现在通过 `TrustedDeviceApprovalRequested` 进入 `TrustedDeviceApprovalScreen`；页面展示登录审批等待状态，并提供 preview 模拟审批通过入口用于状态流闭环。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 任务 20：添加 TOTP 页面和数据边界

**文件：**
- 修改：`apps/harmony-app/entry/src/main/ets/core/navigation/AppDestination.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/state/AppStateReducer.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/app/AppShell.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/vault/VaultHomeScreen.ets`
- 修改：`apps/harmony-app/entry/src/main/ets/features/vault/state/VaultStateMachine.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/vault/data/TotpSetupRepository.ets`
- 创建：`apps/harmony-app/entry/src/main/ets/features/vault/TotpSetupScreen.ets`
- 创建：`apps/harmony-app/entry/src/ohosTest/ets/test/TotpSetupRepository.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/AppStateReducer.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/VaultStateMachine.test.ets`
- 修改：`apps/harmony-app/entry/src/ohosTest/ets/test/List.test.ets`
- 修改：`apps/harmony-app/README.md`

- [x] **步骤 1：先写添加 TOTP 红灯测试**

测试覆盖：

- `OpenAddTotp` 必须从保险库首页进入独立 `AddTotp` 目的地。
- `TotpSetupSaved` 必须回到两步验证码页面，形成“添加后查看验证码”的主应用闭环。
- Vault 状态机必须产生 `NavigateToAddTotp` 事件。
- TOTP setup repository 必须能解析 `otpauth://totp` URI，缺少 `secret` 时返回 validation error。
- TOTP setup repository 必须支持发行方、账号和 secret 的手动录入 preview。

- [x] **步骤 2：验证红灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：构建失败，错误为缺少 `AppAction.OpenAddTotp`、`AppAction.TotpSetupSaved`、`AppDestination.AddTotp`、`VaultAction.OpenAddTotp`、`VaultViewSurface.AddTotp`、`VaultEventKind.NavigateToAddTotp` 和 `features/vault/data/TotpSetupRepository`，证明测试正在约束尚未实现的主应用添加 TOTP 边界。

- [x] **步骤 3：实现最小 TOTP setup repository**

本轮新增：

- `TotpSetupMode`
- `TotpSetupStatus`
- `TotpSetupDraft`
- `TotpSetupRepository`
- `PreviewTotpSetupRepository`

当前只做 `otpauth://totp` URI preview 解析、手动录入 preview 和 secret 掩码展示，不写入真实保险库，不计算真实 TOTP，不调用 Bitwarden SDK。

- [x] **步骤 4：接入独立添加 TOTP 页面**

保险库首页的验证码卡片现在同时提供“添加 TOTP”和“查看验证码”入口；`TotpSetupScreen` 支持 URI 解析和手动录入 preview，保存 preview 后进入两步验证码页面。

- [x] **步骤 5：验证绿灯**

运行：`& 'C:\Program Files\Huawei\DevEco Studio\tools\hvigor\bin\hvigorw.bat' --mode module -p module=entry@ohosTest assembleHap --no-daemon --stacktrace`

结果：`BUILD SUCCESSFUL`，仍只有预期的 `No signingConfig found for product default` 警告。

## 自检

- 规格覆盖度：计划覆盖 `Password Manager` 一期主应用、TOTP、设备 Passkey 登录、自动填充、凭据获取、SDK bridge、生物识别、推送同步、自托管 / SSO / trusted device / key connector 边界，以及 Premium Web 开放、mTLS 预留和 Authenticator 扩展边界。
- 类型一致性：`CapabilityProbeResult`、`SdkClientManager`、`RootState`、`SpecialCircumstance` 在计划和工程骨架中使用同一命名。
- 安全边界：计划不提交签名材料，不伪造加密实现，不把自动填充和 Passkey provider 混为同一能力。
