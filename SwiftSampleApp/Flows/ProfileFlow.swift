//
//  ProfileFlow.swift
//  SwiftSampleApp
//

import UIKit
import SwiftUI
import RxFlow

final class ProfileFlow: Flow {

    var root: Presentable { navigationController }

    private let navigationController: UINavigationController = {
        let nav = UINavigationController()
        nav.navigationBar.tintColor = AppTheme.Color.primary
        return nav
    }()

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .profile:
            return navigateToProfile()
        case .editProfile:
            return navigateToEditProfile()
        case .allChats:
            return navigateToAllChats()
        case .chatThread(let user):
            return navigateToChatThread(user: user)
        case .userProfile(let uid):
            return navigateToUserProfile(uid: uid)
        case .followersList(let uid):
            return navigateToFollowList(uid: uid, mode: .followers)
        case .followingList(let uid):
            return navigateToFollowList(uid: uid, mode: .following)
        case .logoutComplete:
            return .end(forwardToParentFlowWithStep: AppStep.logoutComplete)
        default:
            return .none
        }
    }

    // MARK: - Navigation

    private func navigateToProfile() -> FlowContributors {
        let viewModel = ProfileViewModel()
        let vc = UIHostingController(rootView: ProfileView(viewModel: viewModel))
        vc.title = "プロフィール"
        navigationController.setViewControllers([vc], animated: false)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: viewModel
        ))
    }

    private func navigateToEditProfile() -> FlowContributors {
        let viewModel = EditProfileViewModel()
        let vc = UIHostingController(rootView: EditProfileView(viewModel: viewModel))
        vc.view.backgroundColor = .clear
        let nav = UINavigationController(rootViewController: vc)
        navigationController.present(nav, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: viewModel
        ))
    }

    private func navigateToAllChats() -> FlowContributors {
        let viewModel = AllChatsViewModel()
        let vc = UIHostingController(rootView: AllChatsView(viewModel: viewModel))
        vc.title = "メッセージ"
        navigationController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: viewModel
        ))
    }

    private func navigateToChatThread(user: UserModel) -> FlowContributors {
        let viewModel = ChatThreadViewModel(recipient: user)
        let viewController = ChatThreadHostingViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
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

    private func navigateToFollowList(uid: String, mode: FollowListMode) -> FlowContributors {
        let viewModel = FollowListViewModel(uid: uid, mode: mode)
        let vc = UIHostingController(rootView: FollowListView(viewModel: viewModel))
        vc.title = mode.title
        navigationController.pushViewController(vc, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: viewModel
        ))
    }
}
