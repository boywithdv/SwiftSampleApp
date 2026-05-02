//
//  SplashViewController.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

final class SplashViewController: UIViewController, Stepper {

    // MARK: - Properties

    let steps = PublishRelay<Step>()
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let logoContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let appIconLabel: UILabel = {
        let label = UILabel()
        label.text = "📍"
        label.font = .systemFont(ofSize: 60)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "LocaSocial"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "近くの人とつながろう"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.8)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        startSplashAnimation()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = AppTheme.Color.primaryLight

        [appIconLabel, titleLabel, subtitleLabel, activityIndicator].forEach {
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            appIconLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appIconLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),

            titleLabel.topAnchor.constraint(equalTo: appIconLabel.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            activityIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])

        activityIndicator.startAnimating()
    }

    // MARK: - Animation

    private func startSplashAnimation() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            let isLoggedIn = AuthService.shared.isLoggedIn
            self?.steps.accept(isLoggedIn ? AppStep.tabBarIsRequired : AppStep.authRequired)
        }
    }
}
