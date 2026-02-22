//
//  AppStep.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import RxFlow

/// アプリケーション全体で使用するステップを定義する列挙型
/// 各フローや画面遷移で使用されるステップをここに追加してください。
enum AppStep: Step {
    // アプリケーション起動時の初期フロー
    case splash
    
    // スプラッシュ画面完了後の遷移
    case splashComplete
    
    // タブバーへの遷移
    case tabBar
    case tabBarIsRequired
    
    // 各タブの遷移
    case home
    case browsing
    case reservation
    case favorite
    case myPage
}
