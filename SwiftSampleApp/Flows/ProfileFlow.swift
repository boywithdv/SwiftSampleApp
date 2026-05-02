//
//  ProfileFlow.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow

final class ProfileFlow: Flow {

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
        let viewController = ProfileViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }

    private func navigateToEditProfile() -> FlowContributors {
        let viewModel = EditProfileViewModel()
        let viewController = EditProfileViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: viewController)
        navigationController.present(nav, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }

    private func navigateToAllChats() -> FlowContributors {
        let viewModel = AllChatsViewModel()
        let viewController = AllChatsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
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
        let viewController = UserProfileViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }

    private func navigateToFollowList(uid: String, mode: FollowListViewController.Mode) -> FlowContributors {
        let viewModel = FollowListViewModel(uid: uid, mode: mode)
        let viewController = FollowListViewController(viewModel: viewModel, mode: mode)
        navigationController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }
}
