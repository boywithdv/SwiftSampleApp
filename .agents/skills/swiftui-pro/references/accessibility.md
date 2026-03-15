# アクセシビリティ

- フォント・色・アニメーションなどに関するユーザーのアクセシビリティ設定を尊重する。
- 特定のフォントサイズを強制しない。Dynamic Type（`.font(.body)`・`.font(.headline)` など）を優先する。
- カスタムフォントサイズが*必要な*場合、iOS 18 以前をターゲットにするときは `@ScaledMetric` を使用する。iOS 26 以降をターゲットにする場合は `.font(.body.scaled(by:))` もフォントサイズの調整に使用できる。
- 不明瞭または役に立たない VoiceOver の読み上げを持つ画像のインスタンスにフラグを立てる（例：`Image(.newBanner2026)`）。装飾的な場合は `Image(decorative:)` または `accessibilityHidden()` の使用を提案し、そうでない場合は `accessibilityLabel()` を付加する。
- ユーザーが「モーションを減らす」を有効にしている場合、大きなモーションベースのアニメーションをオパシティに置き換える。
- ボタンのラベルが複雑または頻繁に変わる場合、より良い Voice Control コマンドを提供するために `accessibilityInputLabels()` の使用を推奨する。例えば、ボタンが「AAPL $271.68」のようなライブ更新の Apple 株価を持つ場合、"Apple" の入力ラベルを追加することは大きな改善になる。
- 画像ラベルを持つボタンには、テキストが非表示であっても常にテキストを含めなければならない：`Button("Label", systemImage: "plus", action: myAction)`。テキストラベルがないアイコンのみのボタンは VoiceOver に不適切としてフラグを立てる。
- 色がユーザーインターフェースの重要な差別化要素である場合、色だけでなく何らかのバリエーション（アイコン・パターン・ストロークなど）を示すことで、環境の `.accessibilityDifferentiateWithoutColor` 設定を尊重することを確認する。
- `Menu` も同様：`Menu("Options", systemImage: "ellipsis.circle") { }` のように使用することは、画像だけを使うよりはるかに良い。
- タップ位置やタップ数が特に必要な場合を除き、`onTapGesture()` を使用しない。その他のタップ可能な要素はすべて `Button` であるべきである。
- `onTapGesture()` を使用しなければならない場合は、VoiceOver で正しく読み上げられるよう `.accessibilityAddTraits(.isButton)` または同様のものを追加することを確認する。
