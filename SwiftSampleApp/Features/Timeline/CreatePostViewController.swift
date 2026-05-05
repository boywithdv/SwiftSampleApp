//
//  CreatePostViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxSwift
import RxCocoa

final class CreatePostViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: CreatePostViewModel
    private let disposeBag = DisposeBag()
    private let maxLength = 300
    private let postButton = UIBarButtonItem(title: "投稿", style: .done, target: nil, action: nil)
    private let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: nil, action: nil)

    // MARK: - UI Components

    private let textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.textColor = AppTheme.Color.textPrimary
        tv.backgroundColor = .clear
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "いまどうしてる？"
        label.font = .systemFont(ofSize: 16)
        label.textColor = AppTheme.Color.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = AppTheme.Color.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    init(viewModel: CreatePostViewModel) {
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
        textView.becomeFirstResponder()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = AppTheme.Color.background
        title = "新しい投稿"

        cancelButton.tintColor = AppTheme.Color.textSecondary
        navigationItem.leftBarButtonItem = cancelButton

        postButton.tintColor = AppTheme.Color.primary
        navigationItem.rightBarButtonItem = postButton

        view.addSubview(textView)
        view.addSubview(placeholderLabel)
        view.addSubview(characterCountLabel)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 150),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 4),

            characterCountLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 8),
            characterCountLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        textView.rx.text.orEmpty
            .bind(to: viewModel.messageRelay)
            .disposed(by: disposeBag)

        textView.rx.text.orEmpty
            .map { !$0.isEmpty }
            .bind(to: placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)

        textView.rx.text.orEmpty
            .map { "\($0.count)/\(self.maxLength)" }
            .bind(to: characterCountLabel.rx.text)
            .disposed(by: disposeBag)

        postButton.rx.tap
            .bind(to: viewModel.submitTrigger)
            .disposed(by: disposeBag)

        cancelButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.isFormValid
            .bind(to: postButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.postSuccess
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
