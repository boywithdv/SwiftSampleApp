# Apple Skills 利用ガイド（日本語）

このドキュメントは、`.github/skills` に取り込んだ Apple Skills を「何ができるか」「どんな時に使うか」で素早く判断するための早見表です。

## まず覚える使い分け

- APIの使い方を調べたい: `framework系` スキル（例: `swiftui`, `uikit`）
- 設計・見た目の判断をしたい: `design系` スキル（例: `hig`, `ios-design-consultant`）
- 実装手順や改善フローを進めたい: `guide系` スキル
- 開発補助をしたい: `utilities系` スキル（例: `simulator-utils`, `apple-docs-index`）

## Framework Reference（APIリファレンス）

### UI・画面

| スキル | 主な用途 | 使うタイミング |
|---|---|---|
| `swiftui` | SwiftUIのView/レイアウト/状態管理/API参照 | 画面実装・修正時に正しいSwiftUI APIを確認したい時 |
| `uikit` | UIView/UIViewController/Auto Layout/遷移 | UIKit画面や制約まわりを実装・修正する時 |
| `mapkit` | SwiftUI Map, Marker, Annotation, カメラ制御 | 地図表示・ピン表示・地図操作を実装する時 |
| `photosui` | PhotosPickerなど写真選択UI | 画像選択フローを追加する時 |
| `widgetkit` | ウィジェットのTimeline/Provider/Entry | ホーム・ロック画面ウィジェットを作る時 |

### データ・非同期・テスト

| スキル | 主な用途 | 使うタイミング |
|---|---|---|
| `swift-concurrency` | async/await, Task, Actor, AsyncSequence | 非同期処理や並行処理を安全に書きたい時 |
| `combine` | Publisher/Subscriber/Operator | 既存Combine処理の実装や読解が必要な時 |
| `swiftdata` | @Model, ModelContext, @Query, マイグレーション | SwiftDataで永続化を設計・更新する時 |
| `swift-testing` | Swift Testing（`@Test`, `#expect`） | XCTestから移行、または新規テストを作る時 |
| `xcuitest` | UIテスト要素取得/待機/検証パターン | E2E/UIテストを安定化したい時 |

### Apple機能連携

| スキル | 主な用途 | 使うタイミング |
|---|---|---|
| `appintents` | Siri/Shortcuts/Spotlight連携 | アプリ機能をショートカット公開したい時 |
| `storekit` | 課金・購読（StoreKit 2） | IAP/サブスク導線を実装する時 |
| `healthkit` | HealthKitの読み書き | ヘルスデータ連携を実装する時 |
| `usernotifications` | ローカル/リモート通知 | 通知許諾・配信トリガーを扱う時 |
| `eventkit` | カレンダー/リマインダー | 予定追加・同期機能を作る時 |
| `backgroundtasks` | BGTaskScheduler, バックグラウンド実行 | 定期更新や重い処理をバックグラウンド化する時 |
| `tipkit` | ヒントUI（TipKit） | ユーザー向けガイド吹き出しを追加する時 |
| `corehaptics` | 触覚フィードバック生成 | 体験向上のためにハプティクスを入れる時 |

## Design & Guidelines（設計・デザイン）

| スキル | 主な用途 | 使うタイミング |
|---|---|---|
| `hig` | Apple HIG準拠の判断材料 | UI方針がAppleらしいか確認したい時 |
| `ios-liquid-glass` | iOS 26+のLiquid Glass APIリファレンス | Glass表現を実装する時 |
| `ios-design-consultant` | UX/視覚階層/配置の相談（コードなし） | どのレイアウトが適切か判断したい時 |
| `ios-dev` | 高品質SwiftUI UI実装ガイド | 画面を作る・作り直す時 |

## Workflow & Pattern Guides（実践ガイド）

| スキル | 主な用途 | 使うタイミング |
|---|---|---|
| `guide-swiftui-performance-audit` | SwiftUI描画性能の監査・改善 | カクつき、CPU高負荷、再描画過多を疑う時 |
| `guide-swiftui-ui-patterns` | SwiftUI画面構成のベストプラクティス | 新規画面の設計や共通パターン化をしたい時 |
| `guide-swiftui-view-refactor` | View分割、依存注入、Observation整理 | View肥大化・責務過多を解消したい時 |
| `guide-macos-spm-packaging` | SwiftPMベースmacOSアプリの配布手順 | XcodeプロジェクトなしでmacOS配布をしたい時 |

## Utilities（開発補助）

| スキル | 主な用途 | 使うタイミング |
|---|---|---|
| `apple-docs-index` | Apple公式ドキュメント索引 | まず何を調べるべきか迷う時 |
| `simulator-utils` | シミュレータ操作・スクリーンショット | UI確認画像の取得やデバイス操作をしたい時 |
| `apple-aso` | App Storeメタデータ最適化 | ストア文言（タイトル/説明/キーワード）を改善する時 |
| `ios-app-icon` | App Icon生成ワークフロー | アイコンを新規作成・刷新する時 |
| `ios-app-assets` | アプリ内アセット生成 | タブアイコン・イラスト等を整備する時 |
| `ui-percept-rapid-feedback` | UI品質の高速フィードバック | 見た目品質を短い反復で改善したい時 |

## SwiftSampleApp でのおすすめ優先順

このリポジトリは UIKit + RxFlow が中心のため、次の順で使うと効果的です。

1. `uikit`
2. `hig`
3. `swift-concurrency`
4. `xcuitest`
5. `apple-docs-index`

SwiftUI画面を増やす場合は、次を追加してください。

1. `swiftui`
2. `guide-swiftui-ui-patterns`
3. `guide-swiftui-view-refactor`
4. `guide-swiftui-performance-audit`

## 補足

- これらのSkillsは「最新Apple API寄り（iOS 26+/Swift 6）」の前提です。
- 既存コードが古いAPIでも、必要に応じて後方互換方針を追加して使えます。