# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

美容サロン向けサンプルiOSアプリ。UIKitをコードベース（Storyboard不使用）で構築し、RxFlowで画面遷移を管理する。

## ビルド・実行コマンド

```bash
# Xcodeでプロジェクトを開く
open SwiftSampleApp.xcodeproj

# コマンドラインからビルド
xcodebuild -scheme SwiftSampleApp -destination 'platform=iOS Simulator,name=iPhone 16'

# テスト実行
xcodebuild test -scheme SwiftSampleApp -destination 'platform=iOS Simulator,name=iPhone 16'
```

## 依存パッケージ（Swift Package Manager）

- **RxFlow** 2.13.2 — 画面遷移のCoordinator管理
- **RxSwift** 6.10.1 — リアクティブプログラミング（RxCocoa含む）

パッケージはXcodeのSPMで管理。CocoaPodsではない。

## アーキテクチャ

### RxFlow による画面遷移パターン

アプリ全体の遷移は **Flow + Step + Stepper** の3要素で構成される。

- **`AppStep`** (`Flows/AppStep.swift`): 全画面遷移のステップを定義する単一のenum
- **Flow**: 各画面フローの遷移ロジックを定義。`navigate(to:)` で `AppStep` を受け取り `FlowContributors` を返す
- **Stepper**: ViewControllerが `Stepper` プロトコルに準拠し、`steps: PublishRelay<Step>` 経由で遷移を発火

### 遷移フロー

```
SceneDelegate → AppFlow → SplashFlow → (splashComplete) → TabFlow
                                                             ├── HomeFlow
                                                             ├── BrowsingFlow
                                                             ├── ReservationFlow
                                                             ├── FavoriteFlow
                                                             └── MyPageFlow
```

- `SceneDelegate` が `FlowCoordinator` を初期化し `AppFlow` を起動
- `AppFlow` のrootは `UIWindow`（NavigationControllerではない）
- `SplashFlow` 完了時に `.end(forwardToParentFlowWithStep:)` で親フローへステップを返す
- `TabFlow` が `UITabBarController` を生成し、5つの子Flowを `.multiple` で登録

### 新しい画面を追加する手順

1. `AppStep` に新しいcaseを追加
2. `Features/` 配下に ViewController を作成（UIKit コードベース、`Stepper` 準拠）
3. `Flows/` 配下に対応する Flow を作成
4. 親 Flow の `navigate(to:)` に遷移処理を追加

## ディレクトリ構成

```
SwiftSampleApp/
├── Flows/          # RxFlow の Flow・Step 定義
├── Features/       # 画面ごとの ViewController
│   ├── Splash/
│   ├── RootTabBar/Home/
│   ├── BrowsingHistory/
│   ├── Reservation/
│   ├── Favorite/
│   └── MyPage/
├── Components/     # 再利用可能なUIコンポーネント（CardView等）
├── Services/       # サービス層（未実装）
├── Data/           # データ層（未実装）
├── Protocols/      # プロトコル定義（未実装）
├── Common/         # 共通ユーティリティ（未実装）
└── Configs/        # 設定（未実装）
```

## コーディング規約

- UIはすべてコードベースで構築。`translatesAutoresizingMaskIntoConstraints = false` + `NSLayoutConstraint.activate` パターンを使用
- ViewControllerは `// MARK: -` セクション（Properties, UI Components, Lifecycle, UI Setup, Bindings）で整理
- メモリ管理: Flow内のクロージャでは `[weak self]` を使用。`DisposeBag` で RxSwift のサブスクリプションを管理
- UIコンポーネントのプレビューには `#if DEBUG` + SwiftUI `UIViewRepresentable` ラッパーを使用
