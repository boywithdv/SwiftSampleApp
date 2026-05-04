//
//  SearchFlow.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI
import RxFlow

final class SearchFlow: Flow {

    var root: Presentable { navigationController }

    private let navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.navigationBar.tintColor = AppTheme.Color.primary
        return nav
    }()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .search:
            return navigateToSearch()
        case .userProfile(let uid):
            return navigateToUserProfile(uid: uid)
        default:
            return .none
        }
    }

    private func navigateToSearch() -> FlowContributors {
        let viewModel = SearchViewModel()
        let vc = UIHostingController(rootView: SearchView(viewModel: viewModel))
        vc.title = "検索"
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
