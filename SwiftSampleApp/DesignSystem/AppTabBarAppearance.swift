//
//  AppTabBarAppearance.swift
//  SwiftSampleApp
//

import UIKit

enum AppTabBarAppearance {
    static func configure() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppTheme.Color.surface

        let normalAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemGray
        ]
        let selectedAttr: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppTheme.Color.primary
        ]

        appearance.stackedLayoutAppearance.normal.iconColor   = .systemGray
        appearance.stackedLayoutAppearance.selected.iconColor = AppTheme.Color.primary
        appearance.stackedLayoutAppearance.normal.titleTextAttributes   = normalAttr
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttr

        UITabBar.appearance().standardAppearance   = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor            = AppTheme.Color.primary
    }
}
