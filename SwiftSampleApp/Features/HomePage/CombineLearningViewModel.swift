//
//  CombineLearningViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxFlow
import RxCocoa
import os

private let log = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "SwiftSampleApp",
    category: "CombineLearning"
)

// MARK: - Models

enum CombineLogCategory {
    case published, passthrough, currentValue, combine, debounce, separator
}

struct CombineLogEntry: Identifiable {
    let id = UUID()
    let message: String
    let category: CombineLogCategory
}

// MARK: - ViewModel

final class CombineLearningViewModel: ObservableObject, Stepper {

    // MARK: - Stepper
    let steps = PublishRelay<Step>()

    // MARK: - Published
    @Published private(set) var logMessages: [CombineLogEntry] = []

    // ① @Published デモ用カウンター
    // RxSwift では BehaviorSubject<Int>(value: 0) に相当
    @Published private var counter: Int = 0

    // ② PassthroughSubject (≒ RxSwift の PublishSubject)
    //    初期値なし。send() でイベントを流す → RxSwift の onNext() に相当
    private let passthroughSubject = PassthroughSubject<Int, Never>()

    // ③ CurrentValueSubject (≒ RxSwift の BehaviorSubject)
    //    初期値あり。購読開始時に現在値が即座に届く
    private let currentValueSubject = CurrentValueSubject<String, Never>("初期値-A")
    private var cvCounter = 0

    // ④ combineLatest デモ用
    private let combinePublisher1 = PassthroughSubject<String, Never>()
    private let combinePublisher2 = PassthroughSubject<String, Never>()
    private var combineCounter1 = 0
    private var combineCounter2 = 0

    // ⑤ debounce デモ用
    private let debouncePublisher = PassthroughSubject<Int, Never>()
    private var debounceCount = 0

    // 購読の管理: RxSwift の DisposeBag に相当するのが Set<AnyCancellable>
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    init() {
        setupBindings()
    }

    // MARK: - Bindings
    private func setupBindings() {

        // ① @Published を sink で購読
        // RxSwift: behaviorSubject.asObservable().subscribe(onNext:).disposed(by: disposeBag)
        // Combine:  $counter.sink { }.store(in: &cancellables)
        $counter
            .dropFirst() // 初期値(0)をスキップして、ボタン操作後の変化だけ表示
            .sink { [weak self] value in
                self?.emit("🔍[DEBUG]: [@Published] counter 変化 → \(value)", category: .published)
            }
            .store(in: &cancellables) // RxSwift の .disposed(by: disposeBag) に相当

        // ② PassthroughSubject → map → filter → sink
        // RxSwift: publishSubject.map { $0 * 3 }.filter { $0 % 2 == 0 }.subscribe(onNext:)
        passthroughSubject
            .handleEvents(receiveOutput: { [weak self] value in
                // RxSwift の .do(onNext:) に相当
                self?.emit("🔍[DEBUG]: [PassthroughSubject] send(\(value))", category: .passthrough)
            })
            .map { $0 * 3 }
            .handleEvents(receiveOutput: { [weak self] value in
                self?.emit("🔍[DEBUG]: [map] × 3 → \(value)", category: .passthrough)
            })
            .filter { $0 % 2 == 0 }
            .sink { [weak self] value in
                self?.emit("🔍[DEBUG]: [filter] ✅ 偶数のみ通過: \(value)", category: .passthrough)
            }
            .store(in: &cancellables)

        // ③ CurrentValueSubject - 購読開始時に「初期値-A」が即座に届く
        // RxSwift: BehaviorSubject は同じ挙動
        currentValueSubject
            .sink { [weak self] value in
                self?.emit("🔍[DEBUG]: [CurrentValueSubject] 現在値: \"\(value)\"", category: .currentValue)
            }
            .store(in: &cancellables)

        // ④ combineLatest
        // RxSwift:   Observable.combineLatest(s1, s2).subscribe(onNext:)
        // Combine:   publisher1.combineLatest(publisher2).sink { }
        combinePublisher1
            .combineLatest(combinePublisher2)
            .sink { [weak self] (v1, v2) in
                self?.emit("🔍[DEBUG]: [combineLatest] ✅ 結合: \"\(v1)\" + \"\(v2)\"", category: .combine)
            }
            .store(in: &cancellables)

        // ⑤ debounce
        // RxSwift: .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
        // Combine: .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
        debouncePublisher
            .handleEvents(receiveOutput: { [weak self] count in
                self?.emit("🔍[DEBUG]: [debounce] 受信 #\(count)  (400ms 待機中...)", category: .debounce)
            })
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .sink { [weak self] count in
                self?.emit("🔍[DEBUG]: [debounce] ✅ 発火! 最終: #\(count)", category: .debounce)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func triggerPublished() {
        emit("── @Published ─────────────────", category: .separator)
        counter += 1
    }

    func triggerPassthrough() {
        let value = Int.random(in: 1...10)
        emit("── PassthroughSubject ──────────", category: .separator)
        passthroughSubject.send(value) // RxSwift の onNext() に相当
    }

    func triggerCurrentValue() {
        let values = ["初期値-A", "更新値-B", "更新値-C", "更新値-D"]
        cvCounter += 1
        let value = values[cvCounter % values.count]
        emit("── CurrentValueSubject ─────────", category: .separator)
        currentValueSubject.send(value)
    }

    func triggerCombine1() {
        combineCounter1 += 1
        let value = "Publisher-A(\(combineCounter1))"
        emit("🔍[DEBUG]: [combineLatest] Publisher1.send(\"\(value)\")", category: .combine)
        combinePublisher1.send(value)
    }

    func triggerCombine2() {
        combineCounter2 += 1
        let value = "Publisher-B(\(combineCounter2))"
        emit("🔍[DEBUG]: [combineLatest] Publisher2.send(\"\(value)\")", category: .combine)
        combinePublisher2.send(value)
    }

    func triggerDebounce() {
        debounceCount += 1
        emit("── debounce ────────────────────", category: .separator)
        debouncePublisher.send(debounceCount)
    }

    func clearLogs() {
        logMessages = []
        counter = 0
        cvCounter = 0
        debounceCount = 0
        combineCounter1 = 0
        combineCounter2 = 0
    }

    // MARK: - Private

    private func emit(_ message: String, category: CombineLogCategory) {
        log.debug("\(message)")
        logMessages.append(CombineLogEntry(message: message, category: category))
    }
}
