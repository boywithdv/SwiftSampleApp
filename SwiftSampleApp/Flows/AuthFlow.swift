//
//  AuthFlow.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow
import RxSwift

final class AuthFlow: Flow {

    var root: Presentable {
        return navigationController
    }

    private let navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.navigationBar.tintColor = AppTheme.Color.primary
        nav.navigationBar.prefersLargeTitles = false
        return nav
    }()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .authRequired:
            return navigateToLogin()
        case .showRegister:
            return navigateToRegister()
        case .loginComplete:
            return .end(forwardToParentFlowWithStep: AppStep.loginComplete)
        default:
            return .none
        }
    }

    // MARK: - Navigation

    private func navigateToLogin() -> FlowContributors {
        let viewModel = LoginViewModel()
        let viewController = LoginViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }

    private func navigateToRegister() -> FlowContributors {
        let viewModel = RegisterViewModel()
        let viewController = RegisterViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }
}
