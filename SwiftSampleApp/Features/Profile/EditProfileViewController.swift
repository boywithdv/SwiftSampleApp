//
//  EditProfileViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class EditProfileViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: EditProfileViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let displayNameField = AuthTextField(placeholder: "表示名")

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    init(viewModel: EditProfileViewModel) {
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
        title = "プロフィール編集"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "キャンセル", style: .plain, target: self, action: nil
        )
        navigationItem.leftBarButtonItem?.tintColor = AppTheme.Color.textSecondary

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "保存", style: .done, target: self, action: nil
        )
        navigationItem.rightBarButtonItem?.tintColor = AppTheme.Color.primary

        displayNameField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(displayNameField)

        NSLayoutConstraint.activate([
            displayNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            displayNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            displayNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.displayNameRelay
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] name in
                self?.displayNameField.text = name
            })
            .disposed(by: disposeBag)

        displayNameField.rx.text.orEmpty
            .bind(to: viewModel.displayNameRelay)
            .disposed(by: disposeBag)

        navigationItem.rightBarButtonItem?.rx.tap
            .bind(to: viewModel.saveTrigger)
            .disposed(by: disposeBag)

        navigationItem.leftBarButtonItem?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.isFormValid
            .bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.saveSuccess
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                let alert = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
