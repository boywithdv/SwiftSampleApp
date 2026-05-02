//
//  AllChatsViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class AllChatsViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: AllChatsViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = AppTheme.Color.background
        tv.register(ChatConversationCell.self, forCellReuseIdentifier: ChatConversationCell.reuseIdentifier)
        tv.rowHeight = 72
        tv.separatorInset = UIEdgeInsets(top: 0, left: 72, bottom: 0, right: 0)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "チャットはありません"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = AppTheme.Color.textSecondary
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(viewModel: AllChatsViewModel) {
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
        title = "チャット"
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.conversations
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] convs in
                self?.emptyLabel.isHidden = !convs.isEmpty
            })
            .bind(to: tableView.rx.items(
                cellIdentifier: ChatConversationCell.reuseIdentifier,
                cellType: ChatConversationCell.self
            )) { _, item, cell in
                cell.configure(message: item.0, user: item.1)
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected((Message, UserModel?).self)
            .compactMap { $0.1 }
            .subscribe(onNext: { [weak self] user in
                self?.viewModel.selectConversation(user: user)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - ChatConversationCell

final class ChatConversationCell: UITableViewCell {

    static let reuseIdentifier = "ChatConversationCell"

    private let avatarView: AvatarImageView = {
        let view = AvatarImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = AppTheme.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = AppTheme.Color.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let timestampLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = AppTheme.Color.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = AppTheme.Color.background
        accessoryType = .disclosureIndicator

        [avatarView, nameLabel, lastMessageLabel, timestampLabel].forEach {
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            avatarView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.widthAnchor.constraint(equalToConstant: 48),
            avatarView.heightAnchor.constraint(equalToConstant: 48),

            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 4),
            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 12),

            lastMessageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            lastMessageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            timestampLabel.topAnchor.constraint(equalTo: nameLabel.topAnchor),
            timestampLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(message: Message, user: UserModel?) {
        nameLabel.text = user?.displayName ?? "不明なユーザー"
        lastMessageLabel.text = message.message
        let date = Date(timeIntervalSince1970: message.timestamp)
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        timestampLabel.text = formatter.localizedString(for: date, relativeTo: Date())

        if let user {
            avatarView.configure(user: user)
        } else {
            avatarView.configure(photoUrl: nil, initials: "?")
        }
    }
}
