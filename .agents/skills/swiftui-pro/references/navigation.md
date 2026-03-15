# ナビゲーションとプレゼンテーション

- 適切に `NavigationStack` または `NavigationSplitView` を使用する。非推奨の `NavigationView` の使用にはすべてフラグを立てる。
- デスティネーションの指定には `navigationDestination(for:)` の使用を強く優先する。置き換えるべき古い `NavigationLink(destination:)` パターンの使用にはすべてフラグを立てる。
- 同じナビゲーション階層内で `navigationDestination(for:)` と `NavigationLink(destination:)` を混在させない。重大な問題を引き起こす。
- `navigationDestination(for:)` はデータ型ごとに一度登録しなければならない。重複にフラグを立てる。


## アラート・確認ダイアログ・シート

- `confirmationDialog()` は常にダイアログをトリガーするユーザーインターフェースに付加する。これにより Liquid Glass アニメーションが正しいソースから移動できる。
- アラートにアラートを閉じるだけで何もしない「OK」ボタンが1つだけある場合、完全に省略できる：`.alert("Dismiss Me", isPresented: $isShowingAlert) { }`。
- シートがオプショナルなデータを表示するよう設計されている場合、オプショナルが安全にアンラップされるよう `sheet(isPresented:)` より `sheet(item:)` を優先する。
- `sheet(item:)` を唯一のイニシャライザパラメータとしてアイテムを受け取る View と共に使用する場合、`sheet(item: $someItem) { someItem in SomeView(item: someItem) }` より `sheet(item: $someItem, content: SomeView.init)` を優先する。
