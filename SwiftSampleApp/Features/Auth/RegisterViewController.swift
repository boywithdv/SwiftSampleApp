//
//  RegisterViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class RegisterViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: RegisterViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "アカウント作成"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = AppTheme.Color.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let displayNameField = AuthTextField(placeholder: "表示名（ニックネーム）")
    private let emailField = AuthTextField(placeholder: "メールアドレス", keyboardType: .emailAddress)
    private let passwordField = AuthTextField(placeholder: "パスワード（6文字以上）", isSecure: true)
    private let confirmPasswordField = AuthTextField(placeholder: "パスワード（確認）", isSecure: true)

    private let registerButton = PrimaryButton(title: "アカウントを作成")

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Init

    init(viewModel: RegisterViewModel) {
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.tintColor = AppTheme.Color.primary
        title = ""
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = AppTheme.Color.background

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [titleLabel, displayNameField, emailField, passwordField, confirmPasswordField,
         registerButton, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),

            displayNameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 32),
            displayNameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            displayNameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            emailField.topAnchor.constraint(equalTo: displayNameField.bottomAnchor, constant: 12),
            emailField.leadingAnchor.constraint(equalTo: displayNameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: displayNameField.trailingAnchor),

            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),

            confirmPasswordField.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 12),
            confirmPasswordField.leadingAnchor.constraint(equalTo: passwordField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: passwordField.trailingAnchor),

            registerButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 24),
            registerButton.leadingAnchor.constraint(equalTo: displayNameField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: displayNameField.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor),

            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        displayNameField.rx.text.orEmpty
            .bind(to: viewModel.displayNameRelay)
            .disposed(by: disposeBag)

        emailField.rx.text.orEmpty
            .bind(to: viewModel.emailRelay)
            .disposed(by: disposeBag)

        passwordField.rx.text.orEmpty
            .bind(to: viewModel.passwordRelay)
            .disposed(by: disposeBag)

        confirmPasswordField.rx.text.orEmpty
            .bind(to: viewModel.confirmPasswordRelay)
            .disposed(by: disposeBag)

        registerButton.rx.tap
            .bind(to: viewModel.registerTrigger)
            .disposed(by: disposeBag)

        viewModel.isFormValid
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.isFormValid
            .map { $0 ? 1.0 : 0.5 }
            .bind(to: registerButton.rx.alpha)
            .disposed(by: disposeBag)

        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.activityIndicator.startAnimating() : self?.activityIndicator.stopAnimating()
                self?.registerButton.setTitle(isLoading ? "" : "アカウントを作成", for: .normal)
                self?.registerButton.isEnabled = !isLoading
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
