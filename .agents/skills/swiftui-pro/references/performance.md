# パフォーマンス

- モディファイアの値を切り替える際は、`_ConditionalContent` を避け、構造的アイデンティティを保ち、基となるプラットフォームビューの再作成を繰り返さないように、if/else のビュー分岐より三項式を優先する。
- 絶対に必要な場合を除き `AnyView` を避ける。代わりに `@ViewBuilder`・`Group`・ジェネリクスを使用する。
- `ScrollView` が不透明・静的・ソリッドな背景を持つ場合、スクロールエッジのレンダリング効率を向上させるために `scrollContentBackground(.visible)` を優先する。
- コンピューテッドプロパティやメソッドに配置するよりも、専用の SwiftUI ビューを作成してビューを分割する方が効率的である。プロパティやメソッドに `@ViewBuilder` を使用してもこれは解決されない。ビューの分割を強く優先する。
- View のイニシャライザは可能な限り小さくシンプルに保ち、重要でない作業を避ける。View が表示されたときに実行されるよう `task()` モディファイアに移動できる作業にフラグを立てる。
- 同様に、各 View の `body` プロパティは頻繁に呼び出されると想定する — ソートやフィルタリングなどのロジックを簡単に外に移動できる場合はそうすべきである。
- `DateFormatter` などのフォーマッターを格納するプロパティの作成は、必要でない限り避ける。`Text(Date.now, format: .dateTime.day().month().year())` や `Text(100, format: .currency(code: "USD"))` のように `Text` にフォーマットを付けて使用するのがより自然なアプローチである。
- 頻繁に繰り返される場合の `List`/`ForEach` イニシャライザ内の高コストなインライン変換（例：`items.filter { ... }`）を避ける。
- `let` を使ってソースオブトゥルースから変換済みデータを導出するか、`@State` にキャッシュすることを優先する。ただし、古い UI を避けるための明示的な無効化ロジックがない限り、派生コレクションを `@State` にキャッシュしない。
- `ScrollView` の大きなデータセットには `LazyVStack`/`LazyHStack` を使用する。多くの子を持つイーガースタックにフラグを立てる。
- 非同期作業を行う際は `onAppear()` より `task()` を優先する。View が消えたときに自動的にキャンセルされるためである。
- 可能な場合は View にエスケープする `@ViewBuilder` クロージャを格納しない。代わりにビルドされた View の結果を格納する。

例：

```swift
// アンチパターン: エスケープするクロージャを View に格納する。
struct CardView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        VStack(alignment: .leading) {
            content()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 8))
    }
}

// 推奨: ビルドされた View の値を格納する。合成されたイニシャライザがビルダーの呼び出しを処理する。
struct CardView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading) {
            content
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(.rect(cornerRadius: 8))
    }
}
```
