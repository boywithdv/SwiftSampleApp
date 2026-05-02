//
//  TimelineFlow.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow

final class TimelineFlow: Flow {

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
        case .timeline:
            return navigateToTimeline()
        case .postDetail(let post):
            return navigateToPostDetail(post: post)
        case .createPost:
            return navigateToCreatePost()
        case .userProfile(let uid):
            return navigateToUserProfile(uid: uid)
        default:
            return .none
        }
    }

    // MARK: - Navigation

    private func navigateToTimeline() -> FlowContributors {
        let viewModel = TimelineViewModel()
        let viewController = TimelineViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }

    private func navigateToPostDetail(post: UserPost) -> FlowContributors {
        let viewModel = PostDetailViewModel(post: post)
        let viewController = PostDetailHostingViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        return .one(flowContributor: .contribute(
            withNextPresentable: viewController,
            withNextStepper: viewModel
        ))
    }

    private func navigateToCreatePost() -> FlowContributors {
        let viewModel = CreatePostViewModel()
        let viewController = CreatePostViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: viewController)
        navigationController.present(nav, animated: true)
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
