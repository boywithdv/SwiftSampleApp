//
//  SwiperFlow.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI
import RxFlow

final class SwiperFlow: Flow {

    var root: Presentable { navigationController }

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
        let vc = UIHostingController(rootView: SwiperView(viewModel: viewModel))
        vc.title = "スワイプ"
        navigationController.setViewControllers([vc], animated: false)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: viewModel
        ))
    }

    private func navigateToUserProfile(uid: String) -> FlowContributors {
        let viewModel = UserProfileViewModel(targetUid: uid)
        let vc = UIHostingController(rootView: UserProfileView(viewModel: viewModel))
        navigationController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: viewModel
        ))
    }
}
