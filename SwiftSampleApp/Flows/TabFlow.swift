//
//  TabFlow.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import UIKit
import RxFlow
import RxSwift
import RxCocoa

class TabFlow: Flow {
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
        default:
            return .none
        }
    }
    
    private func navigateToTabBar() -> FlowContributors {
        let tabInfos: [(flow: Flow, step: AppStep, title: String, image: String, selectedImage: String)] = [
            (HomeFlow(), .home, "ホーム", "house", "house.fill"),
            (BrowsingFlow(), .browsing, "閲覧履歴", "clock", "clock.fill"),
            (ReservationFlow(), .reservation, "予約", "calendar", "calendar.circle.fill"),
            (FavoriteFlow(), .favorite, "お気に入り", "heart", "heart.fill"),
            (MyPageFlow(), .myPage, "マイページ", "person", "person.fill")
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
