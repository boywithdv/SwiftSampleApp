//
//  SplashFlow.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI
import RxFlow
import RxSwift
import RxCocoa

final class SplashFlow: Flow {

    var root: Presentable { rootViewController }

    private let rootViewController: UIHostingController<SplashView>
    private let stepper = SplashStepper()

    init() {
        rootViewController = UIHostingController(rootView: SplashView())
        rootViewController.view.backgroundColor = .clear
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .splash:
            return .one(flowContributor: .contribute(
                withNextPresentable: rootViewController,
                withNextStepper: stepper
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

// MARK: - SplashStepper

// NOTE: initialStep を定義してはいけない。
// AppFlow の OneStepper(withSingleStep: .splash) が最初の .splash を発行する。
// ここで initialStep = .splash を定義すると RxFlow が .splash を再発行し、
// ステッパーが多重登録されて navigate(to: .splash) がループする。
private final class SplashStepper: RxFlow.Stepper {
    let steps = PublishRelay<Step>()

    func readyToEmitSteps() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.steps.accept(AuthService.shared.isLoggedIn
                ? AppStep.tabBarIsRequired
                : AppStep.authRequired)
        }
    }
}
