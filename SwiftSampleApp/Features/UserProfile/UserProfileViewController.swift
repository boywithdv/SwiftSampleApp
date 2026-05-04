//
//  UserProfileViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class UserProfileViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: UserProfileViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppTheme.Color.surface
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let avatarView: AvatarImageView = {
        let view = AvatarImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = AppTheme.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = AppTheme.Color.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let statsStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.spacing = 32
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let followersStatView = UIKitStatView(title: "フォロワー")
    private let followingStatView = UIKitStatView(title: "フォロー中")
    private let postsStatView = UIKitStatView(title: "投稿")

    private let followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("フォロー", for: .normal)
        button.setTitle("フォロー中", for: .selected)
        button.backgroundColor = AppTheme.Color.primary
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("メッセージ", for: .normal)
        button.setTitleColor(AppTheme.Color.primary, for: .normal)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = AppTheme.Color.primary.cgColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        let size = (UIScreen.main.bounds.width - 4) / 3
        layout.itemSize = CGSize(width: size, height: size)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = AppTheme.Color.background
        cv.register(PostGridCell.self, forCellWithReuseIdentifier: PostGridCell.reuseIdentifier)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // MARK: - Init

    init(viewModel: UserProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = AppTheme.Color.background

        [postsStatView, followersStatView, followingStatView].forEach {
            statsStack.addArrangedSubview($0)
        }

        [avatarView, nameLabel, emailLabel, statsStack, followButton, messageButton].forEach {
            headerView.addSubview($0)
        }

        view.addSubview(headerView)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            avatarView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            avatarView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 80),
            avatarView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            nameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            statsStack.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
            statsStack.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            followButton.topAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 16),
            followButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            followButton.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.45, constant: -25),
            followButton.heightAnchor.constraint(equalToConstant: 36),
            followButton.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),

            messageButton.topAnchor.constraint(equalTo: followButton.topAnchor),
            messageButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            messageButton.widthAnchor.constraint(equalTo: followButton.widthAnchor),
            messageButton.heightAnchor.constraint(equalTo: followButton.heightAnchor),

            collectionView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 2),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let followersTap = UITapGestureRecognizer()
        followersStatView.addGestureRecognizer(followersTap)
        followersStatView.isUserInteractionEnabled = true
        followersTap.rx.event.map { _ in }.bind(to: viewModel.followersTrigger).disposed(by: disposeBag)

        let followingTap = UITapGestureRecognizer()
        followingStatView.addGestureRecognizer(followingTap)
        followingStatView.isUserInteractionEnabled = true
        followingTap.rx.event.map { _ in }.bind(to: viewModel.followingTrigger).disposed(by: disposeBag)
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.targetUser
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.title = user.displayName
                self?.nameLabel.text = user.displayName
                self?.emailLabel.text = user.email
                self?.avatarView.configure(user: user)
                self?.followersStatView.update(count: user.followers.count)
                self?.followingStatView.update(count: user.following.count)
            })
            .disposed(by: disposeBag)

        viewModel.posts
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] posts in
                self?.postsStatView.update(count: posts.count)
            })
            .bind(to: collectionView.rx.items(
                cellIdentifier: PostGridCell.reuseIdentifier,
                cellType: PostGridCell.self
            )) { _, post, cell in
                cell.configure(post: post)
            }
            .disposed(by: disposeBag)

        viewModel.isFollowing
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isFollowing in
                self?.followButton.isSelected = isFollowing
                self?.followButton.backgroundColor = isFollowing
                    ? UIColor.systemGray4 : AppTheme.Color.primary
            })
            .disposed(by: disposeBag)

        followButton.rx.tap
            .bind(to: viewModel.followTrigger)
            .disposed(by: disposeBag)

        messageButton.rx.tap
            .bind(to: viewModel.messageTrigger)
            .disposed(by: disposeBag)
    }
}
