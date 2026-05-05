//
//  TabFlow.swift
//  SwiftSampleApp
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

final class TabFlow: Flow {

    var root: Presentable {
        return self.rootViewController
    }

    private let rootViewController = UITabBarController()

    init() {}

    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }

        switch step {
        case .tabBarIsRequired:
            return navigateToTabBar()
        case .logoutComplete:
            return .end(forwardToParentFlowWithStep: AppStep.logoutComplete)
        default:
            return .none
        }
    }

    private func navigateToTabBar() -> FlowContributors {
        // time_line_view の値に応じて Home タブを表示/非表示（Flutter の NavigationConfig と同一ロジック）
        let isTimelineEnabled = RemoteConfigService.shared.timelineViewEnabled

        var tabInfos: [(flow: Flow, step: AppStep, title: String, image: String, selectedImage: String)] = []
        if isTimelineEnabled {
            tabInfos.append((TimelineFlow(), .timeline, "ホーム", "house", "house.fill"))
        }
        tabInfos += [
            (SwiperFlow(),    .swiper,       "スワイプ",      "person.2",           "person.2.fill"),
            (MapFlow(),       .locationMap,  "マップ",        "map",                "map.fill"),
            (SearchFlow(),    .search,       "検索",          "magnifyingglass",    "magnifyingglass"),
            (ProfileFlow(),   .profile,      "プロフィール",  "person.crop.circle", "person.crop.circle.fill")
        ]

        let flows = tabInfos.map { $0.flow }
        Flows.use(flows, when: .created) { [unowned self] roots in
            let viewControllers = zip(roots, tabInfos).compactMap { root, info -> UIViewController? in
                guard let viewController = root as? UIViewController else { return nil }
                viewController.tabBarItem = UITabBarItem(
                    title: info.title,
                    image: UIImage(systemName: info.image),
                    selectedImage: UIImage(systemName: info.selectedImage)
                )
                return viewController
            }
            self.rootViewController.setViewControllers(viewControllers, animated: false)
        }

        let contributors = tabInfos.map { info in
            FlowContributor.contribute(
                withNextPresentable: info.flow,
                withNextStepper: OneStepper(withSingleStep: info.step)
            )
        }
        return .multiple(flowContributors: contributors)
    }
}
