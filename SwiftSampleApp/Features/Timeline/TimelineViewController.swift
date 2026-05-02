//
//  TimelineViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class TimelineViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: TimelineViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = AppTheme.Color.background
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let refreshControl = UIRefreshControl()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "まだ投稿がありません"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.textColor = AppTheme.Color.textSecondary
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(viewModel: TimelineViewModel) {
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
        title = "LocaSocial"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: nil
        )
        navigationItem.rightBarButtonItem?.tintColor = AppTheme.Color.primary

        tableView.refreshControl = refreshControl
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        tableView.delegate = self
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.posts
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] posts in
                self?.emptyStateLabel.isHidden = !posts.isEmpty
                self?.refreshControl.endRefreshing()
            })
            .bind(to: tableView.rx.items(
                cellIdentifier: PostCell.reuseIdentifier,
                cellType: PostCell.self
            )) { [weak self] _, post, cell in
                cell.configure(post: post, currentUserId: self?.viewModel.currentUserId)
                cell.delegate = self
            }
            .disposed(by: disposeBag)

        navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: viewModel.createTrigger)
            .disposed(by: disposeBag)

        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.refreshTrigger)
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(UserPost.self)
            .subscribe(onNext: { [weak self] post in
                self?.viewModel.steps.accept(AppStep.postDetail(post))
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension TimelineViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - PostCellDelegate

extension TimelineViewController: PostCellDelegate {
    func postCell(_ cell: PostCell, didTapLikeFor postId: String) {
        viewModel.likeTrigger.accept(postId)
    }

    func postCell(_ cell: PostCell, didTapAvatarFor userId: String) {
        viewModel.steps.accept(AppStep.userProfile(userId))
    }
}
