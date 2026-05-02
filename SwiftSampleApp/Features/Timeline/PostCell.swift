//
//  PostCell.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

protocol PostCellDelegate: AnyObject {
    func postCell(_ cell: PostCell, didTapLikeFor postId: String)
    func postCell(_ cell: PostCell, didTapAvatarFor userId: String)
}

final class PostCell: UITableViewCell {

    static let reuseIdentifier = "PostCell"

    // MARK: - UI Components

    private let cardView = SNSCardView()

    private let avatarView: AvatarImageView = {
        let view = AvatarImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = AppTheme.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = AppTheme.Color.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = AppTheme.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        button.tintColor = AppTheme.Color.secondary
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = AppTheme.Color.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Properties

    weak var delegate: PostCellDelegate?
    private var postId: String?
    private var userId: String?
    var disposeBag = DisposeBag()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        [avatarView, usernameLabel, timestampLabel, messageLabel, likeButton, likeCountLabel].forEach {
            cardView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            avatarView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            avatarView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40),

            usernameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor),
            usernameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 8),
            usernameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            timestampLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 2),
            timestampLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),

            messageLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),

            likeButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            likeButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            likeButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 24),

            likeCountLabel.centerYAnchor.constraint(equalTo: likeButton.centerYAnchor),
            likeCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor, constant: 4)
        ])

        likeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self, let postId = self.postId else { return }
                self.delegate?.postCell(self, didTapLikeFor: postId)
            })
            .disposed(by: disposeBag)

        let avatarTap = UITapGestureRecognizer()
        avatarView.addGestureRecognizer(avatarTap)
        avatarView.isUserInteractionEnabled = true
        avatarTap.rx.event
            .subscribe(onNext: { [weak self] _ in
                guard let self, let userId = self.userId else { return }
                self.delegate?.postCell(self, didTapAvatarFor: userId)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Configure

    func configure(post: UserPost, currentUserId: String?) {
        postId = post.postId
        userId = post.userId
        usernameLabel.text = post.username
        timestampLabel.text = post.formattedDate
        messageLabel.text = post.message
        likeCountLabel.text = "\(post.likes.count)"

        let isLiked = currentUserId.map { post.isLikedBy($0) } ?? false
        likeButton.isSelected = isLiked

        avatarView.configure(
            photoUrl: nil,
            initials: String(post.username.prefix(2)).uppercased()
        )
    }
}
