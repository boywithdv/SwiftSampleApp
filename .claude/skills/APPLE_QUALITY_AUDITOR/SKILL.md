---
name: "apple-quality-auditor"
description: "SwiftSampleApp（LocaSocial）の実装をApple公式ガイドライン・HIG・ベストプラクティスに照らして監査するスキル。クラッシュリスク・Deprecated API・UIKit/SwiftUIハイブリッド固有の問題・UIの品質をチェックし、Appleらしい美しいUIへの改善提案を行う。"
---

# Skill: Apple Quality Auditor（SwiftSampleApp専用）

## 概要

SwiftSampleApp（LocaSocial）の実装品質をAppleの公式ガイドライン・ドキュメント・ベストプラクティスの観点から総合的に監査します。

プロジェクトルート: `/Users/usr4100224/swift_develop/SwiftSampleApp`

---

## 起動時の必須アクション

毎回 `CLAUDE.md` を Read で参照してからタスクに着手すること:
```
/Users/usr4100224/swift_develop/SwiftSampleApp/CLAUDE.md
```

---

## 実行フロー

### Phase 0: スコープの確認

`AskUserQuestion` で確認する（自明な場合はスキップ）:
- 監査対象（特定ファイル / Feature / プロジェクト全体）
- 重点チェック領域（クラッシュ / UI品質 / パフォーマンス / アクセシビリティ）

---

### Phase 1: クラッシュリスク監査

#### 1-1. Force Unwrap / 強制キャスト

```bash
grep -rn "!\." SwiftSampleApp/ --include="*.swift"
grep -rn "as!" SwiftSampleApp/ --include="*.swift"
```

**判定**:
- `IBOutlet` 以外の `!` アンラップ → `[NG]`
- `as!` の強制キャスト → `[WARN]`

#### 1-2. Main Thread 違反

RxSwift使用プロジェクトのため、UIバインディングで `observeOn(MainScheduler.instance)` が漏れていないか確認する。

```bash
grep -rn "DispatchQueue.global" SwiftSampleApp/ --include="*.swift"
grep -rn "subscribe(on" SwiftSampleApp/ --include="*.swift"
```

SwiftUIコンポーネント（Swiper / PostDetail / Chat）では `@MainActor` 付与が適切かも確認する。

#### 1-3. メモリリーク・循環参照

```bash
grep -rn "\.subscribe(" SwiftSampleApp/ --include="*.swift" | grep -v "disposed(by:"
grep -rn "\.bind(" SwiftSampleApp/ --include="*.swift" | grep -v "disposed(by:"
```

**重点確認**:
- RxSwiftの `subscribe` / `bind` に `disposed(by: disposeBag)` が付いているか
- クロージャ内の `[weak self]` が漏れていないか
- `SwiperHostingViewController` などの HostingVC でのメモリ管理

#### 1-4. Firebase 関連のクラッシュリスク

```bash
grep -rn "FirebaseAuth\|FirebaseFirestore" SwiftSampleApp/ --include="*.swift"
```

- Auth状態の変化をメインスレッドで処理しているか
- Firestore リスナーの `remove()` が `deinit` で呼ばれているか

#### 1-5. Deprecated API 検出

Apple Docs MCPツールで確認する:

```
mcp__apple-docs__search_apple_docs
mcp__apple-docs__get_platform_compatibility
mcp__apple-docs__find_similar_apis
```

**主要な確認対象**:
- `UIScreen.main.bounds` → `UIWindowScene` 経由に移行推奨
- `NavigationView` → `NavigationStack`（iOS 16+）
- `@StateObject` / `@ObservedObject` の使い分け（iOS 17+は `@Observable`）

---

### Phase 2: Apple HIG 準拠チェック

#### 2-1. デザインシステム準拠

CLAUDE.mdのデザイントークンと実装が一致しているか確認する:

| Token | Light | Dark |
|---|---|---|
| Primary | `#01896C` | `#37B6E9` |
| Secondary | `#F45479` | `#8BF8C4` |
| Background | `#F2F2F7` | `#192734` |
| Surface | `#FFFFFF` | `#22303C` |

```bash
# ハードコードされたカラーを検索（AppTheme以外の直接指定）
grep -rn "UIColor(red:" SwiftSampleApp/ --include="*.swift"
grep -rn "#[0-9A-Fa-f]\{6\}" SwiftSampleApp/ --include="*.swift"
```

デザインシステム外のカラーが使われていたら `[WARN]` として報告する。

#### 2-2. UIKit / SwiftUI ハイブリッド固有のチェック

SwiftSampleAppはUIKit+SwiftUIのハイブリッド構成のため、以下を確認する:

**HostingVC パターン（Swiper / PostDetail / Chat）**:
- `BaseViewModel + ObservableObject` を両方採用しているか
- SwiftUI側で `@ObservedObject` で ViewModel を参照しているか
- UIKit側の HostingVC がライフサイクルを正しく管理しているか

```bash
grep -rn "UIHostingController" SwiftSampleApp/ --include="*.swift"
grep -rn "ObservableObject" SwiftSampleApp/ --include="*.swift"
```

#### 2-3. タッチターゲット・レイアウト

```bash
grep -rn "frame = " SwiftSampleApp/ --include="*.swift"  # Auto Layout未使用
grep -rn "safeAreaLayoutGuide" SwiftSampleApp/ --include="*.swift"  # セーフエリア確認
```

**チェック項目**:
- タッチターゲット最低 44×44pt
- セーフエリア: `safeAreaLayoutGuide` を使用しているか
- Auto Layout で frame の手動計算を避けているか

#### 2-4. アクセシビリティ

- `accessibilityLabel` が設定されているか
- 画像に `accessibilityLabel` があるか
- Dynamic Type 対応（`UIFont.preferredFont` または `.font(.body)` 等）

---

### Phase 3: SwiftUI コンポーネントの Apple ベストプラクティス

Apple Docs MCPツールで最新の推奨実装を確認してから判断すること。

**Swiper（カードスワイプ）**:
- ジェスチャー処理が `DragGesture` + `.onEnded` で適切に実装されているか
- アニメーションに `.spring()` / `withAnimation` が使われているか

**PostDetail / Chat（SwiftUI）**:
- `List` / `LazyVStack` の使い分けが適切か
- `task {}` modifier を使っているか（`onAppear` + `async` より推奨）
- `NavigationStack` を使っているか（iOS 16+推奨、`NavigationView` は非推奨）

```bash
grep -rn "NavigationView" SwiftSampleApp/ --include="*.swift"
grep -rn "onAppear {" SwiftSampleApp/ --include="*.swift"
```

---

### Phase 4: パフォーマンス・セキュリティ

#### パフォーマンス

```bash
grep -rn "UIImage(named:" SwiftSampleApp/ --include="*.swift"
grep -rn "reloadData()" SwiftSampleApp/ --include="*.swift"
```

- Map画面（MKMapView）でアノテーション更新が頻繁に `reloadData` を呼んでいないか
- Firebase Firestore のリスナーが不要な更新をトリガーしていないか

#### セキュリティ

```bash
grep -rn "print(" SwiftSampleApp/ --include="*.swift"
grep -rn "UserDefaults" SwiftSampleApp/ --include="*.swift"
```

- `GoogleService-Info.plist` がgit管理されていないか
- 認証トークンを UserDefaults に保存していないか（Keychain 推奨）
- `print()` に機密情報が含まれていないか

---

### Phase 5: RxFlow 遷移フローのチェック

CLAUDE.mdの遷移フローと実装が一致しているか確認する:

```
SceneDelegate → AppFlow → SplashFlow → AuthFlow または TabFlow
```

```bash
grep -rn "class.*Flow:" SwiftSampleApp/ --include="*.swift"
grep -rn "AppStep\." SwiftSampleApp/ --include="*.swift"
```

**チェック項目**:
- 各 Flow が `navigate(to:)` でステップを適切に処理しているか
- `FlowContributors` の返り値が正しいか（`.none` の漏れがないか）
- `Stepper` プロトコルを採用した ViewModel が `steps.accept` を正しく使っているか

---

### Phase 6: 監査レポート出力

```
---
## Apple Quality Audit レポート — SwiftSampleApp (LocaSocial)

### 対象: [ファイル名 / Feature名]
### 実行日: [日付]

---

## 🔴 Critical（即時修正が必要）
- [NG] [ファイル名:行番号] 内容

## 🟡 Warning（早期対応推奨）
- [WARN] [ファイル名:行番号] 内容

## 🟢 Improvement（Apple品質向上提案）
- [INFO] 内容

## ✅ Passed
- 内容

---

## Apple HIG 適合スコア

| カテゴリ | スコア | コメント |
|---|---|---|
| クラッシュ安全性 | x/5 | |
| HIG準拠 | x/5 | |
| UIKit/SwiftUI連携 | x/5 | |
| パフォーマンス | x/5 | |
| モダンAPI使用 | x/5 | |

---

## 推奨アクション（優先順位順）
1. [最優先] ...
2. [高] ...
3. [中] ...

---
```

---

## 判定アイコン

| アイコン | 意味 |
|---|---|
| `[NG]` | 修正必須（クラッシュ・ガイドライン違反） |
| `[WARN]` | 要対応（非推奨API・品質低下リスク） |
| `[INFO]` | 改善提案（Appleらしさの向上） |
| `[OK]` | 問題なし |

---

## 禁止事項

- Apple Docs MCP ツールを使わずに Deprecated 情報を断言すること
- `.pbxproj` ファイルへの直接編集
- 確認なしのコード変更
- デザインシステム（AppTheme）を参照せずにカラーを提案すること

---

## トリガー例

```
/apple-quality-auditor
実装がAppleのガイドラインに沿っているか確認して
クラッシュしそうな箇所を調べて
UIがAppleらしいか見て
HIGに準拠しているかチェックして
```
