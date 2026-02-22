//
//  SplashFlow.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
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
            return navigateToSplash()
        case .splashComplete:
            return .end(forwardToParentFlowWithStep: AppStep.tabBarIsRequired)
        default:
            return .none
        }
    }
    
    private func navigateToSplash() -> FlowContributors {
        return .one(flowContributor: .contribute(
            withNextPresentable: rootViewController,
            withNextStepper: rootViewController
        ))
    }
}
