//
//  SwiperFlow.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow

final class SwiperFlow: Flow {

    var root: Presentable {
        return navigationController
    }

    private let navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.navigationBar.tintColor = AppTheme.Color.primary
        return nav
    }()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .swiper:
            return navigateToSwiper()
        case .userProfile(let uid):
            return navigateToUserProfile(uid: uid)
        default:
            return .none
        }
    }

    private func navigateToSwiper() -> FlowContributors {
        let viewModel = SwiperViewModel()
        let viewController = SwiperHostingViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }

    private func navigateToUserProfile(uid: String) -> FlowContributors {
        let viewModel = UserProfileViewModel(targetUid: uid)
        let viewController = UserProfileViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }
}
