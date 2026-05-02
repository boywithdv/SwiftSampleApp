//
//  ProfileViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class ProfileViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: ProfileViewModel
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

    private let displayNameLabel: UILabel = {
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

    private let statsStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalSpacing
        sv.spacing = 32
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let postsStatView = StatView(title: "投稿")
    private let followersStatView = StatView(title: "フォロワー")
    private let followingStatView = StatView(title: "フォロー中")

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

    init(viewModel: ProfileViewModel) {
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
        title = "プロフィール"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain, target: self, action: nil
        )
        navigationItem.rightBarButtonItem?.tintColor = AppTheme.Color.primary

        let chatButton = UIBarButtonItem(
            image: UIImage(systemName: "message"),
            style: .plain, target: self, action: nil
        )
        chatButton.tintColor = AppTheme.Color.primary

        let logoutButton = UIBarButtonItem(
            image: UIImage(systemName: "rectangle.portrait.and.arrow.right"),
            style: .plain, target: self, action: nil
        )
        logoutButton.tintColor = AppTheme.Color.secondary

        navigationItem.leftBarButtonItems = [logoutButton, chatButton]

        statsStackView.addArrangedSubview(postsStatView)
        statsStackView.addArrangedSubview(followersStatView)
        statsStackView.addArrangedSubview(followingStatView)

        [avatarView, displayNameLabel, emailLabel, statsStackView].forEach {
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

            displayNameLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 12),
            displayNameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            emailLabel.topAnchor.constraint(equalTo: displayNameLabel.bottomAnchor, constant: 4),
            emailLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),

            statsStackView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 16),
            statsStackView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            statsStackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16),

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

        navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: viewModel.editTrigger)
            .disposed(by: disposeBag)

        chatButton.rx.tap
            .bind(to: viewModel.chatsTrigger)
            .disposed(by: disposeBag)

        logoutButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showLogoutConfirmation()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.currentUser
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.displayNameLabel.text = user.displayName
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
    }

    // MARK: - Logout Confirmation

    private func showLogoutConfirmation() {
        let alert = UIAlertController(title: "ログアウト", message: "ログアウトしますか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel))
        alert.addAction(UIAlertAction(title: "ログアウト", style: .destructive) { [weak self] _ in
            self?.viewModel.logoutTrigger.accept(())
        })
        present(alert, animated: true)
    }
}

// MARK: - Helper Views

final class StatView: UIView {
    private let countLabel = UILabel()
    private let titleLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)
        countLabel.font = .systemFont(ofSize: 20, weight: .bold)
        countLabel.textColor = AppTheme.Color.textPrimary
        countLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = AppTheme.Color.textSecondary
        titleLabel.textAlignment = .center

        let sv = UIStackView(arrangedSubviews: [countLabel, titleLabel])
        sv.axis = .vertical
        sv.spacing = 2
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sv)
        NSLayoutConstraint.activate([
            sv.topAnchor.constraint(equalTo: topAnchor),
            sv.leadingAnchor.constraint(equalTo: leadingAnchor),
            sv.trailingAnchor.constraint(equalTo: trailingAnchor),
            sv.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func update(count: Int) {
        countLabel.text = "\(count)"
    }
}

final class PostGridCell: UICollectionViewCell {
    static let reuseIdentifier = "PostGridCell"

    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.font = .systemFont(ofSize: 11)
        label.textColor = AppTheme.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = AppTheme.Color.surface
        contentView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(post: UserPost) {
        textLabel.text = post.message
    }
}
