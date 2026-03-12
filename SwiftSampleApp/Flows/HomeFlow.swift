//
//  HomeFlow.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import UIKit
import RxFlow
import RxSwift

class HomeFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: UINavigationController
    
    init() {
        let homeVC = HomeViewController()
        self.rootViewController = UINavigationController(rootViewController: homeVC)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .home:
            return navigateToHome()
        case .tileDetail(let item):
            return navigateToTileDetail(item: item)
        default:
            return .none
        }
    }

    private func navigateToHome() -> FlowContributors {
        guard let homeVC = rootViewController.viewControllers.first as? HomeViewController else {
            return .none
        }
        return .one(flowContributor: .contribute(
            withNextPresentable: homeVC,
            withNextStepper: homeVC
        ))
    }

    private func navigateToTileDetail(item: HomeTileItem) -> FlowContributors {
        switch item {
        case .rxSwiftLearning:
            return navigateToRxSwiftLearning()
        case .combineLearning:
            return navigateToCombineLearning()
        default:
            let viewModel = TileDetailViewModel(item: item)
            let viewController = TileDetailHostingViewController(viewModel: viewModel)
            rootViewController.pushViewController(viewController, animated: true)
            return .one(flowContributor: .contribute(
                withNextPresentable: viewController,
                withNextStepper: viewModel
            ))
        }
    }

    private func navigateToRxSwiftLearning() -> FlowContributors {
        let viewModel = RxSwiftLearningViewModel()
        let viewController = RxSwiftLearningHostingViewController(viewModel: viewModel)
        rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }

    private func navigateToCombineLearning() -> FlowContributors {
        let viewModel = CombineLearningViewModel()
        let viewController = CombineLearningHostingViewController(viewModel: viewModel)
        rootViewController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }
}
