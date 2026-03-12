//
//  RxSwiftLearningViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow
import os

private let log = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "SwiftSampleApp",
    category: "RxSwiftLearning"
)

// MARK: - Models

enum LogCategory {
    case map, filter, combine, debounce, separator
}

struct LogEntry: Identifiable {
    let id = UUID()
    let message: String
    let category: LogCategory
}

// MARK: - ViewModel

final class RxSwiftLearningViewModel: ObservableObject, Stepper {

    // MARK: - Stepper
    let steps = PublishRelay<Step>()

    // MARK: - Published
    @Published private(set) var logMessages: [LogEntry] = []

    // MARK: - Private
    private let disposeBag = DisposeBag()
    private let mapSubject = PublishSubject<Int>()
    private let filterSubject = PublishSubject<Int>()
    private let combineSubject1 = BehaviorSubject<String?>(value: nil)
    private let combineSubject2 = BehaviorSubject<String?>(value: nil)
    private let debounceSubject = PublishSubject<Int>()
    private var debounceCount = 0
    private var combineCounter1 = 0
    private var combineCounter2 = 0

    // MARK: - Initialization
    init() {
        setupBindings()
    }

    // MARK: - Bindings
    private func setupBindings() {
        // map: 入力値を × 2 に変換
        mapSubject
            .do(onNext: { [weak self] value in
                self?.emit("🔍[DEBUG]: [map] 入力: \(value)", category: .map)
            })
            .map { $0 * 2 }
            .subscribe(onNext: { [weak self] result in
                self?.emit("🔍[DEBUG]: [map] 出力: \(result)  (\(result / 2) × 2)", category: .map)
            })
            .disposed(by: disposeBag)

        // filter: 偶数のみ通過
        filterSubject
            .do(onNext: { [weak self] value in
                let pass = value % 2 == 0 ? "✅ 通過" : "❌ 除外"
                self?.emit("🔍[DEBUG]: [filter] 入力: \(value)  偶数? → \(pass)", category: .filter)
            })
            .filter { $0 % 2 == 0 }
            .subscribe(onNext: { [weak self] result in
                self?.emit("🔍[DEBUG]: [filter] ↳ ダウンストリームへ: \(result)", category: .filter)
            })
            .disposed(by: disposeBag)

        // combineLatest: 両ストリームが値を持ったとき結合して発火
        Observable.combineLatest(
            combineSubject1.compactMap { $0 },
            combineSubject2.compactMap { $0 }
        )
        .subscribe(onNext: { [weak self] (v1, v2) in
            self?.emit("🔍[DEBUG]: [combineLatest] ✅ 結合発火: \"\(v1)\" + \"\(v2)\"", category: .combine)
        })
        .disposed(by: disposeBag)

        // debounce: 連続イベントを 300ms で間引く
        debounceSubject
            .do(onNext: { [weak self] count in
                self?.emit("🔍[DEBUG]: [debounce] 受信 #\(count)  (300ms 待機中...)", category: .debounce)
            })
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] count in
                self?.emit("🔍[DEBUG]: [debounce] ✅ 発火! 最終タップ: #\(count)", category: .debounce)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Actions

    func triggerMap() {
        let value = Int.random(in: 1...20)
        emit("── map ───────────────────────", category: .separator)
        mapSubject.onNext(value)
    }

    func triggerFilter() {
        let value = Int.random(in: 1...20)
        emit("── filter ────────────────────", category: .separator)
        filterSubject.onNext(value)
    }

    func triggerCombine1() {
        combineCounter1 += 1
        let value = "Stream-A(\(combineCounter1))"
        emit("🔍[DEBUG]: [combineLatest] Subject1 ← \"\(value)\"", category: .combine)
        combineSubject1.onNext(value)
    }

    func triggerCombine2() {
        combineCounter2 += 1
        let value = "Stream-B(\(combineCounter2))"
        emit("🔍[DEBUG]: [combineLatest] Subject2 ← \"\(value)\"", category: .combine)
        combineSubject2.onNext(value)
    }

    func triggerDebounce() {
        debounceCount += 1
        emit("── debounce ──────────────────", category: .separator)
        debounceSubject.onNext(debounceCount)
    }

    func clearLogs() {
        logMessages = []
        debounceCount = 0
        combineCounter1 = 0
        combineCounter2 = 0
    }

    // MARK: - Private

    private func emit(_ message: String, category: LogCategory) {
        log.debug("\(message)")
        logMessages.append(LogEntry(message: message, category: category))
    }
}
