//
//  CardView.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import UIKit
import RxSwift
import RxCocoa

class CardView: UIView {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    let tapGesture = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .darkGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Initialization
    init(title: String, description: String, iconName: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.descriptionLabel.text = description
        self.iconImageView.image = UIImage(systemName: iconName)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        
        // TODO(human): カードのシャドウとインタラクティブな動きを実装
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        // Add tap gesture
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
    }
}

// MARK: - SwiftUI Preview
#if DEBUG
import SwiftUI

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // 単一カードのプレビュー
            CardViewRepresentable(
                title: "予約管理",
                description: "予約の確認・変更ができます",
                iconName: "calendar"
            )
            .frame(height: 80)
            .padding()
            .previewDisplayName("予約カード")
            .previewLayout(.sizeThatFits)
            
            // 複数カードのプレビュー
            VStack(spacing: 16) {
                CardViewRepresentable(
                    title: "予約管理",
                    description: "予約の確認・変更ができます",
                    iconName: "calendar"
                )
                .frame(height: 80)
                
                CardViewRepresentable(
                    title: "お気に入り",
                    description: "お気に入りのサロンを確認",
                    iconName: "heart.fill"
                )
                .frame(height: 80)
                
                CardViewRepresentable(
                    title: "閲覧履歴",
                    description: "最近見たサロンをチェック",
                    iconName: "clock.fill"
                )
                .frame(height: 80)
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .previewDisplayName("カード一覧")
            .previewLayout(.sizeThatFits)
        }
    }
}

struct CardViewRepresentable: UIViewRepresentable {
    let title: String
    let description: String
    let iconName: String
    
    func makeUIView(context: Context) -> CardView {
        return CardView(title: title, description: description, iconName: iconName)
    }
    
    func updateUIView(_ uiView: CardView, context: Context) {
        // 更新処理が必要な場合はここに記述
    }
}
#endif
