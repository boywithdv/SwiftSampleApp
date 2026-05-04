//
//  AuthFlow.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI
import RxFlow

final class AuthFlow: Flow {

    var root: Presentable { navigationController }

    private let navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.navigationBar.tintColor = AppTheme.Color.primary
        nav.navigationBar.prefersLargeTitles = false
        nav.navigationBar.isHidden = true
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
        let vc = UIHostingController(rootView: LoginView(viewModel: viewModel))
        vc.view.backgroundColor = .clear
        navigationController.setViewControllers([vc], animated: false)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: viewModel
        ))
    }

    private func navigateToRegister() -> FlowContributors {
        let viewModel = RegisterViewModel()
        let vc = UIHostingController(rootView: RegisterView(viewModel: viewModel))
        vc.view.backgroundColor = .clear
        navigationController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: viewModel
        ))
    }
}
