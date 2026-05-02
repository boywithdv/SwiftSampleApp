//
//  SplashFlow.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

final class SplashFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController: SplashViewController

    init() {
        self.rootViewController = SplashViewController()
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .splash:
            return .one(flowContributor: .contribute(
                withNextPresentable: rootViewController,
                withNextStepper: rootViewController
            ))
        case .authRequired:
            return .end(forwardToParentFlowWithStep: AppStep.authRequired)
        case .tabBarIsRequired:
            return .end(forwardToParentFlowWithStep: AppStep.tabBarIsRequired)
        default:
            return .none
        }
    }
}
