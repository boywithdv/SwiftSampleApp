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

    var title: String {
        switch self {
        case .reservation: return "予約管理"
        case .favorite: return "お気に入り"
        case .browsing: return "閲覧履歴"
        }
    }

    var description: String {
        switch self {
        case .reservation: return "予約の確認・変更ができます"
        case .favorite: return "お気に入りのサロンを確認"
        case .browsing: return "最近見たサロンをチェック"
        }
    }

    var iconName: String {
        switch self {
        case .reservation: return "calendar"
        case .favorite: return "heart.fill"
        case .browsing: return "clock.fill"
        }
    }
}
