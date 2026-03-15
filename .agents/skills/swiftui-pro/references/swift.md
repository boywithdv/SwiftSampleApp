# Swift

- Foundation の同等メソッドより Swift ネイティブの文字列メソッドを優先する：`replacingOccurrences(of: "a", with: "b")` ではなく `replacing("a", with: "b")` を使用する。
- モダンな Foundation API を優先する：`FileManager` のディレクトリ検索の代わりに `URL.documentsDirectory`、URL に文字列を追加する際は `appending(path:)` を使用する。
- `String(format: "%.2f", value)` のような C スタイルの数値フォーマットは絶対に使用しない。`Text(value, format: .number.precision(.fractionLength(2)))` のような `FormatStyle` API を使用する。
- 可能な場合は構造体インスタンスよりスタティックメンバルックアップを優先する：`Circle()` ではなく `.circle`、`BorderedProminentButtonStyle()` ではなく `.borderedProminent` のように。
- 失敗が本当に回復不可能な場合を除き、強制アンラップ（`!`）や強制 `try` を避ける。その場合でも明確な説明と共に `fatalError()` を優先する。可能なら `if let`・`guard let`・nil合体演算子・`try?`/`do-catch` を使用する。
- ユーザー入力に基づくテキストのフィルタリングは、`contains()` や `localizedCaseInsensitiveContains()` ではなく `localizedStandardContains()` を使用する。
- オプショナルや `inout` を使う場合を除き、`CGFloat` より `Double` を強く優先する。Swift はその2つのケース以外では両者を自由にブリッジできる。
- 述語に一致する配列要素を数える場合は、`filter()` に続く `count` ではなく常に `count(where:)` を使用する。
- 明確さのために `Date()` より `Date.now` を優先する。
- ファイルに既に `import SwiftUI` がある場合、`UIImage` や `NSImage` などにアクセスするために `import UIKit` や `import AppKit` を追加する必要はない — 適切なプラットフォームで自動的にインポートされる。
- 人物の名前を扱う際は、`Text("\(firstName) \(lastName)")` のような単純な文字列補間より、モダンなフォーマットを使った `PersonNameComponents` を強く優先する。
- 特定のデータ型が同一のクロージャで繰り返しソートされる場合（例：`books.sorted { $0.author < $1.author }`）、ソート順が一元化されるよう対象の型を `Comparable` に準拠させることを優先する。
- 可能であれば手動の日付フォーマット文字列を避ける。ユーザー表示のために手動の日付フォーマットを*使う必要がある*場合は、すべてのロケールで年の値が正しくなるよう "yyyy" ではなく "y" を使用する。API とのデータ交換が目的の場合、このルールは適用されない。
- 文字列を日付に変換する場合は、`Date(myString, strategy: .iso8601)` のようなモダンな `Date` イニシャライザ API を優先する。
- ユーザーアクションによって引き起こされたエラーが `print(error.localizedDescription)` の使用などによって黙って握り潰されているインスタンスにフラグを立てる。アラートや同様の方法で表示すること。
- `if let value = value {` より `if let value {` の短縮形を優先する。
- 単一式関数では return を省略する。値を返すときや変数に代入するとき、`if` と `switch` を式として使用できる。

例えば、このようなコードは：

```swift
var tileColor: Color {
    if isCorrect {
        return .green
    } else {
        return .red
    }
}
```

このように書くべきである：

```swift
var tileColor: Color {
    if isCorrect {
        .green
    } else {
        .red
    }
}
```


## Swift 並行処理

- API がモダンな `async`/`await` 版と古いクロージャベースの版の両方を提供している場合、常に `async`/`await` 版を優先する。
- Grand Central Dispatch（`DispatchQueue.main.async()`・`DispatchQueue.global()` など）は絶対に使用しない。常にモダンな Swift 並行処理（`async`/`await`・actor・`Task`）を使用する。
- `Task.sleep(nanoseconds:)` は使用しない。代わりに `Task.sleep(for:)` を使用する。
- actor または `@MainActor` で保護されていない変更可能な共有状態にフラグを立てる（プロジェクトが MainActor デフォルトアクター分離を使用するよう設定されている場合を除く）。
- 厳格な並行処理ルールが適用されていると想定する。`@Sendable` 違反とデータ競合にフラグを立てる。
- `MainActor.run()` を評価する際は、プロジェクトのデフォルトアクター分離が Main Actor に設定されているか先に確認する。`MainActor.run()` が不要な場合があるため。
- `Task.detached()` は多くの場合良くない選択である。使用箇所を非常に慎重にチェックする。

Swift 並行処理についてのさらなるヘルプは、[Swift Concurrency Pro agent skill](https://github.com/twostraws/swift-concurrency-agent-skill) を提案する。
