//
//  RxSwiftStateFlowViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow
import Combine

// MARK: - Models

struct FlowEvent: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: Date = Date()
}

// MARK: - ViewModel

final class RxSwiftStateFlowViewModel: ObservableObject, Stepper {

    // MARK: - Stepper
    let steps = PublishRelay<Step>()

    // MARK: - BehaviorRelay
    // BehaviorRelay: 常に最新値を保持。新しいSubscriberも即座に最新値を受け取る。
    private let behaviorRelay = BehaviorRelay<Int>(value: 0)

    // MARK: - Published (UI State)
    @Published var relayCurrentValue: Int = 0
    @Published var sub1ReceivedValue: String = "---"
    @Published var sub2ReceivedValue: String = "---"
    @Published var sub3ReceivedValue: String = "---"
    @Published var lateSubReceivedValue: String = "（まだ購読していない）"
    @Published var isLateSubSubscribed: Bool = false

    // アニメーショントリガー (changeで検知させるためにUUIDを使用)
    @Published var flowAnimationTrigger: UUID = UUID()

    // パルスカウンター (changeで検知)
    @Published var relayPulseCount: Int = 0
    @Published var sub1PulseCount: Int = 0
    @Published var sub2PulseCount: Int = 0
    @Published var sub3PulseCount: Int = 0
    @Published var lateSubPulseCount: Int = 0

    // イベントログ
    @Published var events: [FlowEvent] = []

    // MARK: - Private
    private let disposeBag = DisposeBag()
    private var lateDisposeBag = DisposeBag()
    private var acceptCount = 0

    // MARK: - Init
    init() {
        setupBindings()
        addEvent("✅ BehaviorRelay<Int>(value: 0) 生成")
        addEvent("🔗 Subscriber-1 購読開始")
        addEvent("🔗 Subscriber-2 購読開始")
        addEvent("🔗 Subscriber-3 購読開始")
        addEvent("──────────────────────")
        addEvent("💡 BehaviorRelay は初期値 0 を3つのSubscriberへ配信済み")
    }

    // MARK: - Bindings
    private func setupBindings() {
        // Subscriber 1
        behaviorRelay
            .subscribe(onNext: { [weak self] value in
                guard let self else { return }
                self.sub1ReceivedValue = "\(value)"
                self.sub1PulseCount += 1
            })
            .disposed(by: disposeBag)

        // Subscriber 2
        behaviorRelay
            .subscribe(onNext: { [weak self] value in
                guard let self else { return }
                self.sub2ReceivedValue = "\(value)"
                self.sub2PulseCount += 1
            })
            .disposed(by: disposeBag)

        // Subscriber 3
        behaviorRelay
            .subscribe(onNext: { [weak self] value in
                guard let self else { return }
                self.sub3ReceivedValue = "\(value)"
                self.sub3PulseCount += 1
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions

    /// BehaviorRelay に新しい値を流す
    func acceptNewValue() {
        acceptCount += 1
        let value = acceptCount

        addEvent("──────────────────────")
        addEvent("🔵 behaviorRelay.accept(\(value)) 呼び出し")

        relayCurrentValue = value
        relayPulseCount += 1
        flowAnimationTrigger = UUID()

        behaviorRelay.accept(value)

        // ログはRxのsubscribeコールバック後に記録される
        DispatchQueue.main.async { [weak self] in
            self?.addEvent("📥 Subscriber-1 受信: \(value)")
            self?.addEvent("📥 Subscriber-2 受信: \(value)")
            self?.addEvent("📥 Subscriber-3 受信: \(value)")
        }
    }

    /// Late Subscriber が購読開始する（BehaviorRelayの最新値が即流れることを示す）
    func subscribeLate() {
        guard !isLateSubSubscribed else { return }
        isLateSubSubscribed = true

        addEvent("──────────────────────")
        addEvent("🔔 Late-Subscriber 購読開始！")
        addEvent("💡 BehaviorRelay → 最新値 \(relayCurrentValue) を即配信")

        behaviorRelay
            .subscribe(onNext: { [weak self] value in
                guard let self else { return }
                self.lateSubReceivedValue = "\(value)"
                self.lateSubPulseCount += 1
                if self.isLateSubSubscribed {
                    DispatchQueue.main.async {
                        self.addEvent("📥 Late-Subscriber 受信: \(value)")
                    }
                }
            })
            .disposed(by: lateDisposeBag)
    }

    /// 状態リセット
    func clearAll() {
        acceptCount = 0
        relayCurrentValue = 0
        sub1ReceivedValue = "---"
        sub2ReceivedValue = "---"
        sub3ReceivedValue = "---"
        lateSubReceivedValue = "（まだ購読していない）"
        isLateSubSubscribed = false
        lateDisposeBag = DisposeBag()
        events = []

        behaviorRelay.accept(0)
        sub1ReceivedValue = "0"
        sub2ReceivedValue = "0"
        sub3ReceivedValue = "0"

        addEvent("✅ リセット完了 — BehaviorRelay(value: 0)")
        addEvent("🔗 Subscriber-1, 2, 3 購読中")
    }

    // MARK: - Private

    private func addEvent(_ message: String) {
        events.append(FlowEvent(message: message))
        if events.count > 60 {
            events.removeFirst()
        }
    }
}
