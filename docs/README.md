# RxSwift / Combine 学習ガイド

このドキュメントは SwiftSampleApp の学習画面と連動した、RxSwift・Combine の実践的な学習ガイドです。
**アプリで手を動かしながら読む**ことで理解が深まります。

---

## 学習の進め方

```
STEP 1  なぜリアクティブが必要か？を理解する
   ↓
STEP 2  RxSwift の核心「Observable / Subject」を理解する
   ↓
STEP 3  アプリで RxSwift の演算子を体験する（RxSwift学習タイル）
   ↓
STEP 4  Combine の型を RxSwift と対比しながら理解する
   ↓
STEP 5  アプリで Combine の演算子を体験する（Combine学習タイル）
   ↓
STEP 6  どちらをいつ使うか判断できるようになる
```

---

## STEP 1｜なぜリアクティブが必要か？

### 従来の命令的なコードの問題

UIを作るとき、「状態が変わったら画面を更新する」という処理は必ず発生します。

```swift
// ❌ 命令的な書き方
// テキストが変わるたびにこのメソッドを手動で呼び続けなければならない
func textFieldDidChange(_ textField: UITextField) {
    let emailOK = !(emailField.text?.isEmpty ?? true)
    let passOK  = !(passwordField.text?.isEmpty ?? true)
    loginButton.isEnabled = emailOK && passOK
    // → 条件が増えるたびにここを変更しなければならない
}
```

### リアクティブな書き方

```swift
// ✅ リアクティブな書き方（RxSwift）
Observable.combineLatest(
    emailField.rx.text.map    { !($0 ?? "").isEmpty },
    passwordField.rx.text.map { !($0 ?? "").isEmpty }
)
.map { $0 && $1 }
.bind(to: loginButton.rx.isEnabled)
.disposed(by: disposeBag)

// → 「2つが両方 true のときボタンを有効にする」という意図をそのまま書ける
// → 条件が増えても combineLatest に追加するだけ
```

**Flutter との対比:**
Flutter の `StreamBuilder` や Riverpod の `ref.watch` も同じ発想です。
状態の変化を「購読（watch）」して、変わったときに自動で再描画する。

---

## STEP 2｜RxSwift の核心を理解する

### Observable（観察可能なストリーム）

```
普通の変数：  1つの値をその場で持つ
              let x = 5

Observable：  値が時間とともに流れてくる列
              ───5───3───8───1───▶  (時間軸)
              （Flutter の Stream と同じ概念）
```

### Subject の種類と使い分け

| 型 | 初期値 | 過去の値を流す | 主な用途 |
|---|---|---|---|
| `PublishSubject` | なし | しない | ボタンタップなど単発イベント |
| `BehaviorSubject` | あり | 直前の1つ | 現在の状態（ログイン状態など） |
| `ReplaySubject` | なし | N個まで | 直近の履歴が必要な場合 |

```swift
// PublishSubject：送った後に購読すると何も届かない
let publish = PublishSubject<String>()
publish.onNext("A")              // 購読前なので誰も受け取らない
publish.subscribe(onNext: { print($0) })
publish.onNext("B")              // → "B" だけ届く

// BehaviorSubject：購読した瞬間に現在値が届く
let behavior = BehaviorSubject<String>(value: "初期値")
behavior.subscribe(onNext: { print($0) }) // → "初期値" が即座に届く
behavior.onNext("更新値")                  // → "更新値" が届く
```

### DisposeBag（購読の管理）

```swift
// 購読し続けると메모리リークする
// DisposeBag に入れることで、ViewControllerが解放されると購読も自動解除される
private let disposeBag = DisposeBag()

observable
    .subscribe(onNext: { value in print(value) })
    .disposed(by: disposeBag)  // ← これをつけ忘れない

// Flutter との対比：
// StreamSubscription を cancel() するのと同じ
```

---

## STEP 3｜アプリで RxSwift を体験する

### 🚀 やること
アプリを起動 → ホームタブ → **「RxSwift学習」タイル** をタップ

### map の体験

```swift
// コードの内部処理（RxSwiftLearningViewModel.swift）
mapSubject
    .do(onNext: { value in
        // ← ここでログ出力（副作用。値は変えない）
    })
    .map { $0 * 2 }             // ← 値を変換
    .subscribe(onNext: { result in
        // ← 変換後の値を受け取る
    })
```

**「map を試す」ボタンを押してログを確認:**
```
── map ───────────────────────
🔍[DEBUG]: [map] 入力: 7
🔍[DEBUG]: [map] 出力: 14  (7 × 2)
```
→ `do(onNext:)` は途中で副作用（ログ出力）だけ行い、値は変えずに流す

### filter の体験

```swift
filterSubject
    .do(onNext: { value in /* 入力ログ */ })
    .filter { $0 % 2 == 0 }    // ← 偶数のみ通過、奇数はここで止まる
    .subscribe(onNext: { result in /* 通過ログ */ })
```

**「filter を試す」を何度か押して、奇数のときと偶数のときで出力が変わることを確認**

### combineLatest の体験

```swift
Observable.combineLatest(subject1, subject2)
    .subscribe(onNext: { (v1, v2) in
        // ← 両方の subject が値を持ったときだけここに来る
    })
```

**体験手順:**
1. 「Subject1 発火」だけ押す → **何も出ない**（subject2 がまだ値を持っていないため）
2. 「Subject2 発火」を押す → **結合発火！** 両方の値が届く
3. 「Subject1 発火」をもう一度 → subject2 の**最新値**と即座に結合して発火

### debounce の体験

```swift
debounceSubject
    .do(onNext: { count in /* 受信ログ */ })
    .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
    .subscribe(onNext: { count in /* 発火ログ */ })
```

**体験手順:**
「連打してみて！」を素早く5回押す

```
🔍[DEBUG]: [debounce] 受信 #1  (300ms 待機中...)
🔍[DEBUG]: [debounce] 受信 #2  (300ms 待機中...)
🔍[DEBUG]: [debounce] 受信 #3  (300ms 待機中...)
🔍[DEBUG]: [debounce] 受信 #4  (300ms 待機中...)
🔍[DEBUG]: [debounce] 受信 #5  (300ms 待機中...)
🔍[DEBUG]: [debounce] ✅ 発火! 最終タップ: #5   ← 最後の1つだけ届く
```

---

## STEP 4｜Combine を RxSwift と対比して理解する

### 型の対応表

| 概念 | RxSwift | Combine |
|---|---|---|
| ストリームの型 | `Observable<T>` | `Publisher` (プロトコル) |
| 手動送信（初期値なし） | `PublishSubject<T>` | `PassthroughSubject<T, Never>` |
| 手動送信（初期値あり） | `BehaviorSubject<T>` | `CurrentValueSubject<T, Never>` |
| 値を流す | `.onNext(value)` | `.send(value)` |
| 購読する | `.subscribe(onNext:)` | `.sink(receiveValue:)` |
| 購読を管理する | `DisposeBag` | `Set<AnyCancellable>` |
| 副作用を挟む | `.do(onNext:)` | `.handleEvents(receiveOutput:)` |

### コードの書き方の違い

```swift
// ── RxSwift ──────────────────────────────────
let subject = PublishSubject<Int>()        // 型名が違う
subject.onNext(42)                         // メソッド名が違う

subject
    .filter { $0 > 0 }
    .map { $0 * 2 }
    .subscribe(onNext: { print($0) })      // 購読方法が違う
    .disposed(by: disposeBag)              // 解除方法が違う

// ── Combine ──────────────────────────────────
let subject = PassthroughSubject<Int, Never>()  // 型名が違う
subject.send(42)                                // メソッド名が違う

subject
    .filter { $0 > 0 }                    // ← 演算子は同じ！
    .map { $0 * 2 }                       // ← 演算子は同じ！
    .sink(receiveValue: { print($0) })    // 購読方法が違う
    .store(in: &cancellables)             // 解除方法が違う
```

### @Published は Combine 専用の状態管理

```swift
// RxSwift には @Published はない
// Combine の @Published はプロパティに付けるだけで Publisher になる

class ViewModel: ObservableObject {

    @Published var count: Int = 0   // ← これ自体が Publisher
    //           ↑
    //   $ をつけると Publisher として参照できる
    //   $count → Published<Int>.Publisher 型

}

// 外から購読するとき
viewModel.$count
    .sink { newCount in print(newCount) }
    .store(in: &cancellables)
```

**Combine が SwiftUI と統合できる理由:**
`@Published` が変化すると `objectWillChange` が自動で発火し、
SwiftUI の View が自動的に再描画される。

```
@Published の値が変わる
    ↓
Combine が objectWillChange を発火（自動）
    ↓
SwiftUI が body を再計算して再描画
    ↓
Flutter の setState() / ref.invalidate() に相当
```

---

## STEP 5｜アプリで Combine を体験する

### 🚀 やること
アプリを起動 → ホームタブ → **「Combine学習」タイル** をタップ

### CurrentValueSubject の「初期値」を体験

**画面を開いた瞬間にログが1行出ていることを確認:**
```
🔍[DEBUG]: [CurrentValueSubject] 現在値: "初期値-A"
```
→ 購読した瞬間に現在値が届く（`BehaviorSubject` と同じ挙動）
→ `PassthroughSubject` では画面を開いても何も出ない（初期値がない）

**「値を更新して send()」を押す:**
```
── CurrentValueSubject ─────────
🔍[DEBUG]: [CurrentValueSubject] 現在値: "更新値-B"
```

### PassthroughSubject のパイプラインを体験

```swift
// CombineLearningViewModel.swift の内部処理
passthroughSubject
    .handleEvents(receiveOutput: { value in /* 受信ログ */ })  // RxSwift の .do(onNext:)
    .map { $0 * 3 }
    .handleEvents(receiveOutput: { value in /* map後ログ */ })
    .filter { $0 % 2 == 0 }
    .sink { value in /* 通過ログ */ }
    .store(in: &cancellables)                                   // RxSwift の .disposed(by:)
```

**「send(ランダム値)」を何度か押して、map × 3 → filter（偶数のみ）の流れを確認**

### RxSwift 学習画面と並べて比較する

同じ概念（combineLatest, debounce）でも書き方が違うことを確認:

```swift
// RxSwift
Observable.combineLatest(subject1, subject2)
    .subscribe(onNext: { (v1, v2) in ... })
    .disposed(by: disposeBag)

// Combine
publisher1
    .combineLatest(publisher2)         // ← メソッドチェーンで書く
    .sink(receiveValue: { (v1, v2) in ... })
    .store(in: &cancellables)
```

---

## STEP 6｜どちらをいつ使うか

### 判断フローチャート

```
新しいコードを書くとき
    │
    ├─ iOS 12 以下もサポートする？
    │       YES → RxSwift を使う（Combine は iOS 13〜）
    │       NO  ↓
    │
    ├─ SwiftUI と深く統合したい？
    │       YES → Combine（@Published が SwiftUI とネイティブ連携）
    │       NO  ↓
    │
    ├─ 演算子を豊富に使いたい？（zip, window, throttle など）
    │       YES → RxSwift（演算子の種類が圧倒的に多い）
    │       NO  ↓
    │
    └─ 外部ライブラリを増やしたくない？
            YES → Combine（Apple 純正、追加不要）
            NO  → どちらでも OK
```

### 本アプリでの使い分け

| 処理 | 使用技術 | 理由 |
|---|---|---|
| カードタップを監視 | **RxSwift** (`tapGesture.rx.event`) | UIKit の UIGestureRecognizer に RxCocoa で rx 拡張が使える |
| 画面遷移の発火 | **RxFlow** + `PublishRelay` | RxFlow の Stepper プロトコルが RxSwift ベース |
| ViewModel の状態管理 | **Combine** (`@Published`) | SwiftUI View と自動連携できる |
| SwiftUI の再描画 | **Combine** (`objectWillChange`) | SwiftUI が Combine とネイティブ統合 |

---

## 演算子クイックリファレンス

### 変換系

| 演算子 | 説明 | 例 |
|---|---|---|
| `map` | 値を変換する | `5 → 10`（× 2） |
| `flatMap` | Observable/Publisher を返す変換 | API レスポンスの変換 |
| `compactMap` | nil を除去しながら変換 | `String? → String` |
| `scan` | 累積値を計算する | `[1,2,3] → [1,3,6]`（累計） |

### フィルタ系

| 演算子 | 説明 |
|---|---|
| `filter` | 条件を満たす値のみ通過 |
| `debounce` | 一定時間イベントがなければ発火 |
| `throttle` | 一定時間内の最初 or 最後のみ通過 |
| `distinctUntilChanged` | 前回と同じ値は流さない |
| `take(N)` | 最初の N 個だけ通す |
| `skip(N)` | 最初の N 個を無視する |

### 結合系

| 演算子 | 説明 |
|---|---|
| `combineLatest` | 複数ストリームの最新値を結合（どれかが変わると発火） |
| `zip` | 複数ストリームのペアを結合（順番に対応させる） |
| `merge` | 複数ストリームをそのまま合流 |
| `withLatestFrom` | 別ストリームの最新値を取得して結合 |

---

## よくある間違い

### ① DisposeBag / cancellables を忘れる

```swift
// ❌ これはメモリリークする
observable.subscribe(onNext: { print($0) })

// ✅ 必ず管理する
observable
    .subscribe(onNext: { print($0) })
    .disposed(by: disposeBag)          // RxSwift

subject
    .sink(receiveValue: { print($0) })
    .store(in: &cancellables)           // Combine
```

### ② UIHostingController で @ObservedObject を使う

```swift
// ❌ UIHostingController 内では描画が不安定になることがある
struct MyView: View {
    @ObservedObject var viewModel: MyViewModel
}

// ✅ @StateObject + init で DI する
struct MyView: View {
    @StateObject private var viewModel: MyViewModel
    init(viewModel: MyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}
```

### ③ [weak self] を忘れる

```swift
// ❌ 循環参照でメモリリーク
observable.subscribe(onNext: { _ in
    self.doSomething()
})

// ✅ クロージャ内では [weak self] を使う
observable.subscribe(onNext: { [weak self] _ in
    self?.doSomething()
})
```

---

## Flutter エンジニア向け対応表まとめ

| Flutter / Dart | RxSwift | Combine |
|---|---|---|
| `Stream<T>` | `Observable<T>` | `Publisher` |
| `StreamController` | `PublishSubject` | `PassthroughSubject` |
| `BehaviorSubject` (rxdart) | `BehaviorSubject` | `CurrentValueSubject` |
| `stream.listen()` | `.subscribe(onNext:)` | `.sink(receiveValue:)` |
| `StreamSubscription.cancel()` | `.disposed(by: disposeBag)` | `.store(in: &cancellables)` |
| `stream.map()` | `.map {}` | `.map {}` |
| `stream.where()` | `.filter {}` | `.filter {}` |
| `StateNotifier` | `BehaviorSubject` | `@Published` + `ObservableObject` |
| `ref.watch(provider)` | `.subscribe(onNext:)` | `$published.sink {}` |
| `async/await` | — | — |
| `Future<T>` | `Single<T>` | `Future<T, Error>` |
