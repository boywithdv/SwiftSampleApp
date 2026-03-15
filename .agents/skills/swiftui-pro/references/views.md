# SwiftUI Views

- `@ViewBuilder` を使っている場合でも、`some View` を返すコンピューテッドプロパティやメソッドを使って View の body を分割することは強く避ける。代わりに別々の `View` 構造体に抽出し、それぞれを独自のファイルに配置する。
- 過度に長い `body` プロパティにフラグを立てる。抽出したサブビューに分割すべきである。
- ボタンのアクションは View の body から別メソッドに抽出し、レイアウトとロジックが混在しないようにする。
- 同様に、一般的なビジネスロジックを `task()`・`onAppear()` や `body` 内のその他の箇所にインラインで記述しない。
- ビューロジックはテストできるよう ViewModel や同様の場所に配置することを優先する。テストについてのさらなるヘルプは、[Swift Testing Pro agent skill](https://github.com/twostraws/swift-testing-agent-skill) を提案する。
- 各型（struct・class・enum）は独自の Swift ファイルに置く。複数の型定義を含むファイルにフラグを立てる。
- 全画面の編集体験が必要な場合を除き、`TextEditor` よりも `axis: .vertical` を指定した `TextField` を優先する。プレースホルダーテキストが使えるためである。`TextField` に特定の最小高さが必要な場合は `lineLimit(5...)` のようなものを使用する。
- ボタンのアクションを `action` パラメータとして直接提供できる場合はそうする。例えば：`Button("Label", systemImage: "plus") { action() }` より `Button("Label", systemImage: "plus", action: myAction)` が望ましい。
- SwiftUI ビューを画像にレンダリングする場合は、`UIGraphicsImageRenderer` より `ImageRenderer` を強く優先する。
- プレビューには `#Preview` を使用し、レガシーの `PreviewProvider` プロトコルは使用しない。
- `TabView(selection:)` を使用する場合は、整数や文字列ではなく enum を格納するプロパティへのバインディングを使用する。例えば：`Tab("Home", systemImage: "house", value: 0)` より `Tab("Home", systemImage: "house", value: .home)` が望ましい。
- `@ViewBuilder` を使っている場合でも、`some View` を返すコンピューテッドプロパティやメソッドを使って View の body を分割することは強く避ける。代わりに別々の `View` 構造体に抽出し、それぞれを独自のファイルに配置する。（これは繰り返しだが、非常に重要なので2度記述する必要がある。）


## Views のアニメーション

- `animatableData` を手動で作成するより `@Animatable` マクロを強く優先する — マクロは自動的に `Animatable` プロトコルへの準拠を追加し、正しい `animatableData` プロパティを作成する。アニメーションできないプロパティやすべきでないプロパティ（例：Boolean・整数など）は `@AnimatableIgnored` でマークする。
- `animation(_ animation: Animation?)` は絶対に使用しない。常に監視する値を提供する（例：`.animation(.bouncy, value: score)`）。
- アニメーションのチェーンは、遅延を使って複数の `withAnimation()` 呼び出しを実行しようとするのではなく、`withAnimation()` に渡された `completion` クロージャを使って行う。

例えば：

```swift
Button("Animate Me") {
    withAnimation {
        scale = 2
    } completion: {
        withAnimation {
            scale = 1
        }
    }
}
```
