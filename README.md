# SwiftSampleApp

美容サロン向けサンプル iOS アプリ。
UIKit (コードベース) + SwiftUI + RxFlow + RxSwift の組み合わせで構築されている。

---

## 目次

1. [技術スタック](#技術スタック)
2. [アーキテクチャ全体図](#アーキテクチャ全体図)
3. [画面遷移フロー (RxFlow)](#画面遷移フロー-rxflow)
4. [UIKit ↔ SwiftUI ブリッジパターン](#uikit--swiftui-ブリッジパターン)
5. [RxSwift データ表示の仕組み](#rxswift-データ表示の仕組み)
6. [演算子ごとのデータフロー](#演算子ごとのデータフロー)
7. [ディレクトリ構成](#ディレクトリ構成)
8. [ビルド方法](#ビルド方法)

---

## 技術スタック

| ライブラリ | バージョン | 役割 |
|---|---|---|
| RxFlow | 2.13.2 | 画面遷移の Coordinator 管理 |
| RxSwift / RxCocoa | 6.10.1 | リアクティブプログラミング |
| SwiftUI | — | 詳細画面の UI 構築 |
| UIKit | — | タブバー・ホーム画面の UI 構築 |
| Combine | — | ObservableObject / @Published によるバインディング |

パッケージ管理は **Swift Package Manager (SPM)** を使用。

---

## アーキテクチャ全体図

```mermaid
graph TD
    subgraph Entry["起動"]
        SD[SceneDelegate]
        FC[FlowCoordinator]
    end

    subgraph Flows["RxFlow レイヤー"]
        AF[AppFlow]
        SF[SplashFlow]
        TF[TabFlow]
        HF[HomeFlow]
    end

    subgraph UIKit["UIKit レイヤー"]
        RTBC[RootTabBarController]
        HomeVC["HomeViewController\n(Stepper 準拠)"]
    end

    subgraph Bridge["UIKit ↔ SwiftUI ブリッジ"]
        TDHVC["TileDetailHostingViewController\n(UIHostingController)"]
        RLHVC["RxSwiftLearningHostingViewController\n(UIHostingController)"]
    end

    subgraph SwiftUI["SwiftUI レイヤー"]
        TDV[TileDetailView]
        RLV[RxSwiftLearningView]
    end

    subgraph VM["ViewModel レイヤー"]
        TDVM["TileDetailViewModel\n(ObservableObject + Stepper)"]
        RLVM["RxSwiftLearningViewModel\n(ObservableObject + Stepper)"]
    end

    SD --> FC
    FC --> AF
    AF --> SF
    SF -->|splashComplete| TF
    TF --> RTBC
    RTBC --> HF
    HF --> HomeVC
    HomeVC -->|"steps.accept(.tileDetail)"| HF
    HF -->|push| TDHVC
    HF -->|push| RLHVC
    TDHVC -->|rootView| TDV
    RLHVC -->|rootView| RLV
    TDV <-->|"@StateObject"| TDVM
    RLV <-->|"@StateObject"| RLVM
```

---

## 画面遷移フロー (RxFlow)

ユーザー操作から画面が push されるまでのシーケンス。

```mermaid
sequenceDiagram
    actor User
    participant HomeVC as HomeViewController<br/>(Stepper)
    participant RxFlow as FlowCoordinator<br/>(RxFlow 内部)
    participant HomeFlow as HomeFlow
    participant HostingVC as HostingViewController
    participant VM as ViewModel<br/>(Stepper)

    User->>HomeVC: カードをタップ
    HomeVC->>HomeVC: tapGesture.rx.event で検知
    HomeVC->>RxFlow: steps.accept(.tileDetail(.rxSwiftLearning))
    RxFlow->>HomeFlow: navigate(to: .tileDetail(.rxSwiftLearning))
    HomeFlow->>VM: RxSwiftLearningViewModel() を生成
    HomeFlow->>HostingVC: RxSwiftLearningHostingViewController(viewModel:) を生成
    HomeFlow->>HomeFlow: rootViewController.pushViewController(vc, animated: true)
    HomeFlow->>RxFlow: .one(.contribute(presentable: vc, stepper: vm)) を返す
    Note over RxFlow: HostingVC と VM を次の<br/>Presentable / Stepper として登録
```

### AppStep の全遷移一覧

```mermaid
graph LR
    splash --> splashComplete
    splashComplete --> tabBar
    tabBar --> home
    tabBar --> browsing
    tabBar --> reservation
    tabBar --> favorite
    tabBar --> myPage
    home -->|"tileDetail(.reservation)"| TD1[TileDetailView\n予約管理]
    home -->|"tileDetail(.favorite)"| TD2[TileDetailView\nお気に入り]
    home -->|"tileDetail(.browsing)"| TD3[TileDetailView\n閲覧履歴]
    home -->|"tileDetail(.rxSwiftLearning)"| RLD[RxSwiftLearningView]
```

---

## UIKit ↔ SwiftUI ブリッジパターン

SwiftUI 画面を UIKit の NavigationController に push するために
`UIHostingController` をラッパー (玄関口) として使う。

```mermaid
graph LR
    subgraph UIKit世界
        NavC[UINavigationController]
        HVC["HostingViewController\n(UIHostingController&lt;SomeView&gt;)"]
    end

    subgraph SwiftUI世界
        V["SomeView\n(SwiftUI struct)"]
        VM["SomeViewModel\n(ObservableObject + Stepper)"]
    end

    NavC -->|push| HVC
    HVC -->|rootView として保持| V
    V <-->|"@StateObject\n双方向バインディング"| VM
    VM -->|"steps.accept(AppStep)"| RxFlow[RxFlow\n画面遷移実行]
```

### `@ObservedObject` vs `@StateObject`

`UIHostingController` 経由で SwiftUI View を使う場合、`@ObservedObject` では UIKit のライフサイクルとズレてデータが表示されないことがある。`@StateObject` を使うことで View が ViewModel を所有し、安定して描画される。

| | `@ObservedObject` | `@StateObject` |
|---|---|---|
| オブジェクトの所有 | しない（外部が保持） | View が所有 |
| UIHostingController との相性 | ❌ 再描画が不安定になる場合あり | ✅ 安定 |
| 外から DI する方法 | `var viewModel: VM` で受け取る | `_viewModel = StateObject(wrappedValue: vm)` |

```swift
// 正しいパターン（UIHostingController 使用時）
struct SomeView: View {
    @StateObject private var viewModel: SomeViewModel

    init(viewModel: SomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
```

Flutter の Riverpod との対比:

| Swift | Flutter (Riverpod) |
|---|---|
| `@StateObject` | `StateNotifierProvider`（Provider が所有） |
| `@ObservedObject` | `ref.watch` で外部参照するだけ |
| `@Published` | `state` の変更通知 |
| `ObservableObject` | `StateNotifier` / `AsyncNotifier` |

---

## RxSwift データ表示の仕組み

ボタン押下からログがコンソールに表示されるまでの全体フロー。

```mermaid
sequenceDiagram
    actor User
    participant View as RxSwiftLearningView<br/>(SwiftUI)
    participant VM as RxSwiftLearningViewModel<br/>(ObservableObject)
    participant Subject as RxSwift Subject<br/>(PublishSubject / BehaviorSubject)
    participant Op as RxSwift 演算子<br/>(map / filter / debounce...)
    participant Logger as os.Logger

    User->>View: ボタンをタップ
    View->>VM: viewModel.triggerMap() などを呼び出す
    VM->>Subject: subject.onNext(value) でイベントを流す
    Subject->>Op: do(onNext:) → 演算子を適用
    Op->>VM: subscribe(onNext:) のクロージャを実行
    VM->>Logger: log.debug("🔍[DEBUG]: ...")
    VM->>VM: logMessages.append(LogEntry)\n@Published を更新
    VM-->>View: Combine が変更を自動通知\n(objectWillChange)
    View->>View: ForEach(logMessages) で再描画
    Note over View: 新しいログがコンソールに追加表示
```

### レイヤー別の責務

```mermaid
graph TD
    subgraph View["View (SwiftUI) — 描画のみ"]
        BTN[ボタン]
        CON[ログコンソール]
    end

    subgraph VM["ViewModel (ObservableObject) — ロジックと状態管理"]
        PUB["@Published logMessages: [LogEntry]"]
        ACT["trigger〇〇() メソッド"]
        EMT["emit() — ログ追記 + Logger 出力"]
    end

    subgraph Rx["RxSwift ストリーム — データ変換"]
        SBJ["Subject\n(PublishSubject / BehaviorSubject)"]
        OPS["演算子\n.map / .filter / .debounce / combineLatest"]
        SUB["subscribe(onNext:)"]
    end

    BTN -->|タップ| ACT
    ACT -->|onNext| SBJ
    SBJ --> OPS
    OPS --> SUB
    SUB --> EMT
    EMT --> PUB
    PUB -->|Combine で自動通知| CON
```

---

## 演算子ごとのデータフロー

### map — 値を変換する

入力値を別の値に変換して流す。本アプリではランダムな整数を × 2 にする。

```mermaid
graph LR
    BTN[ボタンタップ] -->|"Int.random(1〜20)"| SBJ["PublishSubject&lt;Int&gt;"]
    SBJ -->|"do: 入力をログ出力"| DO["do(onNext:)"]
    DO -->|"$0 × 2"| MAP["map { $0 * 2 }"]
    MAP -->|変換後の値| SUB["subscribe(onNext:)"]
    SUB -->|"出力をログ出力"| LOG[ログコンソール]
```

**ログ出力例:**
```
── map ───────────────────────
🔍[DEBUG]: [map] 入力: 7
🔍[DEBUG]: [map] 出力: 14  (7 × 2)
```

---

### filter — 条件でフィルタリング

条件を満たす要素のみを下流に流す。本アプリでは偶数のみ通過させる。

```mermaid
graph LR
    BTN[ボタンタップ] -->|"Int.random(1〜20)"| SBJ["PublishSubject&lt;Int&gt;"]
    SBJ -->|"do: 入力と偶数判定をログ出力"| DO["do(onNext:)"]
    DO -->|"$0 % 2 == 0 ?"| FLT["filter { $0 % 2 == 0 }"]
    FLT -->|偶数のみ通過| SUB["subscribe(onNext:)"]
    FLT -->|奇数は破棄| DEAD["❌ ここで止まる"]
    SUB -->|"通過ログを出力"| LOG[ログコンソール]
```

**ログ出力例（偶数の場合）:**
```
── filter ────────────────────
🔍[DEBUG]: [filter] 入力: 8  偶数? → ✅ 通過
🔍[DEBUG]: [filter] ↳ ダウンストリームへ: 8
```

**ログ出力例（奇数の場合）:**
```
── filter ────────────────────
🔍[DEBUG]: [filter] 入力: 5  偶数? → ❌ 除外
```

---

### combineLatest — 複数ストリームを結合

**2つのストリームが両方とも値を持ったとき**に結合して発火する。
どちらか片方だけでは発火しない点がポイント。

```mermaid
sequenceDiagram
    participant U as User
    participant S1 as "BehaviorSubject1<br/>(初期値: nil)"
    participant S2 as "BehaviorSubject2<br/>(初期値: nil)"
    participant CL as combineLatest
    participant LOG as ログコンソール

    U->>S1: Subject1 発火ボタン
    S1->>CL: "Stream-A(1)" を emit
    Note over CL: S2 がまだ nil → 発火しない

    U->>S2: Subject2 発火ボタン
    S2->>CL: "Stream-B(1)" を emit
    CL->>LOG: ✅ 結合発火: "Stream-A(1)" + "Stream-B(1)"

    U->>S1: Subject1 発火ボタン（2回目）
    S1->>CL: "Stream-A(2)" を emit
    Note over CL: S2 の最新値 "Stream-B(1)" と即座に結合
    CL->>LOG: ✅ 結合発火: "Stream-A(2)" + "Stream-B(1)"
```

**ログ出力例:**
```
🔍[DEBUG]: [combineLatest] Subject1 ← "Stream-A(1)"
  （S2 がまだ nil のため発火しない）

🔍[DEBUG]: [combineLatest] Subject2 ← "Stream-B(1)"
🔍[DEBUG]: [combineLatest] ✅ 結合発火: "Stream-A(1)" + "Stream-B(1)"
```

---

### debounce — 連続イベントを間引く

指定した時間 (300ms) 以内に連続してイベントが来ても、最後の 1 つだけ下流に流す。
検索ボックスの入力補完や連打防止によく使われる。

```mermaid
sequenceDiagram
    participant U as "User（連打）"
    participant SBJ as "PublishSubject&lt;Int&gt;"
    participant DBC as "debounce<br/>(300ms, MainScheduler)"
    participant SUB as subscribe
    participant LOG as ログコンソール

    U->>SBJ: タップ #1
    SBJ->>DBC: 1 を emit
    DBC->>LOG: 🔍[DEBUG]: 受信 #1 (300ms 待機中...)
    Note over DBC: タイマーリセット

    U->>SBJ: タップ #2（100ms 後）
    SBJ->>DBC: 2 を emit
    DBC->>LOG: 🔍[DEBUG]: 受信 #2 (300ms 待機中...)
    Note over DBC: タイマーリセット

    U->>SBJ: タップ #3（100ms 後）
    SBJ->>DBC: 3 を emit
    DBC->>LOG: 🔍[DEBUG]: 受信 #3 (300ms 待機中...)
    Note over DBC: 300ms 経過（連打なし）

    DBC->>SUB: 3 だけ emit（最後の値のみ下流へ）
    SUB->>LOG: 🔍[DEBUG]: ✅ 発火! 最終タップ: #3
```

**ログ出力例（3 連打した場合）:**
```
── debounce ──────────────────
🔍[DEBUG]: [debounce] 受信 #1  (300ms 待機中...)
── debounce ──────────────────
🔍[DEBUG]: [debounce] 受信 #2  (300ms 待機中...)
── debounce ──────────────────
🔍[DEBUG]: [debounce] 受信 #3  (300ms 待機中...)
🔍[DEBUG]: [debounce] ✅ 発火! 最終タップ: #3
```

---

## ディレクトリ構成

```
SwiftSampleApp/
├── Flows/
│   ├── AppStep.swift                             # 全遷移ステップの enum
│   ├── AppFlow.swift
│   ├── SplashFlow.swift
│   ├── TabFlow.swift
│   ├── HomeFlow.swift                            # タイル詳細・RxSwift学習への遷移を管理
│   ├── BrowsingFlow.swift
│   ├── FavoriteFlow.swift
│   ├── MyPageFlow.swift
│   └── ReservationFlow.swift
├── Features/
│   ├── Splash/
│   │   └── SplashViewController.swift
│   ├── RootTabBar/Home/
│   │   └── HomeViewController.swift             # タイルタップで steps を発火
│   ├── HomePage/
│   │   ├── HomeTileItem.swift                   # タイル種別 enum
│   │   ├── TileDetailViewModel.swift            # 汎用タイル詳細 ViewModel
│   │   ├── TileDetailView.swift                 # 汎用タイル詳細 View (SwiftUI)
│   │   ├── TileDetailHostingViewController.swift
│   │   ├── RxSwiftLearningViewModel.swift       # 演算子デモ ViewModel
│   │   ├── RxSwiftLearningView.swift            # 演算子ボタン + ログコンソール (SwiftUI)
│   │   └── RxSwiftLearningHostingViewController.swift
│   ├── BrowsingHistory/
│   ├── Favorite/
│   ├── MyPage/
│   └── Reservation/
└── Components/
    └── CardView.swift                           # ホーム画面のタイルカード (UIKit)
```

---

## ビルド方法

```bash
# Xcode でプロジェクトを開く
open SwiftSampleApp.xcodeproj

# コマンドラインからビルド
xcodebuild -scheme SwiftSampleApp -destination 'platform=iOS Simulator,name=iPhone 16'

# テスト実行
xcodebuild test -scheme SwiftSampleApp -destination 'platform=iOS Simulator,name=iPhone 16'
```
