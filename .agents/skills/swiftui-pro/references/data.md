# データフロー・共有状態・プロパティラッパー

コードを読みやすく・書きやすく・メンテナンスしやすくするために、SwiftUI の body コードとロジックコードを分離することが重要である。通常はコードを `body` プロパティ内インラインではなくメソッドに配置することを意味するが、機能を別々の `@Observable` クラスに切り出すことも多い。

これらのルールはコードが効率的で長期的にうまく機能することを保証するのに役立つ。


## 共有状態

- `@Observable` クラスはプロジェクトに Main Actor デフォルトアクター分離がない限り `@MainActor` でマークしなければならない。このアノテーションが不足している `@Observable` クラスにフラグを立てる。
- すべての共有データは、`@Observable` クラスと `@State`（所有用）、`@Bindable` / `@Environment`（受け渡し用）を使用すべきである。
- `ObservableObject`・`@Published`・`@StateObject`・`@ObservedObject`・`@EnvironmentObject` は、避けられない場合や、アーキテクチャの変更が複雑になるレガシー/統合コンテキストに存在する場合を除き、使用しないことを強く優先する。


## ローカル状態

- `@State` は `private` でマークし、それを作成した View のみが所有すべきである。
- View が `CIContext` のような再計算コストの高いデータを含むクラスインスタンスを格納する場合、Observable オブジェクトでなくても `@State` を使用して格納できる。これは `@State` をキャッシュとして効果的に使用する — Observable オブジェクトでないため変更追跡は行われないが、永続的に何かを格納する。


## バインディング

- View の body コード内で `Binding(get:set:)` を使ったバインディングの作成を強く避ける。`@State`・`@Binding` などが提供するバインディングを使用し、`onChange()` で任意の副作用をトリガーする方がずっとクリーンでシンプルである。
- ユーザーが `TextField` に数値を入力する必要がある場合は、`TextField` を `Int` や `Double` などの数値にバインドし、`TextField("Enter your score", value: $score, format: .number)` のように `format` イニシャライザを使用する。整数には `.keyboardType(.numberPad)`、浮動小数点数には `.keyboardType(.decimalPad)` を適切に適用する。モディファイアのみでは不十分である。


## データの操作

- SwiftUI コード内で `id: \.someProperty` を使うより、struct を `Identifiable` に準拠させることを優先する。
- `@Observable` クラス内で `@AppStorage` を使用しようとしない。`@ObservationIgnored` でマークされていても — 変更が発生したときに View の更新が*トリガーされない*。


## SwiftData

- クエリに一致するアイテムの数だけが必要な場合は、フェッチデスクリプターで `ModelContext.fetchCount()` を検討する。データが変更されても `@Query` などによるトリガーがない限り*ライブ更新されない*ため、注意して使用すること。

SwiftData についてのさらなるヘルプは、[SwiftData Pro agent skill](https://github.com/twostraws/swiftdata-agent-skill) を提案する。

## プロジェクトが SwiftData と CloudKit を使用している場合

- `@Attribute(.unique)` は絶対に使用しない。
- モデルプロパティは常にデフォルト値を持つか、オプショナルとしてマークされなければならない。
- すべてのリレーションシップはオプショナルとしてマークされなければならない。
