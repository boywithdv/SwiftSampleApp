---
name: "locasocial-expert"
description: "SwiftSampleApp（LocaSocial）専用の実装支援スキル。CLAUDE.mdを自動参照し、UIKit+SwiftUIハイブリッド・RxFlow・Firebase・デザインシステムに沿った実装・レビュー・リファクタリングを行う。Flutterとの対応概念も添えて説明する。"
---

# Skill: LocaSocial Expert（SwiftSampleApp専用）

## 概要

`/Users/usr4100224/swift_develop/SwiftSampleApp` に特化した実装支援スキルです。
以下を提供します:

1. **実装サポート**: LocaSocialのパターンに沿った新機能・修正のコード提案
2. **コードレビュー**: CLAUDE.mdのアーキテクチャ・規約に準拠しているか確認
3. **トラブルシューティング**: RxSwift/RxFlow・Firebase・UIKit/SwiftUI連携の問題を解決
4. **リファクタリング提案**: 既存コードのLocaSocialパターンへの適合

---

## 起動時の必須アクション

**毎回必ず**以下を参照してからタスクに着手すること:

```
/Users/usr4100224/swift_develop/SwiftSampleApp/CLAUDE.md
```

---

## LocaSocial プロジェクト コンテキスト

### 技術スタック

| 技術 | 用途 | Flutter対応概念 |
|---|---|---|
| UIKit + SwiftUI（ハイブリッド） | UI構築 | Widget（StatefulWidget / HookWidget） |
| MVVM | アーキテクチャ | Presentation / Domain分離 |
| RxSwift / RxCocoa | 状態管理・バインディング | Riverpod + Stream |
| RxFlow | 画面遷移（Coordinator） | auto_route |
| Firebase Auth | 認証 | firebase_auth |
| Firebase Firestore | データベース | cloud_firestore |
| Firebase RemoteConfig | 機能フラグ | firebase_remote_config |
| MKMapView | 地図表示 | google_maps_flutter |

### アーキテクチャ 遷移フロー

```
SceneDelegate
  → AppFlow
    → SplashFlow
        → (authRequired)    → AuthFlow → LoginVC / RegisterVC
        → (tabBarRequired)  → TabFlow
                                ├── TimelineFlow  (Tab 0)
                                ├── SwiperFlow    (Tab 1)  ← SwiftUI
                                ├── MapFlow       (Tab 2)
                                ├── SearchFlow    (Tab 3)
                                └── ProfileFlow   (Tab 4)
                                      └── ChatFlow (sub-flow) ← SwiftUI
```

### ディレクトリ規則

| ディレクトリ | 配置するもの |
|---|---|
| `DesignSystem/` | AppTheme, AppTabBarAppearance, UIColor+Hex |
| `Models/` | UserModel, UserPost, Message, Comment（Codable） |
| `Services/` | AuthService, FirestoreService, UserRepository など |
| `Components/` | AvatarImageView, SNSCardView, PrimaryButton など |
| `Flows/` | AppFlow, AuthFlow, TabFlow, 各 FeatureFlow |
| `Features/[機能]/` | ViewController + ViewModel（UIKit）または SwiftUI View |

### SwiftUI HostingVC パターン

Swiper / PostDetail / Chat は SwiftUI で実装。UIKit の Flow から呼び出す際は:
- `SwiperHostingViewController` などが UIKit ラッパー（Stepper）を担う
- SwiftUI側は `@ObservedObject` で ViewModel を参照
- ViewModel は `BaseViewModel` + `ObservableObject` **両方**に準拠する

```swift
// ✅ LocaSocial 標準の HostingVC パターン
final class ChatHostingViewController: UIViewController {
    private let viewModel: ChatViewModel
    
    init(viewModel: ChatViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let chatView = ChatView(viewModel: viewModel)
        let hostingVC = UIHostingController(rootView: chatView)
        addChild(hostingVC)
        view.addSubview(hostingVC.view)
        hostingVC.view.frame = view.bounds
        hostingVC.didMove(toParent: self)
    }
}
```

---

## 実行フロー

### Phase 0: タスクの把握

`AskUserQuestion` で確認すること（自明な場合はスキップ）:
- 実装・レビュー・修正・調査のどれか
- 対象の Flow / Feature / Service
- UIKit画面か SwiftUI画面か（または HostingVC ハイブリッドか）

並行して:
1. `CLAUDE.md` を Read で参照
2. 対象ファイルを Read で読み込む
3. 類似 Feature を grep で探す

---

### Phase 1: UIKit 画面の実装パターン

#### ViewModel（RxSwift）の標準パターン

```swift
// ✅ LocaSocial標準
final class TimelineViewModel: BaseViewModel {
    
    // MARK: - Outputs
    let posts = BehaviorRelay<[UserPost]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Private
    private let postRepository: PostRepository
    private let disposeBag = DisposeBag()
    
    init(postRepository: PostRepository = PostRepository()) {
        self.postRepository = postRepository
        super.init()
    }
    
    // MARK: - Inputs
    func viewDidLoad() {
        fetchPosts()
    }
    
    private func fetchPosts() {
        isLoading.accept(true)
        postRepository.fetchPosts()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                self?.posts.accept(posts)
                self?.isLoading.accept(false)
            }, onError: { [weak self] error in
                self?.isLoading.accept(false)
                // errorSubject は BaseViewModel に定義
            })
            .disposed(by: disposeBag)
    }
}
```

**チェックリスト**:
- `[weak self]` がクロージャ内に存在するか
- `.observe(on: MainScheduler.instance)` でUIスレッドに戻しているか
- `disposed(by: disposeBag)` が付いているか
- `import UIKit` が ViewModel に含まれていないか

#### ViewController の標準パターン

```swift
final class TimelineViewController: UIViewController {
    var viewModel: TimelineViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.viewDidLoad()
    }
    
    private func bindViewModel() {
        viewModel.posts
            .bind(to: tableView.rx.items(
                cellIdentifier: PostCell.identifier,
                cellType: PostCell.self
            )) { _, post, cell in
                cell.configure(with: post)
            }
            .disposed(by: disposeBag)
        
        viewModel.isLoading
            .bind(to: activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
}
```

---

### Phase 2: RxFlow の実装パターン

```swift
// ✅ LocaSocial標準の Flow パターン
final class TimelineFlow: Flow {
    var root: Presentable { rootViewController }
    private lazy var rootViewController = UINavigationController()
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        switch step {
        case .timelineIsRequired:
            return navigateToTimeline()
        case .postDetailIsRequired(let post):
            return navigateToPostDetail(post: post)
        default:
            return .none
        }
    }
    
    private func navigateToTimeline() -> FlowContributors {
        let vm = TimelineViewModel()
        let vc = TimelineViewController()
        vc.viewModel = vm
        rootViewController.setViewControllers([vc], animated: false)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: vm
        ))
    }
    
    private func navigateToPostDetail(post: UserPost) -> FlowContributors {
        let vm = PostDetailViewModel(post: post)
        let vc = PostDetailHostingViewController(viewModel: vm)
        rootViewController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: vm
        ))
    }
}
```

**チェックリスト**:
- `navigate(to:)` の `default: return .none` が抜けていないか
- `FlowContributors` が適切に返されているか
- ViewModel が `Stepper` プロトコルを採用しているか（`steps.accept(AppStep.xxx)` で遷移）

---

### Phase 3: Firebase 連携パターン

#### Firestore Repository パターン

```swift
// ✅ LocaSocial標準
final class PostRepository {
    private let db = Firestore.firestore()
    
    func fetchPosts() -> Observable<[UserPost]> {
        Observable.create { observer in
            let listener = self.db.collection("posts")
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    let posts = snapshot?.documents.compactMap {
                        try? $0.data(as: UserPost.self)
                    } ?? []
                    observer.onNext(posts)
                }
            return Disposables.create { listener.remove() }  // ← 必須
        }
    }
}
```

**重要**: Firestore の `addSnapshotListener` は `Disposables.create { listener.remove() }` でリスナーを解除すること。漏れると無限にコールバックが呼ばれる。

#### Firebase Auth 認証状態の監視

```swift
// ✅ SplashFlow / AppFlow での Auth 状態監視
Auth.auth().addStateDidChangeListener { [weak self] _, user in
    if let user = user {
        self?.steps.accept(AppStep.tabBarIsRequired)
    } else {
        self?.steps.accept(AppStep.authRequired)
    }
}
```

---

### Phase 4: デザインシステム準拠チェック

CLAUDE.mdのデザイントークンが使われているか確認する:

```bash
# AppTheme以外の直接カラー指定を検索
grep -rn "UIColor(red:" SwiftSampleApp/ --include="*.swift"
grep -rn "Color(" SwiftSampleApp/ --include="*.swift" | grep -v "AppTheme\|Color.primary"
```

**判定**:
- AppTheme / DesignSystem 外のカラー直接指定 → `[WARN]`
- ダークモード未対応のハードコードカラー → `[NG]`

---

### Phase 5: 既存スキルとの連携

| ユースケース | 使用するスキル |
|---|---|
| 実装後のコードレビュー | `/swift-impl-reviewer` |
| クラッシュ・バグ調査 | `/swift-troubleshoot-expert` |
| MVVM責務の整合性確認 | `/mvvm-integrity-check` |
| Apple Guidelines チェック | `/apple-quality-auditor` |
| 設計の深掘りインタビュー | `/swift-precise-interviewer` |

---

### Phase 6: 実装提案の出力フォーマット

```
---
## LocaSocial 実装提案

### 対象: [Feature名]
### 画面タイプ: [UIKit / SwiftUI / HostingVC ハイブリッド]

---

### 実装コード

**[ファイル名]** (`SwiftSampleApp/Features/[機能]/[ファイル名].swift`)

\`\`\`swift
// コード
\`\`\`

**配置場所**: `[ディレクトリパス]`
**Xcodeへの追加**: 手動でターゲット追加が必要（.pbxproj 直接編集禁止）

---

### チェックリスト

- [ ] [weak self] + disposed(by:) のRxSwift管理
- [ ] .observe(on: MainScheduler.instance) でUI更新前にメインスレッドに戻す
- [ ] Firestore リスナーを Disposables.create で解除
- [ ] ViewModel に import UIKit なし
- [ ] デザインシステム（AppTheme）のカラートークンを使用
- [ ] Flow の navigate(to:) に default: .none がある

---

### Flutter対応概念（参考）

[Flutterの類似パターンとの対比説明]

---
```

---

## 禁止事項

- `.pbxproj` ファイルへの直接編集
- `CLAUDE.md` を参照せずに実装を提案すること
- デザインシステム（AppTheme）を参照せずにカラーを直接指定すること
- 確認なしにコードを削除・変更すること
- 要求されたスコープ外のファイルを変更すること

---

## 出力言語

- すべての説明・分析は**日本語**で行う
- Flutter対応概念の説明は寿希也のFlutter背景を考慮して添える
- コード・ファイル名・技術用語は英語のまま

---

## トリガー例

```
/locasocial-expert
LocaSocialのこの実装を見て
[機能名]のViewModelを作って
このコードがLocaSocialのパターンに沿っているか確認して
Firebaseとの連携部分をレビューして
```
