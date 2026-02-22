
# Flows と AppStep の説明

このディレクトリには RxFlow を使った画面遷移の単位（Flow）と、遷移を表す列挙子（AppStep）が置かれています。

### Flow（〇〇Flow）とは

Flow はアプリ内の「画面遷移のまとまり」を表すクラスです。

例: `SplashFlow`, `TabFlow`, `HomeFlow` など。各 Flow は `Flow` プロトコルを実装し、`root`（Presentable）と `navigate(to:)` を提供します。

Flow の責務はその領域内での ViewController の生成・配置と、受け取った Step に応じた遷移の実行です。

Flow 内では、サブ Flow（別タブや別機能）を `Flows.use(...)` で組み合わせ、`FlowContributors` を返すことで次の Flow / Step に処理を渡します。

使い方のポイント:

- `root` は通常 `UINavigationController` や `UITabBarController`、あるいは `UIWindow` を返します。
- `navigate(to:)` 内で `guard let step = step as? AppStep` として自分が扱える Step のみ処理します。
- 新しいタブや画面を追加する場合は、まず `〇〇Flow` を作成して `TabFlow` に登録します。

### AppStep とは

`AppStep` は RxFlow の `Step` を採用した列挙型で、アプリ内の遷移イベントを表現します。

命名規約の例:

- `xxxIsRequired` サフィックスは「遷移要求」を表すことが多い（例: `tabBarIsRequired`）。
- 単純な状態や到達点は短い名前で表す（例: `home`, `splash`）。

`AppStep` を追加したら、該当する Flow の `navigate(to:)` と、遷移を発行する `Stepper`（ViewController や ViewModel）側のコードも更新してください。

例（簡易マッピング）:

- `AppStep.splash` → `SplashFlow` がスプラッシュを表示
- スプラッシュ内で処理完了後 `steps.accept(AppStep.splashComplete)` を送出 → `SplashFlow` は親フローへ `tabBarIsRequired` をフォワード
- `AppFlow` が `tabBarIsRequired` を受け取り `TabFlow` を起動 → `TabFlow` がタブ構成（`HomeFlow` 等）をセット

### 実装上の注意点

- シーンベース（iOS 13+）のプロジェクトでは `SceneDelegate` 側で `AppFlow` を起動し、`window` を使って `rootViewController` を設定する必要があります。
- `Stepper` を実装するオブジェクト（ViewController / ViewModel）は、自身が発行する `Step` の型と Flow の `switch` ケースが一致するようにしてください。
- Flow や Step 名が不整合だと遷移が反応せず、白画面や期待どおりの遷移にならない原因になります。

必要なら、`TabFlow` に複数タブを追加する具体例（`FavoriteFlow`, `MyPageFlow` など）をこちらで実装します。希望があれば教えてください。

