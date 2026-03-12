//
//  CombineLearningView.swift
//  SwiftSampleApp
//

import SwiftUI

// MARK: - CombineLogCategory Color

extension CombineLogCategory {
    var color: Color {
        switch self {
        case .published:    return Color(.systemPink)
        case .passthrough:  return .blue
        case .currentValue: return .teal
        case .combine:      return .orange
        case .debounce:     return .purple
        case .separator:    return Color(.systemGray3)
        }
    }
}

// MARK: - CombineLearningView

struct CombineLearningView: View {

    @StateObject private var viewModel: CombineLearningViewModel

    init(viewModel: CombineLearningViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                operatorSection
                    .frame(height: geometry.size.height * 0.58)
                Divider()
                logConsoleSection
            }
        }
        .navigationTitle("Combine学習")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Operator Section

    private var operatorSection: some View {
        ScrollView {
            VStack(spacing: 12) {

                // ① @Published
                CombineOperatorCard(
                    title: "@Published",
                    rxEquivalent: "BehaviorSubject",
                    description: "プロパティに付けるだけで変化を自動通知。\nsink { } で購読し、store(in:) で管理する。",
                    color: Color(.systemPink)
                ) {
                    Button("counter をインクリメント") { viewModel.triggerPublished() }
                        .buttonStyle(CombineButtonStyle(color: Color(.systemPink)))
                }

                // ② PassthroughSubject
                CombineOperatorCard(
                    title: "PassthroughSubject",
                    rxEquivalent: "PublishSubject",
                    description: "初期値なし。send() でイベントを流す。\nRxSwift の onNext() に相当。\nmap → filter のパイプラインを通して届く。",
                    color: .blue
                ) {
                    Button("send(ランダム値)") { viewModel.triggerPassthrough() }
                        .buttonStyle(CombineButtonStyle(color: .blue))
                }

                // ③ CurrentValueSubject
                CombineOperatorCard(
                    title: "CurrentValueSubject",
                    rxEquivalent: "BehaviorSubject",
                    description: "初期値あり。購読開始時に現在値が即座に届く。\n画面起動時に「初期値-A」が届くのはこのため。",
                    color: .teal
                ) {
                    Button("値を更新して send()") { viewModel.triggerCurrentValue() }
                        .buttonStyle(CombineButtonStyle(color: .teal))
                }

                // ④ combineLatest
                CombineOperatorCard(
                    title: "combineLatest",
                    rxEquivalent: "Observable.combineLatest",
                    description: "Combine では publisher1.combineLatest(publisher2) と書く。\n両方が値を持つと結合して発火する。",
                    color: .orange
                ) {
                    HStack(spacing: 8) {
                        Button("Publisher1") { viewModel.triggerCombine1() }
                            .buttonStyle(CombineButtonStyle(color: .orange))
                        Button("Publisher2") { viewModel.triggerCombine2() }
                            .buttonStyle(CombineButtonStyle(color: .orange))
                    }
                }

                // ⑤ debounce
                CombineOperatorCard(
                    title: "debounce",
                    rxEquivalent: "debounce",
                    description: "Combine: debounce(for: .milliseconds(400), scheduler: RunLoop.main)\nRxSwift: debounce(.milliseconds(300), scheduler: MainScheduler.instance)",
                    color: .purple
                ) {
                    Button("連打してみて！") { viewModel.triggerDebounce() }
                        .buttonStyle(CombineButtonStyle(color: .purple))
                }
            }
            .padding(16)
        }
    }

    // MARK: - Log Console Section

    private var logConsoleSection: some View {
        VStack(spacing: 0) {
            consoleHeader
            consoleBody
        }
    }

    private var consoleHeader: some View {
        HStack(spacing: 6) {
            Image(systemName: "terminal")
                .font(.caption)
                .foregroundColor(.secondary)
            Text("ログコンソール")
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Button(action: { viewModel.clearLogs() }) {
                Label("クリア", systemImage: "trash")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray5))
    }

    private var consoleBody: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    if viewModel.logMessages.isEmpty {
                        Text("ボタンを押して Combine の動きを確認しよう！")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.secondary)
                            .padding(12)
                    } else {
                        ForEach(viewModel.logMessages) { entry in
                            Text(entry.message)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(entry.category.color)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 1)
                                .id(entry.id)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .onChange(of: viewModel.logMessages.count) { _ in
                if let last = viewModel.logMessages.last {
                    withAnimation(.easeOut(duration: 0.15)) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.systemGray6))
    }
}

// MARK: - CombineOperatorCard

private struct CombineOperatorCard<Content: View>: View {
    let title: String
    let rxEquivalent: String
    let description: String
    let color: Color
    @ViewBuilder let action: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(color)
                    Text(description)
                        .font(.caption2)
                        .foregroundColor(Color(.systemGray))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                // RxSwift 相当バッジ
                VStack(alignment: .trailing, spacing: 2) {
                    Text("RxSwift")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray3))
                        .cornerRadius(4)
                    Text(rxEquivalent)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
            action
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - CombineButtonStyle

private struct CombineButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(color.opacity(configuration.isPressed ? 0.65 : 1.0))
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#if DEBUG
struct CombineLearningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CombineLearningView(viewModel: CombineLearningViewModel())
        }
    }
}
#endif
