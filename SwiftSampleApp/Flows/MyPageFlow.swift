//
//  MyPageFlow.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import UIKit
import RxFlow
import RxSwift

class MyPageFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: UINavigationController
    
    init() {
        let myPageVC = MyPageViewController()
        self.rootViewController = UINavigationController(rootViewController: myPageVC)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .myPage:
            return navigateToMyPage()
        default:
            return .none
        }
    }
    
    private func navigateToMyPage() -> FlowContributors {
        guard let myPageVC = rootViewController.viewControllers.first as? MyPageViewController else {
            return .none
        }
        return .one(flowContributor: .contribute(
            withNextPresentable: myPageVC,
            withNextStepper: myPageVC
        ))
    }
}
