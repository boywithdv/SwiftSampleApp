//
//  ChatFlow.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow

final class ChatFlow: Flow {

    var root: Presentable {
        return navigationController
    }

    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .allChats:
            return navigateToAllChats()
        case .chatThread(let user):
            return navigateToChatThread(user: user)
        default:
            return .none
        }
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
}
