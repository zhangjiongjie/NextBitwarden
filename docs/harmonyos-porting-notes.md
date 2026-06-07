# Bitwarden Android 到 HarmonyOS NEXT 迁移注意事项

## 1. 文档目的

本文档用于在开始鸿蒙版本架构设计之前，先把 `bitwarden/android` 当前工程的产品边界、可复用部分、必须重写的系统能力，以及高风险验证点记录清楚。

当前目标不是直接给出最终架构实现方案，而是回答下面 4 个问题：

1. Android 工程当前到底包含哪些产品与能力。
2. 哪些部分值得在鸿蒙侧保留同样的分层和职责边界。
3. 哪些 Android 系统集成能力不能 1:1 平移到鸿蒙。
4. 在“功能尽量相同、UI 尽量相似”的前提下，哪些地方必须接受鸿蒙原生重构。

## 2. 先说结论

- 可以追求“功能一致”。
- 可以追求“UI 视觉和交互风格尽量一致”。
- 不能假设“系统集成方式一致”。
- 最应该复用的是模块边界、状态机、业务模型、仓储分层、设计语言。
- 最不能直接照搬的是自动填充、凭据提供、Passkey provider、生物识别密钥保护、推送、后台任务、NFC、支付、系统入口和应用间桥接。

一句话概括：鸿蒙版更像是“按 Bitwarden Android 的产品设计和业务模型，重新做一套 HarmonyOS NEXT 原生客户端”，而不是把 Android 工程简单翻译成 ArkTS。

当前已经确认的产品方向有 3 点：

- 一期范围只做 `Password Manager` 主应用，不做独立 `Authenticator`，也不做 `authenticatorbridge`。
- `Password Manager` 主应用本身就要保留 TOTP 新增入口和两步验证码展示能力。
- 首发目标必须尽量对齐 Android，自动填充、Passkey、凭据获取这类系统集成能力也属于首发范围。

进一步收窄到登录与认证方式，一期边界还已经确认：

- 一期需要支持用户通过 `TOTP` 两步验证码完成登录。
- 一期需要支持设备内置 Passkey（platform authenticator）登录。
- 一期不要求支持外部安全密钥、`NFC`、`YubiKey` 这类外部 Passkey / WebAuthn 登录方式。

但要特别强调：

- “首发必须覆盖”是产品目标。
- “HarmonyOS NEXT 是否存在完全对等的系统 provider 能力”仍然是待验证的技术事实。

这两件事不能混写，否则文档会把“需求已确认”和“平台能力已证实”混为一谈。

## 3. 当前 Android 工程的真实边界

### 3.1 这不是单一 App

当前仓库不是单个密码管理器应用，而是至少包含 2 个用户产品和 1 个桥接模块：

- `app`：Bitwarden Password Manager 主应用。
- `authenticator`：独立的 Bitwarden Authenticator 应用。
- `authenticatorbridge`：主应用与 Authenticator 之间的桥接。

对应证据：

- `settings.gradle.kts` 引入了 `:app`、`:authenticator`、`:authenticatorbridge`、`:core`、`:data`、`:network`、`:ui` 等模块。
- `docs/ARCHITECTURE.md` 明确把 `Bitwarden.app` 和 `Bitwarden.authenticator` 作为两个 application module 描述。

这对鸿蒙版本非常关键，因为“做一个鸿蒙版 APP”至少有 3 种含义：

1. 只做密码管理器主 App。
2. 主 App 和 Authenticator 都做，仍然保持双应用形态。
3. 做单个鸿蒙 App，把主应用和 Authenticator 能力合并。

如果这个范围不先确认，后面的 IPC、自动填充、Passkey、TOTP、本地锁定策略都会受到影响。

当前这件事已经确认：

- 一期先只做 `Password Manager` 主应用。
- 独立 `Authenticator` 与 `authenticatorbridge` 不进入首发范围。
- 但主应用内部已有的 TOTP 新增和验证码展示能力，仍然属于一期范围。

### 3.2 工程是多模块架构，但不是天然跨平台架构

仓库模块边界很清晰，这一点非常值得保留：

- `core`
- `data`
- `network`
- `ui`
- `app`
- `authenticator`
- `authenticatorbridge`

但要注意：这些模块名虽然很像“跨平台共享层”，实际并不等于可以直接搬到鸿蒙。

当前证据表明：

- `core`、`data`、`network` 都是 Android library module，而不是纯 Kotlin Multiplatform module。
- `data` 直接依赖 `SharedPreferences`、`EncryptedSharedPreferences`、`Context`、`Application`、`ProcessLifecycleOwner` 等 Android API。
- `network` 与 `core` 中也存在 `android.os.Build`、`android.Manifest`、`androidx.annotation.*` 等 Android 依赖。

因此更合理的判断是：

- 可以复用“模块职责划分思想”。
- 可以复用“业务模型、状态流、接口命名风格”。
- 不应期待把现有 `core/data/network/ui` 源码直接编译到鸿蒙。

## 4. 当前 Android 工程最值得保留的东西

### 4.1 状态驱动导航模型

Bitwarden Android 的主应用不是简单的页面跳转堆砌，而是很明显的状态机驱动：

- 未登录。
- 欢迎页。
- Trusted Device。
- Vault Locked。
- Vault Unlocked。
- Vault Unlocked for Autofill Save。
- Vault Unlocked for Autofill Selection。
- Vault Unlocked for FIDO2 Save。
- Vault Unlocked for FIDO2 Assertion。
- Vault Unlocked for Password Get。
- Vault Unlocked for Provider Get Credentials。
- Vault Unlocked for New TOTP。
- Vault Unlocked for New Send。
- Remove Password。
- Reset Password。
- Set Password。
- Registration Event。
- Credential Exchange。

这套设计在鸿蒙侧非常值得保留，因为它天然适合处理：

- 冷启动进入不同场景。
- 从系统入口拉起后的特殊业务流。
- 解锁前后行为差异。
- 多账号状态切换。
- 应用内导航与系统调用入口的统一收敛。

建议后续鸿蒙架构仍保留“根状态机 + feature shell”的思路，不要退化成松散页面跳转。

### 4.2 UDF / MVVM / state-action-event 约束

`docs/ARCHITECTURE.md` 明确说明：

- UI 层采用 UDF。
- ViewModel 基于 `BaseViewModel`。
- 统一使用 `state / action / event`。
- 异步结果通过 internal action 回灌，避免在协程里直接改 UI state。

这套约束非常适合鸿蒙侧保留，因为它能帮助我们在以下复杂场景里保持可维护性：

- 自动填充、Passkey、扫码等系统回调很多。
- 解锁、登录、同步、刷新是强状态依赖。
- 多账号、多保险库锁状态和 feature 入口之间容易串线。

### 4.3 Repository / Manager / Data Source 分层

当前数据层边界非常清楚：

- Data Source：原始网络、磁盘、SDK 接口。
- Manager：单一职责的中层能力，包括 OS 封装。
- Repository：面向 UI 的聚合能力层。

鸿蒙版强烈建议延续这个边界，而不是把所有 Harmony API 直接塞进 ViewModel 或页面中。

尤其是下面这些能力，天然应该被单独做成 capability manager：

- 生物识别认证。
- 密钥存储。
- 自动填充。
- Passkey / FIDO2。
- 推送。
- 后台任务。
- 剪贴板。
- 证书与 mTLS。
- 扫码。
- NFC / 安全密钥。

### 4.4 设计系统与组件抽象

当前 Android 工程有独立的 `ui` 模块与 `BitwardenTheme`，说明它不是“每个页面自己写一套 UI”，而是已经有统一设计语言：

- 颜色体系。
- Typography。
- Shapes。
- Scaffold / TopAppBar / Dialog / Snackbar / List Item 等公共组件。

这对“UI 尽量相似”非常重要。鸿蒙侧最值得复用的不是 Compose 代码本身，而是：

- 页面结构。
- 组件层级。
- 间距、圆角、字号、色彩语义。
- icon 使用规则。
- 空态、加载态、错误态表达方式。

## 5. 当前 Android 工程中已经识别出的核心功能域

### 5.1 主应用功能域

从目录结构看，主应用至少包括以下一级能力域：

- `auth`
  - 登录、注册、欢迎页、设备登录、SSO、Duo、2FA、trusted device、重置密码等。
- `vault`
  - 列表、搜索、查看详情、新建、编辑、附件、导入、导出、验证代码、二维码、手动录入等。
- `tools`
  - 密码生成器、Send。
- `platform`
  - Settings、Splash、Debug、Search、VaultUnlocked、通知、系统入口等。
- `autofill`
  - 系统自动填充和相关 UI。
- `credentials`
  - Credential Manager / Passkey / password provider 相关能力。

需要特别确认的一点是：`Password Manager` 主应用本身就包含 TOTP 相关能力，并不是只有独立 `Authenticator` 才有。

主应用里至少已经明确存在两条链路：

- 给登录条目添加 TOTP：
  - 支持处理 `otpauth://totp` 深链。
  - 支持以 `SpecialCircumstance.AddTotpLoginItem` 进入新建流程。
  - `VaultAddEdit` 流程里明确存在手动录入和二维码扫描入口，并支持将 TOTP 数据预填到登录条目中。
- 展示两步验证码：
  - 主应用里存在独立的 `VerificationCode` 页面。
  - `VaultRepository` 和 `TotpCodeManager` 负责生成和刷新验证码列表 / 单条验证码。
  - 该页面支持查看、复制验证码，并跳转回对应的 Vault 条目。

这意味着对于一期“只做 `Password Manager` 主应用”的范围，TOTP 相关基础能力不需要依赖独立 `Authenticator` 才能成立。

### 5.2 Authenticator 功能域

Authenticator 相对简单，但它本身是独立产品，不只是一个页面：

- 教程。
- 解锁。
- 账号列表。
- TOTP 显示。
- 编辑条目。
- 手动录入。
- 扫码添加。
- 搜索。
- 设置。

如果后面决定合并为单个鸿蒙 App，也仍然要把 Authenticator 视为独立 feature domain，而不是主应用中顺手挂一个页面。

但要注意它与主应用的边界不是“有没有 TOTP”，而是“谁是更完整的 TOTP 产品形态”：

- `Password Manager` 主应用：
  - 重点是把 TOTP 作为 Vault 登录条目的一部分来管理和展示。
- `Authenticator` 独立应用：
  - 提供更聚焦的验证码产品体验，例如专门的验证码列表、教程、扫码、手动录入、导入导出，以及与主应用之间的桥接同步能力。

## 6. “可复用”与“不可直接复用”的边界

### 6.1 可以优先复用的内容

- 产品信息架构。
- feature 划分。
- 业务状态机。
- 数据模型语义。
- 仓储接口和 manager 边界。
- 网络 API 契约。
- 设计系统 token。
- 交互文案和页面层级。
- 测试用例思路和 feature matrix。

### 6.2 只能借鉴思路、不能直接复用源码的内容

- `core/data/network` 的大部分实现。
- 基于 Hilt 的依赖注入装配。
- Compose 页面实现。
- `SavedStateHandle`、`Activity`、`Intent`、`PendingIntent`。
- Android manifest 声明式系统集成。

### 6.3 必须重写的内容

- 生物识别。
- 密钥库接入。
- 自动填充。
- Passkey / FIDO2 系统集成。
- 推送。
- 后台任务。
- 剪贴板定时清理。
- 应用锁定与前后台感知。
- NFC / YubiKey。
- 证书与系统 KeyChain。
- Quick Settings Tile / Accessibility fallback。
- Google Play 相关能力。

## 7. 详细迁移注意事项

### 7.1 产品范围是第一优先级问题

开始架构之前必须先定一个范围版本：

- 方案 A：先只做主密码管理器。
- 方案 B：主密码管理器和 Authenticator 同时做，但仍保持双 App。
- 方案 C：做单个鸿蒙 App，把 TOTP / Authenticator 能力合并进去。

推荐顺序：

1. 先确认最终目标是双 App 还是单 App。
2. 如果目标不明确，第一阶段建议优先做主密码管理器，Authenticator 作为明确的 Phase 2。

当前已确认的一期选择是：

- 先做主密码管理器。
- 不做独立 `Authenticator`。
- 不做 `authenticatorbridge`。

原因：

- 自动填充、Passkey、主保险库、企业能力、登录流的复杂度已经很高。
- Authenticator 叠加后，锁定模型、TOTP 本地存储、桥接与入口切换都会增加复杂度。

### 7.2 UI 相似性的注意事项

“UI 尽量相似”不等于逐像素照抄 Compose，而是需要分层处理：

- 视觉一致：
  - 色板、字号、圆角、分组卡片、列表风格、表单布局、顶部栏风格、空态和错误态风格尽量一致。
- 信息架构一致：
  - 底部导航、分区、设置项分组、条目详情结构、编辑页字段顺序尽量一致。
- 交互一致：
  - 搜索、筛选、解锁、复制、查看密码、生成密码、确认弹窗、失败提示尽量一致。
- 系统行为原生化：
  - 输入框、权限弹窗、密码保险箱、Passkey、扫码、通知等需要遵守 HarmonyOS 原生交互。

鸿蒙侧不要强行模拟 Android 特有控件或入口，例如：

- Quick Settings Tile。
- Android inline autofill suggestion UI。
- Android Credential Manager 设置入口。
- Android Accessibility service 触发式填充。

### 7.3 导航与生命周期不能照搬 Activity / Intent

Android 当前大量依赖：

- Activity 启动模式。
- `Intent` 深链。
- 自定义 scheme。
- `PendingIntent`。
- ActivityResult 回调。
- process restore 和 `SavedStateHandle`。

鸿蒙侧需要保留“根状态驱动”，但需要重写：

- 冷启动路由收敛。
- 从系统能力拉起的回调流。
- 登录、SSO、Duo、WebAuthn 回调。
- 从扫码、共享、自动填充、Passkey 等外部入口回流到统一根状态机。

### 7.4 Bitwarden SDK 是一个必须提前验证的复用点

Bitwarden 官方贡献文档说明，密码管理器的内部 SDK 是用 Rust 编写的，目标是承载尽可能多的核心业务逻辑，并向 Kotlin、Swift、JavaScript/TypeScript 等平台提供绑定。

这对鸿蒙非常重要，因为它说明：

- 真正值得跨端复用的核心逻辑，本来就应该尽量在 SDK，而不是客户端页面代码。
- 但当前 Android 仓库里接入的是 Kotlin/Android 侧已经包装好的 SDK 使用方式。

因此鸿蒙版开始架构前，需要做一个独立 feasibility spike：

1. 当前 Bitwarden Password Manager internal SDK 是否存在可用于 Harmony 的接入路径。
2. 是否有 C ABI / Rust FFI / NAPI / 其他可落到 Harmony 的桥接方式。
3. 如果没有，哪些核心逻辑必须由鸿蒙客户端自行重写或重新封装。

这一点会直接影响：

- 加解密。
- KDF。
- Vault 同步和映射。
- Passkey 数据模型。
- TOTP 生成。

当前这项策略方向已经确认：

- Harmony 版本默认走“官方 Bitwarden internal SDK 直连优先”路线。
- 不预设以“大比例客户端重写核心逻辑”作为一期默认方案。
- 架构上优先为 SDK 宿主桥接层让路，而不是先把核心能力改写到 Harmony 客户端里。

但这个确认的是“接入方向”，不是“技术可行性已经验证完成”：

- 仍然需要逐项验证 SDK 交付形态、宿主桥接接口、Passkey / SSO 配置桥接、Native 目标架构与运行时约束。
- 只有在验证后确认某些能力确实无法直连接入时，才进入局部补写或局部替代方案讨论。

进一步说，`Bitwarden internal SDK` 的 Harmony 接入策略，至少要拆成下面这些确认点：

1. 交付形态：
   - 已确认：一期优先采用源码接入方式，后续再沉淀预编译产物。
   - 可接受形式包括源码依赖、`Git submodule`、本地模块或等效源码集成方式。
   - 首发阶段优先保证可调试、可定位 Native 目标架构 / 加密 / Passkey / SSO / Vault 行为。
   - 等核心链路稳定后，再考虑封装为内部 `.har`、native library 或其他预编译产物。
   - 如果 SDK 最终需要 Rust / native library，则优先在源码接入模式下打通 C ABI / FFI / NAPI 到 ArkTS 的桥接链路。
2. Native 目标架构与运行时兼容性：
   - 已确认：这不是扩大产品范围的功能项，而是 SDK 接入前必须完成的技术验证门槛。
   - 首发发布承诺只面向实际 HarmonyOS NEXT 真机目标架构。
   - HarmonyOS NEXT 存在 native `.so`、CMake、NDK、`abiFilters` 等构建 / 打包维度，但这里不直接套用 Android ABI 语境。
   - 一期优先验证首发真机目标架构，预计以 64 位 ARM 目标为主。
   - `x86_64` 如果只用于模拟器或本地调试，不作为首发发布承诺。
   - 具体支持哪些目标架构，以 DevEco / Harmony SDK 实测结果和首发设备要求为准。
   - spike 必须验证 native library 的构建、加载、初始化、生命周期、异常恢复和崩溃可观测性。
3. Client 生命周期：
   - 已确认：Harmony 版本沿用 Android 的 `globalClient + per-user cached client + single-use client` 多 client 模型。
   - Harmony 侧通过 `SdkClientManager` 统一管理 client 创建、缓存、失效、重建和释放。
   - `globalClient` 负责未登录、环境配置、基础 API、账号列表等全局能力。
   - `userClient` 按账号缓存，解锁后用于 Vault、同步、加密、组织能力。
   - `singleUseClient` 只用于登录、SSO 回调、设备审批、迁移验证等一次性敏感流程。
   - 切换账号、锁定、退出登录时必须明确释放或失效对应 client，页面和 ViewModel 不直接长期持有 SDK client。
4. 宿主侧仓储桥接：
   - 已确认：采用 Android / SDK 职责对齐 + Harmony Adapter 封装。
   - 不直接移植 Kotlin repository 实现，也不在 Harmony 侧重新发明一套领域边界。
   - SDK 看到的接口应尽量接近官方 SDK 预期，Harmony 业务层看到的是 ArkTS 风格的 repository / capability。
   - 中间通过 `SdkRepositoryBridge` 聚合各类 adapter，负责接口转换、生命周期约束和错误归一。
   - SDK 不是只吃纯参数，它还依赖宿主提供 `ClientManagedTokens`、`ClientSettings`、`CipherRepository`、`FolderRepository`、`LocalUserDataKeyStateRepository`、`ServerCommunicationConfigRepository` 等桥接接口。
   - Harmony 侧至少需要准备 `ClientManagedTokensAdapter`、`ClientSettingsAdapter`、`CipherRepositoryAdapter`、`FolderRepositoryAdapter`、`LocalUserDataKeyStateAdapter`、`ServerCommunicationConfigAdapter`。
   - 这些 adapter 分别由 Harmony 本地存储、账号状态、Vault 缓存、用户密钥状态和服务器配置源来承接。
   - UI 和 feature 层不直接绕过 SDK 修改核心加密状态或同步状态。
5. 认证与密码学能力覆盖面：
   - 已确认：一期必须完整覆盖认证域和密码学相关主链路。
   - 一期必做范围包括登录、注册、主密码校验、密码哈希、KDF、password strength、policy filter、PIN、生物识别解锁桥接、trusted device、key connector、组织加密初始化。
   - 不能只验证“能解密 Vault”，还要按认证域逐项验证登录、解锁、组织和企业认证链路是否闭环。
6. Vault 核心能力覆盖面：
   - 已确认：一期必须完整覆盖主应用 Vault 域闭环能力。
   - 一期必做范围包括 cipher、folder、send、attachment、TOTP、密码历史、更新密码、更新 KDF、组织内移动、导入导出。
   - Vault 域验收必须覆盖创建、读取、更新、删除、同步、加解密、本地缓存和组织上下文，不接受只验证单条 cipher 解密成功。
7. Passkey / FIDO2 桥接：
   - 已确认：一期采用 `PlatformPasskeyCapability + SdkFidoBridge` 两层架构。
   - `PlatformPasskeyCapability` 负责 Harmony 系统 Passkey / FIDO2 / 凭据选择能力。
   - `SdkFidoBridge` 负责把 Harmony 系统返回结果转换成 Bitwarden SDK 需要的 `Fido2CredentialStore`、`Fido2UserInterface` 等宿主接口语义。
   - 一期必须覆盖设备内置 Passkey（platform authenticator）登录和凭据相关桥接。
   - 外部安全密钥、`NFC`、`YubiKey`、漫游认证器等 cross-platform authenticator 路径不纳入一期。
   - Android 当前还给 SDK 提供了 `Fido2CredentialStore` 和 `Fido2UserInterface` 一类宿主实现。
   - Harmony 侧是否能把本地 Passkey / WebAuthn / 凭据选择流程等价映射给 SDK，仍需要通过 spike 验证。
8. SSO / Cookie / Server Communication Config：
   - 已确认：一期保留 SSO 登录和自托管服务器配置能力。
   - Harmony 侧优先使用系统浏览器 / 系统 Web 能力完成 SSO 跳转、授权和回调闭环。
   - Cookie、回调 URL、SSO 状态参数不由业务页面私自管理，而是封装到 `SsoWebAuthCapability`。
   - server URL、自托管环境、API endpoint、环境切换等配置通过 `ServerConfigBridge` 对接 SDK 的 `ServerCommunicationConfigRepository`。
   - 企业证书 / `mTLS` 仍不纳入一期，但 `ServerConfigBridge` 要保留后续扩展位。
   - SDK 当前依赖宿主提供 `ServerCommunicationConfigRepository` 和 platform API 来处理 SSO cookie acquisition 一类流程。
   - Harmony 侧浏览器拉起、Cookie 持久化、回调闭环仍需要通过 spike 验证系统能力边界。
9. 版本策略与可维护性：
   - 已确认：一期先锁定一个已验证可在 Harmony 打通的 Bitwarden SDK 版本。
   - 首发阶段不跟随 Android 最新提交滚动升级，避免 Rust / native / 桥接接口变化放大发版风险。
   - 锁定版本必须记录来源 commit / tag、适配补丁、native 构建参数、桥接接口清单和已通过的核心链路。
   - 首发后再建立定期同步 SDK 版本的节奏，每次升级必须跑桥接层回归测试和认证 / Vault 主链路回归。
10. 测试与可替换性：
   - 已确认：一期必须建立 SDK 接入测试护栏，不能只依赖人工手测。
   - 需要支持桥接层 mock，用于验证 `SdkClientManager`、`SdkRepositoryBridge`、`SsoWebAuthCapability`、`SdkFidoBridge` 等边界。
   - 需要覆盖 ArkTS 与 native / Rust SDK 的跨语言集成测试，重点验证参数转换、错误映射、生命周期和异常恢复。
   - 需要建立认证域回归和 Vault 域回归，覆盖登录、解锁、同步、加解密、组织上下文、TOTP、附件、导入导出等主链路。
   - Passkey / FIDO2、SSO / Cookie、系统自动填充、凭据获取这类系统桥接能力至少要有 smoke test。
   - 如果某一块能力暂时需要局部替代实现，必须保持接口可替换，后续可以回归官方 SDK 路线。

在这一组能力里，当前已经进一步确认的产品范围是：

- `trusted device` 纳入一期，按必做能力处理。
- 组织加密初始化纳入一期，按必做能力处理。
- `key connector` 也纳入一期，不从首发范围中删除。

但风险标注需要分层写清楚：

- `trusted device` 和组织加密初始化，按“一期闭环能力”来设计和验证。
- `key connector` 虽然仍在一期范围内，但应单独标记为“企业能力高风险验证项”。
- 也就是说，产品范围上不删，技术验证上单独拉高优先级。

### 7.5 生物识别与密钥保护必须拆成两层能力

Android 当前并不是单纯“弹一个指纹框”，而是把下面两件事绑在一起：

- UI 认证：`BiometricPrompt`。
- 密钥访问控制：`AndroidKeyStore` + `setUserAuthenticationRequired(true)` + `setInvalidatedByBiometricEnrollment(true)`。

鸿蒙当前对应能力更像两套：

- 用户认证：`@ohos.userIAM.userAuth`
- 密钥库与访问控制：`@ohos.security.huks`

因此鸿蒙侧不建议照着 Android 直接做一个“大一统 BiometricsManager”，而应拆成：

- `UserVerificationCapability`
  - 负责发起人脸 / 指纹 / PIN 认证。
  - 处理认证冻结、重试、取消、复用时间窗。
- `ProtectedKeyStoreCapability`
  - 负责生成、存储、轮换、失效恢复。
  - 负责用户认证 token 和密钥访问策略的绑定。

还需要单独关注这些边界：

- 新录入生物特征后密钥是否失效。
- 生物识别被关闭 / 重新开启后的恢复流程。
- 多账号情况下是否每个账号单独维护 unlock secret。
- 解锁失败、认证冻结、PIN 过期等异常如何反馈到 UI。

### 7.6 自动填充是当前最高风险能力之一

Android 当前自动填充不是一条链路，而是至少三条链路并存：

- `AutofillService`
- `AccessibilityService` fallback
- `CredentialProviderService` / Credential Manager

另外还有：

- Autofill callback activity
- inline suggestion UI
- passkey management settings
- browser autofill / privileged apps / block list 等设置周边

鸿蒙侧当前已确认的事实是：

- ArkUI 的 `TextInput` / `TextArea` 支持 `enableAutoFill`、`ContentType.USER_NAME/PASSWORD/NEW_PASSWORD` 等接入方式。
- 文本组件菜单中有 `autoFill` 和 `passwordVault`，文档明确写的是“点击后拉起密码保险箱应用，该应用提供自动填充账号密码能力”。
- 当前已查文档更像是在描述“应用如何接入密码保险箱”，而不是“第三方密码管理器如何注册为系统 provider”。

因此目前更稳妥的结论是：

- HarmonyOS NEXT 存在自动填充与密码保险箱相关能力。
- 但当前没有找到与 Android `AutofillService` / `CredentialProviderService` 明确对等的、面向第三方密码管理器应用的完整 provider 入口证据。
- 这件事必须作为高风险验证项单独攻关，不能在架构上先假设它存在。

#### 7.6.1 首发目标已经确认

这一点现在已经明确：

- 首发目标必须尽量对齐 Android。
- 自动填充不再是“有条件再做”或“后续补齐”的能力，而是首发目标的一部分。
- 但这并不代表 HarmonyOS NEXT 已经被证实具备与 Android 完全对等的第三方 provider 接入模型。

因此文档层面的正确表述应该是：

- 需求已确认：首发必须覆盖自动填充能力。
- 技术事实待验证：第三方密码管理器是否能以系统 provider 身份完整接入。
- 若最终没有完全对等入口，必须给出等效系统集成方案，而不是把需求直接降级为“首发不做”。

对架构的影响：

- 自动填充能力必须独立抽象，不要和普通表单输入混写。
- “主保险库能力”和“系统自动填充集成能力”必须分层。
- 首发范围必须包含自动填充，但实现方案要允许在“完全 provider 接入”和“等效系统集成方案”之间切换。

如果鸿蒙最终不存在完全对等的 provider 入口，可能的等效实现层级为：

1. 完整系统集成，如果后续验证鸿蒙允许第三方密码管理器作为 provider。
2. 通过密码保险箱或系统支持入口完成部分集成。
3. 应用内搜索并手动复制 / 粘贴。
4. 从分享 / 拉起 / 中转页完成半自动填充。

### 7.7 Passkey / WebAuthn / 凭据提供不要和自动填充混为一谈

Android 当前在这一块明显比普通自动填充更复杂，它包含：

- `CredentialProviderService`
- `CredentialProviderActivity`
- 密码凭据获取
- Passkey 创建
- Passkey 断言
- Provider get credentials
- origin 校验
- privileged app allow list
- Digital Asset Links

鸿蒙当前已确认存在 FIDO2 / 通行密钥能力，并且文档暴露了：

- `HMS_FIDO2_register`
- `HMS_FIDO2_authenticate`
- `origin` 参数
- client capability 查询
- platform authenticator / cross-platform authenticator 概念

但这只能说明：

- 鸿蒙具备通行密钥与 FIDO2 核心能力。

还不能直接推出：

- 鸿蒙一定存在与 Android Credential Manager 等价的第三方凭据提供框架。
- 鸿蒙一定支持第三方密码管理器对其他应用统一提供 Passkey。

当前也已经确认的产品目标是：

- 首发范围需要尽量覆盖 Android 里的 Passkey、凭据获取、密码凭据提供相关集成能力。
- 这同样属于首发目标，而不是后续版本再考虑的能力。

但这里仍然要把“目标”与“已验证能力”拆开写：

- 已确认的是产品目标。
- 尚未确认的是 HarmonyOS NEXT 是否提供与 Android Credential Manager / Credential Provider 等价的第三方凭据提供框架。

因此必须拆成 3 个层次分别评估：

1. Bitwarden 鸿蒙 App 自己管理和展示 Passkey 条目。
2. Bitwarden 鸿蒙 App 自己发起或参与 WebAuthn / FIDO2 操作。
3. Bitwarden 鸿蒙 App 作为系统级第三方凭据提供方，为其他应用或网页提供密码 / Passkey。

第 3 层是最高风险点，不能默认可行。

当前已确认的一期边界，还需要把 platform authenticator 和 cross-platform authenticator 拆开写清楚：

- 一期需要覆盖“设备内置 Passkey / platform authenticator”路径。
- 一期不要求覆盖外部安全密钥、`NFC`、`YubiKey`、漫游认证器这类 cross-platform authenticator 路径。
- 也就是说，这次排除的是“外部认证器登录方式”，不是把 Passkey 整体排除出一期。
- SDK 接入上采用 `PlatformPasskeyCapability + SdkFidoBridge` 两层架构，避免把系统 API、凭据 UI 和 SDK 宿主接口混在一起。

如果第 3 层最终没有完全对等入口，首发也不能简单删掉该需求，而需要明确：

- 哪些能力可以通过 HarmonyOS NEXT 已有的 Passkey / FIDO2 / 密码保险箱入口实现。
- 哪些能力只能做到受限集成。
- 哪些差异需要在产品说明和架构边界里显式标注。

### 7.8 登录、SSO、Duo、Auth Request、Trusted Device 不能只盯着“账号密码登录”

Bitwarden 的登录域并不只是输入邮箱和密码，还包括：

- 企业 SSO。
- Duo 回调。
- WebAuthn 回调。
- trusted device。
- device login / auth request approval。
- reset password / set password。
- registration completion。
- key connector 相关流程。

这些能力在鸿蒙侧都会受到浏览器拉起、回调链接、前后台切换、推送和本地加密能力的共同影响。

也就是说，登录域必须被当作一个独立复杂系统来设计，而不是一个普通表单页面。

当前已确认的一期边界补充如下：

- 登录两步验证里，`TOTP` 两步验证码属于一期必做。
- 设备内置 Passkey / WebAuthn 登录属于一期必做。
- 外部安全密钥、`NFC`、`YubiKey` 这类外部 Passkey / WebAuthn 登录方式不纳入一期。
- `trusted device` 属于一期必做。
- `key connector` 属于一期范围，但单列为高风险验证项。
- 组织加密初始化能力属于一期必做，因为它直接影响组织库与集合相关闭环。

### 7.9 推送、实时同步、登录审批按“双模式”落地

Android 当前标准 flavor 依赖 FCM：

- 推送通知。
- 实时同步触发。
- 登录审批 / auth request 等实时事件。

同时仓库还有 `fdroid` flavor，用来去掉 Google Play 依赖。这一点很有参考价值：

- 说明 Bitwarden 自己也承认“有推送能力”和“无推送能力”是两种运行模式。

鸿蒙版当前已确认采用类似能力分层：

- 有 `Push Kit` 的模式。
- 无推送的前台轮询 / 手动刷新模式。

当前一期策略已经确认：

- 推送不是首发阻塞项。
- 如果 `Push Kit` 可用，可以接入推送来增强实时同步和登录审批体验。
- 如果 `Push Kit` 暂不可用，也可以发版，但必须保证核心流程可闭环。
- 实时同步一期必须支持手动同步、前台进入 / 解锁后同步、关键操作后同步。
- 推送触发实时同步属于增强项，不作为首发硬门槛。
- 登录审批 / 设备登录属于一期必做能力。
- 有推送时，登录审批 / 设备登录可以走通知直达。
- 无推送时，发起端等待页采用短时前台轮询，建议只在页面活跃时每 `5-10 秒` 轮询一次。
- 无推送时，审批端进入 App 后也应能手动看到待处理请求。
- 一期不做全局后台长轮询。

这意味着架构上要把“业务闭环”和“推送触发”拆开：

- `AuthRequestCapability` 负责创建、查询、审批、拒绝、过期等业务状态。
- `VaultSyncCapability` 负责手动同步、启动 / 解锁后同步、关键操作后同步。
- `PushCapability` 只负责把系统推送转成触发信号，不应该成为登录审批和同步流程的唯一入口。

### 7.10 本地安全存储不能照搬 AndroidKeyStore + EncryptedSharedPreferences

Android 当前本地安全存储至少包括：

- `EncryptedSharedPreferences`
- MasterKey
- AndroidKeyStore
- 账号级生物解锁密钥
- 系统与账号生物完整性记录

鸿蒙版需要重新拆解成本地存储策略，而不是直接找一个“等价加密 SharedPreferences”替换：

- 普通配置存储。
- 敏感配置存储。
- 访问令牌与刷新令牌。
- 本地解锁材料。
- 生物解锁材料。
- 多账号分区。
- 失效恢复与 logout 语义。

### 7.11 后台任务、剪贴板清理、自动锁定需要按 Harmony 生命周期重做

Android 当前至少有这些行为：

- 前后台感知。
- 锁定超时。
- 屏幕亮起 / 熄灭联动。
- 剪贴板自动清理。
- Worker 任务。

鸿蒙当前文档表明：

- 有 `requestSuspendDelay` 这类短时任务能力。
- 有 `startBackgroundRunning` 这类长时任务能力。
- 长时任务往往伴随通知、模式限制、配额和可取消事件。

因此不能把 Android 的 WorkManager 心智原样带过来。鸿蒙侧需要重新定义：

- 哪些任务必须在后台运行。
- 哪些其实可以前台即做即清。
- 剪贴板清理是定时器、短时任务还是回前台 / 回后台触发。
- 锁定超时是依赖系统生命周期，还是通过 app state manager + monotonic clock 完成。

### 7.12 证书、mTLS、企业能力不要被“先做基础版”忽略

Android 当前包含：

- 证书导入。
- PKCS#12。
- AndroidKeyStore 存储。
- 系统 KeyChain 选择别名。
- 网络层接入客户端证书。

这类能力在企业场景里非常关键，而且会直接影响后续网络栈与设置页设计。

如果一开始架构没给它留位置，后面再补通常要返工：

- 设置模型。
- 本地存储模型。
- 网络 client 组装方式。
- 账号 / 服务器配置切换流程。

当前这项范围已经确认：

- 企业证书 / `mTLS` 不纳入一期范围。
- 一期不要求完成证书导入、客户端证书存储、证书别名选择、`mTLS` 网络接入闭环。

但这不代表架构上可以完全忽略：

- 服务器配置模型仍建议预留后续扩展位。
- 网络层装配方式不要写死到“永远没有客户端证书”。
- 二期如果补企业证书 / `mTLS`，应尽量避免推翻一期网络栈与设置模型。

### 7.13 NFC、YubiKey、漫游认证器不纳入一期范围

Android 当前涉及：

- NFC。
- YubiKey 结果回流。
- FIDO2 外部认证器。

鸿蒙文档显示 FIDO2 transport 枚举里包含：

- NFC
- USB
- BLE
- smart card
- hybrid

但“能力枚举存在”不等于“Bitwarden 需要的外设组合和系统入口都能稳定工作”。

当前这项范围已经确认：

- 外部安全密钥、`NFC`、`YubiKey`、漫游认证器不纳入一期范围。
- 一期不要求完成基于 `NFC / USB / BLE` 的外部 Passkey / WebAuthn 登录闭环。
- 这次排除的是外部认证器路径，不包括设备内置 Passkey 登录，也不包括 `TOTP` 两步验证码登录。

如果后续进入二期，这一块建议再独立验证：

- Yubi OTP。
- NFC 前台读取。
- 安全密钥接入。
- WebAuthn 回调闭环。

### 7.14 扫码与 OCR 能力需要拆开看

Android 当前存在至少两类能力：

- 二维码 / TOTP 扫码。
- 银行卡扫描 / OCR。

鸿蒙当前已看到默认扫码能力文档，因此：

- TOTP 扫码大概率有较稳妥替代方案。

但银行卡扫描这类基于 Google ML Kit 的能力：

- 不能默认存在等价方案。
- 需要替换为 HarmonyOS 侧 OCR / 扫描能力，或者接受第一阶段降级。

### 7.15 Google 生态相关能力都要重新做产品决策

Android `standard` flavor 当前包含：

- Play Billing
- In-app Review
- Crashlytics
- FCM

鸿蒙版不是简单技术替换，而是产品策略问题：

- Premium 购买是否走应用内购买。
- 还是统一跳 Web 支付。
- 评价入口是否保留。
- 崩溃上报与日志策略是否切到其他平台。

特别是 Premium 链路，必须尽早确认，因为它会影响：

- 付费页。
- 订阅状态同步。
- 用户引导文案。
- 平台差异处理。

当前这一项已经确认：

- 一期 `Premium / 订阅` 先统一走 Web 开放。
- 鸿蒙应用端不做应用内购买。
- 鸿蒙应用端不基于本地订阅状态对相关功能做额外限制。

文档里建议把这个策略理解为：

- 一期不实现鸿蒙侧购买链路。
- 一期不新增客户端本地功能门禁。
- 如果后端 / 服务端本身存在能力约束，应视为服务侧约束，而不是鸿蒙端再额外叠加一层购买限制。

### 7.16 AuthenticatorBridge 是否保留，是一个架构级选择

如果最终决定仍做双 App，就必须评估鸿蒙侧：

- 是否有等价的应用间安全通信方案。
- 如何做签名级别信任。
- 如何做版本兼容。
- 如何处理主 App 与 Authenticator 的安装状态、升级顺序和异常回退。

如果第一阶段希望缩短路径，合并为单 App 反而可能更务实。

### 7.17 `setHorizonOSAppLayout` 不是鸿蒙适配代码

Android 工程里出现的 `setHorizonOSAppLayout` 容易误判为“已有鸿蒙兼容逻辑”，但这里的 Horizon OS 指的是 Meta / Oculus 的 Horizon OS 兼容，而不是 HarmonyOS。

因此：

- 不能把这段代码当成鸿蒙适配基础。
- 也不能据此认为当前工程已有 Harmony 兼容层。

## 8. 为了“功能一致”必须特别盯住的能力清单

以下能力不要只盯“有无页面”，而要盯“完整闭环是否存在”：

- 多账号登录与切换。
- Vault 锁定 / 解锁 / 自动锁定。
- 生物识别解锁。
- Trusted Device。
- 企业 SSO。
- 登录两步验证（至少 `TOTP` 两步验证码）。
- 设备内置 Passkey / WebAuthn 登录。
- Duo / WebAuthn 回调。
- 密码条目、卡片、身份、SSH Key、银行账户、护照等多类型条目编辑。
- 附件上传 / 下载。
- 导入 / 导出。
- Generator。
- Send。
- TOTP 展示与新增。
- Passkey 展示、创建、断言。
- 自动填充。
- 搜索。
- 组织、集合、权限上下文。
- 私有服务器配置。
- Auth Request / 设备登录审批。
- Vault 手动同步、前台同步、关键操作后同步。

其中：

- 企业证书 / `mTLS` 已确认不纳入一期，不作为首发闭环要求。
- 外部安全密钥、`NFC`、`YubiKey` 已确认不纳入一期，但设备内置 Passkey / WebAuthn 登录仍在一期范围内。
- 推送触发实时同步属于增强项，不作为首发硬门槛；但登录审批 / 设备登录和基础同步闭环仍属于一期范围。
- 私有服务器配置本身仍应保留在一期范围内。

## 9. 为了“UI 尽量相似”必须特别保留的页面体验

建议后续在鸿蒙架构设计前，单独做一份页面清单和视觉清单，至少覆盖：

- 登录 / 欢迎 / 注册 / 设置密码 / 重置密码。
- Vault 列表。
- 条目详情。
- 新建 / 编辑条目。
- 搜索页。
- Generator。
- Send。
- Autofill / Passkey 相关设置。
- 账户安全相关设置。
- 服务器配置与企业能力页。

如果后续要继续规划独立 `Authenticator`，再单独补一份二期页面清单，不应和一期首发页面范围混写。

其中要特别保留的不是“控件像不像”，而是：

- 信息密度。
- 分组方式。
- 顶栏与滚动行为。
- 空态插图与说明风格。
- 危险操作确认方式。
- 表单字段顺序和默认行为。

## 10. 进入鸿蒙架构设计前必须先验证的事项

以下事项不是“可选优化”，而是进入正式架构设计前就要先拍板或先验证的发布门槛项：

1. HarmonyOS NEXT 是否支持第三方密码管理器作为系统自动填充 / 凭据 provider 的完整接入。
2. HarmonyOS NEXT 是否支持第三方应用对其他应用统一提供 Passkey / password credential。
3. Bitwarden internal SDK 是否存在 Harmony 可接入路径。
4. 一期之后是否还要规划独立 `Authenticator` 与 bridge 路线，以及现在的架构是否需要提前预留扩展边界。

其中第 1、2 项尤其特殊：

- 它们已经是首发目标的一部分。
- 现在需要确认的不是“要不要做”，而是“鸿蒙是否支持完全对等实现，以及如果不支持，要走哪种等效方案”。

## 11. 下一阶段做架构时的原则

在正式设计鸿蒙架构时，建议遵守下面这些原则：

- 先按能力抽象系统接口，再落页面。
- 先定产品范围，再定模块。
- 先保护业务状态机，再适配系统入口。
- 先保留 Bitwarden 的 design language，再做 Harmony 原生控件映射。
- 先按 Android 首发目标对齐，再把系统能力差异收敛到独立 capability 边界内。

更具体地说：

- 主体应围绕 `domain / repository / capability / feature / shell` 来拆。
- Harmony 系统能力必须集中到 adapter / capability 层，不要散落在页面。
- 自动填充、Passkey、生物识别、推送、后台任务必须是独立能力模块。
- 对自动填充、Passkey、凭据获取这类首发必做能力，架构上必须同时容纳“完全对等接入”和“受限等效接入”两种实现路径。
- 不能因为平台能力尚未证实，就在架构上先把这些能力降出首发范围。

## 12. 当前建议

进入正式架构设计之前，当前已经确认的事项和仍待确认的事项建议分开记录。

### 12.1 当前已经确认的事项

- 一期只做 `Password Manager` 主应用。
- 一期不做独立 `Authenticator`，也不做 `authenticatorbridge`。
- `Password Manager` 主应用本身要保留 TOTP 新增入口和验证码展示。
- 首发目标必须尽量对齐 Android，包括自动填充、Passkey、凭据获取这类系统集成能力。
- 一期登录侧需要支持 `TOTP` 两步验证码和设备内置 Passkey（platform authenticator）登录。
- 外部安全密钥、`NFC`、`YubiKey` 这类外部 Passkey / WebAuthn 登录方式不纳入一期。
- `Premium / 订阅` 一期统一走 Web 开放，应用端不做购买，也不做本地功能限制。
- `Bitwarden internal SDK` 的总体接入方向，默认采用“官方 SDK 直连优先”。
- `Bitwarden internal SDK` 的交付形态已确认：一期源码接入优先，稳定后再沉淀预编译产物。
- `Bitwarden internal SDK` 的 client 生命周期已确认：沿用多 client 模型，并由 Harmony 侧 `SdkClientManager` 统一管理。
- `Bitwarden internal SDK` 的宿主侧仓储桥接已确认：Android / SDK 职责对齐，Harmony 侧通过 adapter 封装。
- `Bitwarden internal SDK` 的认证域和 Vault 域覆盖面已确认：一期必须完整覆盖主链路，不接受只验证 Vault 解密成功。
- `Bitwarden internal SDK` 的 Passkey / FIDO2 桥接已确认：采用 `PlatformPasskeyCapability + SdkFidoBridge` 两层架构，一期覆盖设备内置 Passkey 路线。
- `Bitwarden internal SDK` 的 SSO / Cookie / Server Communication Config 桥接已确认：一期保留 SSO 和自托管服务器配置，通过 `SsoWebAuthCapability` 与 `ServerConfigBridge` 封装。
- `Bitwarden internal SDK` 的版本策略已确认：一期锁定一个 Harmony 已验证版本，首发后再建立定期同步和桥接回归测试节奏。
- `Bitwarden internal SDK` 的测试策略已确认：一期必须建立桥接层 mock、跨语言集成、认证 / Vault 回归和系统桥接 smoke test。
- `Bitwarden internal SDK` 的 Native 目标架构与运行时兼容性口径已确认：作为技术验证门槛处理，首发发布承诺只面向实际 HarmonyOS NEXT 真机目标架构。
- `trusted device`、组织加密初始化、`key connector` 都保留在一期范围内。
- 其中 `key connector` 单独标记为企业能力高风险验证项，但不从首发范围中移除。
- 推送采用“双模式”策略：有 `Push Kit` 就接入增强体验，没有推送也不阻塞首发。
- 实时同步一期必须支持手动同步、前台进入 / 解锁后同步、关键操作后同步；推送触发实时同步是增强项。
- 登录审批 / 设备登录属于一期必做；无推送时通过等待页短时前台轮询和 App 内手动查看待处理请求闭环。
- 一期不做全局后台长轮询。
- 企业证书 / `mTLS` 不纳入一期范围。
- 但一期架构仍建议为后续企业证书 / `mTLS` 扩展保留边界。

### 12.2 仍待逐项确认的关键事项

1. 二期产品路线：
   - 后续是否还会做独立 `Authenticator`。
   - 如果会做，一期架构是否需要提前给 bridge / 独立锁态 / 数据同步边界留口。

### 12.3 当前最需要持续盯住的高风险门槛

- 鸿蒙第三方自动填充 / 凭据 provider 能力的真实边界。
- 鸿蒙第三方 Passkey / password credential provider 能力的真实边界。
- Bitwarden internal SDK 的 Harmony 接入可行性。

这些门槛项不确认清楚，后面的鸿蒙架构设计很容易在系统集成层返工。

## 13. 参考资料

### 13.1 当前仓库内的关键参考

- `settings.gradle.kts`
- `docs/ARCHITECTURE.md`
- `app/src/main/AndroidManifest.xml`
- `app/src/main/kotlin/com/x8bit/bitwarden/MainActivity.kt`
- `app/src/main/kotlin/com/x8bit/bitwarden/ui/platform/feature/rootnav/RootNavViewModel.kt`
- `authenticator/src/main/kotlin/com/bitwarden/authenticator/ui/platform/feature/rootnav/RootNavViewModel.kt`
- `app/src/main/kotlin/com/x8bit/bitwarden/data/platform/manager/BiometricsEncryptionManagerImpl.kt`
- `data/src/main/kotlin/com/bitwarden/data/datasource/disk/di/PreferenceModule.kt`
- `ui/src/main/kotlin/com/bitwarden/ui/platform/theme/BitwardenTheme.kt`

### 13.2 本次查过的 HarmonyOS NEXT 离线参考

- `@ohos.userIAM.userAuth (用户认证)`
- `@ohos.security.huks (通用密钥库系统)`
- `@ohos.app.ability.autoFillManager (自动填充框架)`
- `@ohos.resourceschedule.backgroundTaskManager (后台任务管理)`
- `topics/security/通行密钥`
- `topics/components/TextInput`
- `topics/components/文本组件公共接口`

### 13.3 交叉确认的在线资料

- Bitwarden Password Manager internal SDK：
  - https://contributing.bitwarden.com/architecture/sdk/password-manager/
- HarmonyOS 密码保险箱 / 自动填充相关文档入口：
  - https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/passwordvault-overview
  - https://developer.huawei.com/consumer/cn/doc/harmonyos-guides-V14/passwordvault-autofill-V14
  - https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/passwordvault-adaptation-in-custom-layout
