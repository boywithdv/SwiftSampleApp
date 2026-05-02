//
//  SearchViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: SearchViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "ユーザーを検索"
        return sc
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.backgroundColor = AppTheme.Color.background
        tv.register(UserSearchCell.self, forCellReuseIdentifier: UserSearchCell.reuseIdentifier)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Init

    init(viewModel: SearchViewModel) {
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
        title = "検索"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        searchController.searchBar.rx.text.orEmpty
            .bind(to: viewModel.queryRelay)
            .disposed(by: disposeBag)

        viewModel.isSearching
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isSearching in
                isSearching ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
            })
            .disposed(by: disposeBag)

        viewModel.userResults
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
                self?.tableView.deselectRow(at: self?.tableView.indexPathForSelectedRow ?? IndexPath(), animated: true)
            })
            .disposed(by: disposeBag)
    }
}
