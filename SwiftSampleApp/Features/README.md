# Features ディレクトリ：iOS (MVVM) ガイド

このファイルは `Features/` ディレクトリ直下に作成するファイルと、その役割、さらに Flutter 開発者向けの比較を踏まえた iOS の MVVM 実装ガイドをまとめたものです。

以下は各機能（Feature）で一般に作成するファイルの一覧と、Flutter 側での対応例です。

---

## 1. ファイル構造と各ファイルの役割

推奨ディレクトリ例（Feature 単位）

```text
Features/
├── FeatureName/
│   ├── FeatureFlow.swift        // Flow（RxFlow）
│   ├── FeatureViewController.swift
│   ├── FeatureViewModel.swift
│   ├── FeatureCoordinator.swift? // 必要に応じて（軽量 DI 等）
│   ├── FeatureService.swift     // API / データ取得
│   ├── FeatureModels.swift      // DTO / Model
│   └── Assets/                  // 画面固有のアセット
```

対応する Flutter 構成（概念）

- Storyboard -> Widget の build()
- ViewController -> StatefulWidget / State
- ViewModel -> ChangeNotifier / Bloc / Provider

各ファイルの説明

- FeatureFlow.swift
  - RxFlow の `Flow` を実装するファイル。
  - 画面遷移のまとまりを管理し、`root`（UINavigationController / UITabBarController / UIWindow）を持ちます。
  - `navigate(to:)` 内で `AppStep` を受け取り、遷移を実行します。

- FeatureViewController.swift
  - 画面表示を担当する ViewController。
  - UI の構築、ライフサイクル管理、ViewModel へのバインディングを行います。
  - Flutter の StatefulWidget に相当します。

- FeatureViewModel.swift
  - ビジネスロジックと状態管理を担当。
  - RxSwift（Observable / Relay / Single など）を使って UI とデータをやり取りします。
  - Flutter の ChangeNotifier / Bloc に相当します。

- FeatureService.swift
  - ネットワークリクエストやデータ永続化（Repository 層）を担当。

- FeatureModels.swift
  - API からの DTO、画面で使う Model を定義します。

---

## 2. 典型的な実装フロー（開発手順）

1. 要件定義・画面レイアウト設計
2. ViewModel の設計（状態定義・ユースケース）
3. Service / API クライアント実装
4. ViewController 実装（UI  + バインディング）
5. Flow の実装（FeatureFlow で画面遷移を定義）
6. テスト（ユニット / UI）

---

## 3. 実装テンプレート（コード例）

FeatureFlow の基本テンプレート

```swift
final class FeatureFlow: Flow {
    var root: Presentable {
        return rootViewController
    }

    private let rootViewController: UINavigationController

    init() {
        let vc = FeatureViewController()
        self.rootViewController = UINavigationController(rootViewController: vc)
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .feature:
            return .one(flowContributor: .contribute(withNextPresentable: rootViewController, withNextStepper: OneStepper(withSingleStep: AppStep.feature)))
        default:
            return .none
        }
    }
}
```

ViewController + ViewModel バインディング例

```swift
final class FeatureViewController: UIViewController, Stepper {
    let steps = PublishRelay<Step>()
    private let viewModel: FeatureViewModel
    private let disposeBag = DisposeBag()

    init(viewModel: FeatureViewModel = FeatureViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    private func bind() {
        viewModel.items
            .observe(on: MainScheduler.instance)
            .bind(to: /* UI 更新 */)
            .disposed(by: disposeBag)
    }
}
```

ViewModel の簡易テンプレート

```swift
final class FeatureViewModel: Stepper {
    let steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()

    // 出力
    let items = BehaviorRelay<[Model]>(value: [])

    // 入力
    func load() {
        // API 呼び出しなど
    }
}
```

---

## 4. Flutter 対比（要点）

- UI レイアウト: Flutter の Widget tree ↔ iOS は Storyboard / コードでの View 配置
- 状態管理: Flutter (Provider / Bloc) ↔ iOS (RxSwift を用いた ViewModel)
- DI / サービス注入: Flutter の GetIt ↔ iOS のプロトコルベース DI（またはシングルトン）

---

## 5. 開発のベストプラクティス

- 関心の分離: UI と状態ロジックを明確に分ける
- メモリ管理: Rx の購読解除、weak/unowned の適切な使用
- テスタビリティ: ViewModel をユニットテスト可能に保つ
- 命名規則: `AppStep` は遷移イベントを明確に表す（例: `tabBarIsRequired`, `home`）

---

## 6. 追加のチェックリスト（Feature 作成時）

1. `FeatureFlow.swift` を作成して `navigate(to:)` を用意
2. `FeatureViewController.swift` を作成し `Stepper` を実装
3. `FeatureViewModel.swift` を作成して状態と出力を定義
4. `FeatureService.swift` を作成して API 呼び出しを実装
5. `FeatureModels.swift` に DTO を定義
6. 必要なら Storyboard や XIB を作成（ただし本プロジェクトはコードベースを推奨）

---

必要があれば、このテンプレートに沿ってサンプルの Feature（例: `Favorite`）を私が作成します。どうしますか？
