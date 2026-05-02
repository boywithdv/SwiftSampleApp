//
//  FollowListViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class FollowListViewController: UIViewController {

    enum Mode {
        case followers
        case following
    }

    // MARK: - Properties

    private let viewModel: FollowListViewModel
    private let mode: Mode
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.backgroundColor = AppTheme.Color.background
        tv.separatorStyle = .none
        tv.register(UserSearchCell.self, forCellReuseIdentifier: UserSearchCell.reuseIdentifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Init

    init(viewModel: FollowListViewModel, mode: Mode) {
        self.viewModel = viewModel
        self.mode = mode
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
        title = mode == .followers ? "フォロワー" : "フォロー中"

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.users
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(
                cellIdentifier: UserSearchCell.reuseIdentifier,
                cellType: UserSearchCell.self
            )) { _, user, cell in
                cell.configure(user: user)
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(UserModel.self)
            .subscribe(onNext: { [weak self] user in
                self?.viewModel.selectUser(uid: user.uid)
            })
            .disposed(by: disposeBag)
    }
}
