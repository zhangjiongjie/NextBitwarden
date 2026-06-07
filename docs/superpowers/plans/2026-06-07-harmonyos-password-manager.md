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

## 自检

- 规格覆盖度：计划覆盖 `Password Manager` 一期主应用、TOTP、设备 Passkey 登录、自动填充、凭据获取、SDK bridge、生物识别、推送同步、自托管 / SSO / trusted device / key connector 边界。
- 类型一致性：`CapabilityProbeResult`、`SdkClientManager`、`RootState`、`SpecialCircumstance` 在计划和工程骨架中使用同一命名。
- 安全边界：计划不提交签名材料，不伪造加密实现，不把自动填充和 Passkey provider 混为同一能力。
