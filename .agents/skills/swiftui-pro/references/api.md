# モダンな SwiftUI API の使用

- `foregroundColor()` の代わりに常に `foregroundStyle()` を使用する。
- `cornerRadius()` の代わりに常に `clipShape(.rect(cornerRadius:))` を使用する。
- `tabItem()` の代わりに常に `Tab` API を使用する。
- `onChange()` モディファイアを1パラメータバリアントで使用しない。2パラメータを受け取るバリアントまたはパラメータなしのバリアントを使用する。
- より新しい代替手段が機能する場合は `GeometryReader` を使用しない：`containerRelativeFrame()`・`visualEffect()`・`Layout` プロトコル。`GeometryReader` の使用にフラグを立て、モダンな代替手段を提案する。
- ハプティックエフェクトを設計する際は、`UIImpactFeedbackGenerator` などの古い UIKit API より `sensoryFeedback()` を優先する。
- `@Entry` マクロを使用してカスタムの `EnvironmentValues`・`FocusValues`・`Transaction`・`ContainerValues` キーを定義する。これは `defaultValue` を持つ（例えば）`EnvironmentKey` に準拠した型を手動で作成し、コンピューテッドプロパティで `EnvironmentValues` を拡張するレガシーパターンを置き換える。
- 非推奨の `overlay(_:alignment:)` より `overlay(alignment:content:)` を強く優先する。例えば、`.overlay(Text("Hello, world!"))` ではなく `.overlay { Text("Hello, world!") }` を使用する。
- ツールバーアイテムの配置に `.navigationBarLeading` と `.navigationBarTrailing` を使用しない。これらは非推奨である。正しいモダンな配置は `.topBarLeading` と `.topBarTrailing` である。
- 英語・フランス語・ドイツ語・ポルトガル語・スペイン語・イタリア語を扱う際は自動文法一致に頼ることを優先する。例えば、`Text("^[\(people) person](inflect: true)")` を使って人数を表示する。
- 2つのチェーンされたモディファイアで図形を塗りつぶしてストロークできる。ストロークにオーバーレイは不要である。以前はオーバーレイが必要だったが、iOS 17 以降で修正されている。
- アセットカタログから画像を参照する際、プロジェクトが生成シンボルアセット API を使用するよう設定されている場合はそれを優先する：`Image("avatar")` ではなく `Image(.avatar)`。
- iOS 26 以降をターゲットにする場合、SwiftUI にはネイティブの `WebView` ビュータイプがあり、`UIViewRepresentable` 内の手動ラップされた `WKWebView` のほぼすべての使用に取って代わる。使用するには `import WebKit` を含めること。
- `enumerated()` シーケンスに対する `ForEach` は先に配列に変換すべきではない。`ForEach(items.enumerated(), id: \.element.id)` を直接使用する。
- スクロールインジケーターを非表示にする場合は、イニシャライザの `showsIndicators: false` ではなく `.scrollIndicators(.hidden)` を使用する。
- `Text` の `+` 連結を絶対に使用しない。

例えば、ここでの `+` の使用は悪く非推奨である：

```swift
Text("Hello").foregroundStyle(.red)
+
Text("World").foregroundStyle(.blue)
```

代わりに、このようにテキスト補間を使用する：

```swift
let red = Text("Hello").foregroundStyle(.red)
let blue = Text("World").foregroundStyle(.blue)
Text("\(red)\(blue)")
```


## ObservableObject の使用

`ObservableObject` の使用が絶対に必要な場合 — 例えば Combine パブリッシャーを使用したデバウンサーを作成する場合 — `import Combine` が追加されていることを常に確認する。以前は SwiftUI を通じて提供されていたが、現在はそうではない。
