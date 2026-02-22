//
//  FavoriteFlow.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import UIKit
import RxFlow
import RxSwift

class FavoriteFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: UINavigationController
    
    init() {
        let favoriteVC = FavouriteViewController()
        self.rootViewController = UINavigationController(rootViewController: favoriteVC)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .favorite:
            return navigateToFavorite()
        default:
            return .none
        }
    }
    
    private func navigateToFavorite() -> FlowContributors {
        guard let favoriteVC = rootViewController.viewControllers.first as? FavouriteViewController else {
            return .none
        }
        return .one(flowContributor: .contribute(
            withNextPresentable: favoriteVC,
            withNextStepper: favoriteVC
        ))
    }
}
