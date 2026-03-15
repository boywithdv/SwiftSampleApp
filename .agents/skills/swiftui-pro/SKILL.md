---
name: swiftui-pro
description: Comprehensively reviews SwiftUI code for best practices on modern APIs, maintainability, and performance. Use when reading, writing, or reviewing SwiftUI projects.
license: MIT
metadata:
  author: Paul Hudson
  version: "1.0"
---

Swift および SwiftUI のコードを、正確性・モダンな API 使用・プロジェクト規約への準拠の観点でレビューする。本当の問題のみを報告すること — 些細なことを指摘したり、問題を作り出したりしない。

レビュープロセス：

1. `references/api.md` を使って非推奨 API を確認する。
1. `references/views.md` を使って View・モディファイア・アニメーションが最適に書かれているか検証する。
1. `references/data.md` を使ってデータフローが正しく設定されているか確認する。
1. `references/navigation.md` を使ってナビゲーションが最新かつパフォーマンスが良いことを確認する。
1. `references/design.md` を使ってコードがアクセシブルで Apple の Human Interface Guidelines に準拠したデザインになっているか確認する。
1. `references/accessibility.md` を使って Dynamic Type・VoiceOver・Reduce Motion などアクセシビリティへの準拠を検証する。
1. `references/performance.md` を使ってコードが効率的に動作できることを確認する。
1. `references/swift.md` を使って Swift コードを簡易検証する。
1. `references/hygiene.md` を使ってコードの最終的な品質チェックを行う。

部分的なレビューを行う場合は、関連するリファレンスファイルのみを読み込む。


## コア指示

- iOS 26 が存在しており、新規アプリのデフォルトデプロイメントターゲットはこれを使用する。
- Swift 6.2 以降をターゲットにし、モダンな Swift 並行処理を使用する。
- SwiftUI 開発者として、ユーザーは明示的なリクエストがない限り UIKit を避けたいはずである。
- 事前に確認せずにサードパーティフレームワークを導入しない。
- 複数の struct・class・enum を単一ファイルに置くのではなく、型ごとに別々の Swift ファイルに分ける。
- アプリの機能によってフォルダ構造が決まる、一貫したプロジェクト構造を使用する。


## 出力フォーマット

ファイルごとに問題を整理する。各問題について：

1. ファイル名と該当行を記載する。
2. 違反しているルールを明記する（例：「`foregroundColor()` の代わりに `foregroundStyle()` を使用する」）。
3. 簡潔な修正前/修正後のコードを示す。

問題のないファイルはスキップする。最後に、最初に取り組むべき最も影響の大きい変更の優先順位付きサマリーで締めくくる。

出力例：

### ContentView.swift

**12行目: `foregroundColor()` の代わりに `foregroundStyle()` を使用する。**

```swift
// Before
Text("Hello").foregroundColor(.red)

// After
Text("Hello").foregroundStyle(.red)
```

**24行目: アイコンのみのボタンは VoiceOver に不適切 — テストラベルを追加する。**

```swift
// Before
Button(action: addUser) {
    Image(systemName: "plus")
}

// After
Button("Add User", systemImage: "plus", action: addUser)
```

**31行目: View の body 内で `Binding(get:set:)` を使用しない — 代わりに `@State` と `onChange()` を使用する。**

```swift
// Before
TextField("Username", text: Binding(
    get: { model.username },
    set: { model.username = $0; model.save() }
))

// After
TextField("Username", text: $model.username)
    .onChange(of: model.username) {
        model.save()
    }
```

### サマリー

1. **アクセシビリティ（高）:** 24行目の追加ボタンが VoiceOver から見えない。
2. **非推奨 API（中）:** 12行目の `foregroundColor()` を `foregroundStyle()` に変更すべき。
3. **データフロー（中）:** 31行目の手動バインディングは壊れやすくメンテナンスが難しい。

例ここまで。


## リファレンス

- `references/accessibility.md` - Dynamic Type・VoiceOver・Reduce Motion などアクセシビリティ要件。
- `references/api.md` - モダンな API へのコード更新と、それが置き換える非推奨コード。
- `references/design.md` - Apple の Human Interface Guidelines に準拠したアクセシブルなアプリ構築のガイダンス。
- `references/hygiene.md` - コードをクリーンにコンパイルし、長期的にメンテナブルに保つ。
- `references/navigation.md` - `NavigationStack`/`NavigationSplitView` を使ったナビゲーション、アラート・確認ダイアログ・シート。
- `references/performance.md` - SwiftUI コードを最大パフォーマンスに最適化する。
- `references/data.md` - データフロー・共有状態・プロパティラッパー。
- `references/swift.md` - Swift 並行処理の効果的な活用を含む、モダンな Swift コードの書き方のヒント。
- `references/views.md` - View の構造・コンポジション・アニメーション。
