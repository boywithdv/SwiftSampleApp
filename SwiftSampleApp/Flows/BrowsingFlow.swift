//
//  BrowsingFlow.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import UIKit
import RxFlow
import RxSwift

class BrowsingFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: UINavigationController
    
    init() {
        let browsingVC = BrowsingHistoryViewController()
        self.rootViewController = UINavigationController(rootViewController: browsingVC)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .browsing:
            return navigateToBrowsing()
        default:
            return .none
        }
    }
    
    private func navigateToBrowsing() -> FlowContributors {
        guard let browsingVC = rootViewController.viewControllers.first as? BrowsingHistoryViewController else {
            return .none
        }
        return .one(flowContributor: .contribute(
            withNextPresentable: browsingVC,
            withNextStepper: browsingVC
        ))
    }
}
