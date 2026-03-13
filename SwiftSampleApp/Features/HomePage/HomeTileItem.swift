//
//  HomeTileItem.swift
//  SwiftSampleApp
//
//  Created by 佃 寿希也 on 2026/03/12.
//

/// ホーム画面のタイル種別を定義するenum
enum HomeTileItem {
    case reservation
    case favorite
    case browsing
    case rxSwiftLearning
    case combineLearning
    case rxSwiftStateFlow

    var title: String {
        switch self {
        case .reservation: return "予約管理"
        case .favorite: return "お気に入り"
        case .browsing: return "閲覧履歴"
        case .rxSwiftLearning: return "RxSwift学習"
        case .combineLearning: return "Combine学習"
        case .rxSwiftStateFlow: return "状態フロー可視化"
        }
    }

    var description: String {
        switch self {
        case .reservation: return "予約の確認・変更ができます"
        case .favorite: return "お気に入りのサロンを確認"
        case .browsing: return "最近見たサロンをチェック"
        case .rxSwiftLearning: return "演算子の動きをログで確認"
        case .combineLearning: return "Apple純正フレームワークを体験"
        case .rxSwiftStateFlow: return "Relayの値がSubscriberへ流れる様子を可視化"
        }
    }

    var iconName: String {
        switch self {
        case .reservation: return "calendar"
        case .favorite: return "heart.fill"
        case .browsing: return "clock.fill"
        case .rxSwiftLearning: return "waveform"
        case .combineLearning: return "dot.radiowaves.left.and.right"
        case .rxSwiftStateFlow: return "arrow.triangle.pull"
        }
    }
}
