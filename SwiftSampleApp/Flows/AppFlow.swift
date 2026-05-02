//
//  AppFlow.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift

final class AppFlow: Flow {

    private let window: UIWindow

    var root: Presentable {
        return self.window
    }

    init(window: UIWindow) {
        self.window = window
        AppTabBarAppearance.configure()
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .splash:
            return navigateToSplash()
        case .authRequired, .logoutComplete:
            return navigateToAuth()
        case .loginComplete, .tabBarIsRequired:
            return navigateToTabBar()
        default:
            return .none
        }
    }

    // MARK: - Navigation

    private func navigateToSplash() -> FlowContributors {
        let splashFlow = SplashFlow()
        Flows.use(splashFlow, when: .created) { [weak self] root in
            self?.window.rootViewController = root
        }
        return .one(flowContributor: .contribute(
            withNextPresentable: splashFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.splash)
        ))
    }

    private func navigateToAuth() -> FlowContributors {
        let authFlow = AuthFlow()
        Flows.use(authFlow, when: .created) { [weak self] root in
            UIView.transition(with: self!.window, duration: 0.3, options: .transitionCrossDissolve) {
                self?.window.rootViewController = root
            }
        }
        return .one(flowContributor: .contribute(
            withNextPresentable: authFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.authRequired)
        ))
    }

    private func navigateToTabBar() -> FlowContributors {
        let tabFlow = TabFlow()
        Flows.use(tabFlow, when: .created) { [weak self] root in
            UIView.transition(with: self!.window, duration: 0.3, options: .transitionCrossDissolve) {
                self?.window.rootViewController = root
            }
        }
        return .one(flowContributor: .contribute(
            withNextPresentable: tabFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.tabBarIsRequired)
        ))
    }
}
