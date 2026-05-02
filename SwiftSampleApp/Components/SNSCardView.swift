//
//  SNSCardView.swift
//  SwiftSampleApp
//

import UIKit

class SNSCardView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = AppTheme.Color.surface
        layer.cornerRadius = AppTheme.CornerRadius.card
        applyShadow()
    }

    private func applyShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = AppTheme.Shadow.cardOpacity
        layer.shadowRadius = AppTheme.Shadow.cardRadius
        layer.shadowOffset = AppTheme.Shadow.cardOffset
        layer.masksToBounds = false
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        backgroundColor = AppTheme.Color.surface(for: traitCollection)
        applyShadow()
    }
}
