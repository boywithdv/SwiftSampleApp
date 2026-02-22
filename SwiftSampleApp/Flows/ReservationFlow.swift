//
//  ReservationFlow.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import UIKit
import RxFlow
import RxSwift

class ReservationFlow: Flow {
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController: UINavigationController
    
    init() {
        let reservationVC = ReservationViewController()
        self.rootViewController = UINavigationController(rootViewController: reservationVC)
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .reservation:
            return navigateToReservation()
        default:
            return .none
        }
    }
    
    private func navigateToReservation() -> FlowContributors {
        guard let reservationVC = rootViewController.viewControllers.first as? ReservationViewController else {
            return .none
        }
        return .one(flowContributor: .contribute(
            withNextPresentable: reservationVC,
            withNextStepper: reservationVC
        ))
    }
}
