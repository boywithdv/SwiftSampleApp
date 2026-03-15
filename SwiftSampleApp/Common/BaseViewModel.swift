//
//  BaseViewModel.swift
//  SwiftSampleApp
//
//  Created by 佃 寿希也 on 2026/03/15.
//

import RxSwift
import RxCocoa
import RxFlow

/// 全ViewModelの基底クラス。
/// 画面遷移（Stepper）とローディング状態の管理を共通化する。
///
/// Flutter/Riverpodで言う StateNotifier の基底クラスに相当:
///   - steps      ≒ GoRouter へのナビゲーションイベント
///   - isLoading  ≒ AsyncValue.loading
class BaseViewModel: Stepper {

    // MARK: - Stepper

    /// RxFlowの画面遷移イベントを流すRelay。
    /// ViewModelがAcceptしたStepをFlowが受け取り、画面遷移を実行する。
    let steps = PublishRelay<Step>()

    // MARK: - Loading State

    /// ローディング状態を保持するRelay。
    /// trueを流すとUI側でインジケーターを表示する。
    /// Flutter: AsyncValue.loading に相当
    let isLoadingRelay = BehaviorRelay<Bool>(value: false)

    /// isLoadingRelayをObservableとして公開する。
    /// ViewControllerがbindして表示制御に使う。
    var isLoading: Observable<Bool> {
        isLoadingRelay.asObservable()
    }

    // MARK: - Initialization

    /// 指定イニシャライザ。
    /// サブクラスは `super.init()` を呼ぶことでこのクラスの初期化を保証する。
    init() {}
}
