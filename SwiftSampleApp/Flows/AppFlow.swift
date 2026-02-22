//
//  AppFlow.swift
//  SwiftSampleApp
//
//  Created by tsukuda on 2026/02/22.
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift

/// アプリケーション全体でのフローを管理する
/// 例えば、アプリ起動時のスプラッシュ画面表示や、タブバーの設定などを担当する
final class AppFlow: Flow {
    // アプリのメインウィンドウを保持するための変数。
    private let window: UIWindow
    // RxFlowが定義しているプロトコルである。
    // UIControllerやFlowなど画面の対象になれるものが共通して扱える様にするための型
    // UIWindowを返す。
    // 画面遷移を実現するのに必須
    var root: Presentable {
        return self.window
    }
    // 初期化処理
    // UIWindowの初期化をする。
    init(window: UIWindow) {
        self.window = window
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        // 画面遷移時の処理
        switch step {
        case .splash:
            return navigateToSplash()
        case .splashComplete:
            // legacy: direct splashComplete -> tab bar
            return navigateToTabBar()
        case .tabBarIsRequired:
            return navigateToTabBar()
        case .tabBar:
            return .none
        default:
            return .none
        }
    }
    
    private func navigateToSplash() -> FlowContributors {
        let splashFlow = SplashFlow()
        
        Flows.use(splashFlow, when: .created) { [weak self] root in
            self?.window.rootViewController = root
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: splashFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.splash)
        ))
    }
    
    private func navigateToTabBar() -> FlowContributors {
        let tabFlow = TabFlow()
        
        Flows.use(tabFlow, when: .created) { [weak self] root in
            self?.window.rootViewController = root
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: tabFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.tabBarIsRequired)
        ))
    }
    
    
    
}
