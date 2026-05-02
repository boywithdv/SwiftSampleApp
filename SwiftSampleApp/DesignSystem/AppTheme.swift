//
//  AppTheme.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI

enum AppTheme {
    enum Color {
        // Primary brand colors
        static let primaryLight = UIColor(hex: "#01896C")
        static let primaryDark  = UIColor(hex: "#37B6E9")

        // Secondary accent
        static let secondaryLight = UIColor(hex: "#F45479")
        static let secondaryDark  = UIColor(hex: "#8BF8C4")

        // Backgrounds
        static let backgroundLight = UIColor(hex: "#F2F2F7")
        static let backgroundDark  = UIColor(hex: "#192734")

        // Surfaces (cards)
        static let surfaceLight = UIColor.white
        static let surfaceDark  = UIColor(hex: "#22303C")

        // Text
        static let textPrimaryLight   = UIColor(hex: "#1C1C1E")
        static let textPrimaryDark    = UIColor.white
        static let textSecondaryLight = UIColor(hex: "#8A8A8E")
        static let textSecondaryDark  = UIColor(hex: "#8A8A8E")

        static func primary(for traitCollection: UITraitCollection) -> UIColor {
            traitCollection.userInterfaceStyle == .dark ? primaryDark : primaryLight
        }

        static func secondary(for traitCollection: UITraitCollection) -> UIColor {
            traitCollection.userInterfaceStyle == .dark ? secondaryDark : secondaryLight
        }

        static func background(for traitCollection: UITraitCollection) -> UIColor {
            traitCollection.userInterfaceStyle == .dark ? backgroundDark : backgroundLight
        }

        static func surface(for traitCollection: UITraitCollection) -> UIColor {
            traitCollection.userInterfaceStyle == .dark ? surfaceDark : surfaceLight
        }

        static func textPrimary(for traitCollection: UITraitCollection) -> UIColor {
            traitCollection.userInterfaceStyle == .dark ? textPrimaryDark : textPrimaryLight
        }

        // Dynamic UIColor (automatically adapts to system appearance)
        static let primary = UIColor { trait in
            trait.userInterfaceStyle == .dark ? primaryDark : primaryLight
        }
        static let secondary = UIColor { trait in
            trait.userInterfaceStyle == .dark ? secondaryDark : secondaryLight
        }
        static let background = UIColor { trait in
            trait.userInterfaceStyle == .dark ? backgroundDark : backgroundLight
        }
        static let surface = UIColor { trait in
            trait.userInterfaceStyle == .dark ? surfaceDark : surfaceLight
        }
        static let textPrimary = UIColor { trait in
            trait.userInterfaceStyle == .dark ? textPrimaryDark : textPrimaryLight
        }
        static let textSecondary = UIColor { trait in
            trait.userInterfaceStyle == .dark ? textSecondaryDark : textSecondaryLight
        }
    }

    enum Spacing {
        static let xs: CGFloat  = 4
        static let sm: CGFloat  = 8
        static let md: CGFloat  = 16
        static let lg: CGFloat  = 24
        static let xl: CGFloat  = 32
        static let xxl: CGFloat = 48
    }

    enum CornerRadius {
        static let card: CGFloat   = 16
        static let button: CGFloat = 12
        static let avatar: CGFloat = 20  // half of 40pt avatar
        static let small: CGFloat  = 8
    }

    enum Shadow {
        static let cardOpacity: Float  = 0.08
        static let cardRadius: CGFloat = 8
        static let cardOffset = CGSize(width: 0, height: 2)
    }
}

// SwiftUI color extensions
extension Color {
    static let appPrimary    = Color(uiColor: AppTheme.Color.primary)
    static let appSecondary  = Color(uiColor: AppTheme.Color.secondary)
    static let appBackground = Color(uiColor: AppTheme.Color.background)
    static let appSurface    = Color(uiColor: AppTheme.Color.surface)
    static let appTextPrimary   = Color(uiColor: AppTheme.Color.textPrimary)
    static let appTextSecondary = Color(uiColor: AppTheme.Color.textSecondary)
}
