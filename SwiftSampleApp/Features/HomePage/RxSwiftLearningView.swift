//
//  RxSwiftLearningView.swift
//  SwiftSampleApp
//

import SwiftUI

// MARK: - LogCategory Color

extension LogCategory {
    var color: Color {
        switch self {
        case .map:       return .blue
        case .filter:    return .green
        case .combine:   return .orange
        case .debounce:  return .purple
        case .separator: return Color(.systemGray3)
        }
    }
}

// MARK: - RxSwiftLearningView

struct RxSwiftLearningView: View {

    @StateObject private var viewModel: RxSwiftLearningViewModel

    init(viewModel: RxSwiftLearningViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                operatorSection
                    .frame(height: geometry.size.height * 0.52)
                Divider()
                logConsoleSection
            }
        }
        .navigationTitle("RxSwift学習")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Operator Section

    private var operatorSection: some View {
        ScrollView {
            VStack(spacing: 12) {
                OperatorCard(
                    title: "map",
                    subtitle: "値を変換する",
                    description: "ランダムな数値 (1〜20) を × 2 に変換",
                    color: .blue
                ) {
                    Button("map を試す") { viewModel.triggerMap() }
                        .buttonStyle(OperatorButtonStyle(color: .blue))
                }

                OperatorCard(
                    title: "filter",
                    subtitle: "条件でフィルタリング",
                    description: "偶数のみ通過させる（奇数は除外）",
                    color: .green
                ) {
                    Button("filter を試す") { viewModel.triggerFilter() }
                        .buttonStyle(OperatorButtonStyle(color: .green))
                }

                OperatorCard(
                    title: "combineLatest",
                    subtitle: "複数ストリームを結合",
                    description: "Subject1・Subject2 の両方が値を持ったとき発火",
                    color: .orange
                ) {
                    HStack(spacing: 8) {
                        Button("Subject1 発火") { viewModel.triggerCombine1() }
                            .buttonStyle(OperatorButtonStyle(color: .orange))
                        Button("Subject2 発火") { viewModel.triggerCombine2() }
                            .buttonStyle(OperatorButtonStyle(color: .orange))
                    }
                }

                OperatorCard(
                    title: "debounce",
                    subtitle: "連続イベントを間引く",
                    description: "連打しても 300ms 経過後に 1 回だけ発火",
                    color: .purple
                ) {
                    Button("連打してみて！") { viewModel.triggerDebounce() }
                        .buttonStyle(OperatorButtonStyle(color: .purple))
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
                        Text("ボタンを押して演算子の動きを確認しよう！")
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

// MARK: - OperatorCard

private struct OperatorCard<Content: View>: View {
    let title: String
    let subtitle: String
    let description: String
    let color: Color
    @ViewBuilder let action: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(description)
                .font(.caption2)
                .foregroundColor(Color(.systemGray))
            action
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - OperatorButtonStyle

private struct OperatorButtonStyle: ButtonStyle {
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
struct RxSwiftLearningView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RxSwiftLearningView(viewModel: RxSwiftLearningViewModel())
        }
    }
}
#endif
