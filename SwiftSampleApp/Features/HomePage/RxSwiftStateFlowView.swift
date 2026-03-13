//
//  RxSwiftStateFlowView.swift
//  SwiftSampleApp
//

import SwiftUI

// MARK: - RxSwiftStateFlowView

struct RxSwiftStateFlowView: View {

    @StateObject private var viewModel: RxSwiftStateFlowViewModel

    init(viewModel: RxSwiftStateFlowViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                scrollContent
                    .frame(height: geometry.size.height * 0.55)
                Divider()
                eventLogSection
            }
        }
        .navigationTitle("状態フロー可視化")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                conceptHeader
                flowDiagram
                lateSubscriberSection
            }
            .padding(16)
        }
    }

    // MARK: - Concept Header

    private var conceptHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.triangle.pull")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("BehaviorRelay の状態フロー")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.primary)
            }
            Text("accept() を呼ぶと登録済みの全 Subscriber へ即座に値が流れます。\nBehaviorRelay は最新値を保持するため、後から購読したSubscriberも即受信します。")
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.06))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Flow Diagram

    private var flowDiagram: some View {
        VStack(spacing: 0) {
            // Relay node
            RelayNode(
                currentValue: viewModel.relayCurrentValue,
                pulseCount: viewModel.relayPulseCount,
                onAccept: { viewModel.acceptNewValue() }
            )

            // Flow lines + subscriber nodes
            HStack(alignment: .top, spacing: 12) {
                ForEach(0..<3) { index in
                    VStack(spacing: 0) {
                        FlowLine(
                            color: subscriberColor(index),
                            animationTrigger: viewModel.flowAnimationTrigger,
                            delay: Double(index) * 0.12
                        )
                        SubscriberNode(
                            label: "Subscriber-\(index + 1)",
                            value: subscriberValue(index),
                            color: subscriberColor(index),
                            pulseCount: subscriberPulseCount(index)
                        )
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    // MARK: - Late Subscriber Section

    private var lateSubscriberSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "clock.badge.plus")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("Late Subscriber デモ")
                    .font(.system(size: 13, weight: .semibold))
            }
            Text("購読開始のタイミングが遅くても、BehaviorRelay は現在の最新値を即座に流します")
                .font(.caption2)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                // Late subscriber status
                VStack(spacing: 4) {
                    Text("Late-Subscriber")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(viewModel.lateSubReceivedValue)
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(viewModel.isLateSubSubscribed ? .orange : .secondary)
                        .id("late-\(viewModel.lateSubPulseCount)")
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.3), value: viewModel.lateSubPulseCount)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(viewModel.isLateSubSubscribed ? Color.orange.opacity(0.08) : Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.isLateSubSubscribed ? Color.orange.opacity(0.4) : Color.clear, lineWidth: 1.5)
                )

                Button(action: { viewModel.subscribeLate() }) {
                    Label(
                        viewModel.isLateSubSubscribed ? "購読中" : "購読開始",
                        systemImage: viewModel.isLateSubSubscribed ? "checkmark.circle.fill" : "plus.circle"
                    )
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(viewModel.isLateSubSubscribed ? .secondary : .white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(viewModel.isLateSubSubscribed ? Color(.systemGray5) : Color.orange)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLateSubSubscribed)
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    // MARK: - Event Log

    private var eventLogSection: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "terminal")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("イベントログ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: { viewModel.clearAll() }) {
                    Label("リセット", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))

            // Log body
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        if viewModel.events.isEmpty {
                            Text("accept() を押して状態の流れを確認しよう！")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(12)
                        } else {
                            ForEach(viewModel.events) { event in
                                Text(event.message)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(eventColor(for: event.message))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 1)
                                    .id(event.id)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: viewModel.events.count) { _ in
                    if let last = viewModel.events.last {
                        withAnimation(.easeOut(duration: 0.1)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.systemGray6))
        }
    }

    // MARK: - Helpers

    private func subscriberValue(_ index: Int) -> String {
        switch index {
        case 0: return viewModel.sub1ReceivedValue
        case 1: return viewModel.sub2ReceivedValue
        case 2: return viewModel.sub3ReceivedValue
        default: return "---"
        }
    }

    private func subscriberPulseCount(_ index: Int) -> Int {
        switch index {
        case 0: return viewModel.sub1PulseCount
        case 1: return viewModel.sub2PulseCount
        case 2: return viewModel.sub3PulseCount
        default: return 0
        }
    }

    private func subscriberColor(_ index: Int) -> Color {
        switch index {
        case 0: return .blue
        case 1: return .purple
        case 2: return .teal
        default: return .gray
        }
    }

    private func eventColor(for message: String) -> Color {
        if message.contains("accept") { return .blue }
        if message.contains("📥") { return .green }
        if message.contains("🔔") || message.contains("Late") { return .orange }
        if message.contains("🔗") { return .purple }
        if message.contains("──") { return Color(.systemGray3) }
        if message.contains("💡") { return .yellow }
        if message.contains("✅") { return .green }
        return .primary
    }
}

// MARK: - RelayNode

private struct RelayNode: View {
    let currentValue: Int
    let pulseCount: Int
    let onAccept: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0

    var body: some View {
        VStack(spacing: 8) {
            // Type label
            Text("BehaviorRelay<Int>")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.blue)

            // Value badge
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(Color.blue.opacity(0.3 + glowOpacity * 0.7), lineWidth: 2)
                            .scaleEffect(1 + glowOpacity * 0.3)
                            .opacity(1 - glowOpacity)
                    )
                Text("\(currentValue)")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
            }
            .scaleEffect(scale)

            Button(action: {
                onAccept()
                animatePulse()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 11))
                    Text("accept()")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(20)
                .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.bottom, 4)
        .onChange(of: pulseCount) { _ in
            animatePulse()
        }
    }

    private func animatePulse() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            scale = 1.15
        }
        withAnimation(.easeOut(duration: 0.4)) {
            glowOpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.3)) {
                glowOpacity = 0
            }
        }
    }
}

// MARK: - FlowLine

private struct FlowLine: View {
    let color: Color
    let animationTrigger: UUID
    let delay: Double

    @State private var dotOffset: CGFloat = 0
    @State private var dotOpacity: Double = 0

    private let lineHeight: CGFloat = 72

    var body: some View {
        ZStack(alignment: .top) {
            // Dashed static line
            DashedLine(color: color.opacity(0.25))
                .frame(width: 2, height: lineHeight)

            // Animated packet dot
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
                .offset(y: dotOffset)
                .opacity(dotOpacity)
                .shadow(color: color.opacity(0.6), radius: 4)
        }
        .frame(width: 10, height: lineHeight)
        .onChange(of: animationTrigger) { _ in
            startAnimation()
        }
    }

    private func startAnimation() {
        dotOffset = 0
        dotOpacity = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            dotOpacity = 1
            withAnimation(.easeIn(duration: 0.45)) {
                dotOffset = lineHeight - 5
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeOut(duration: 0.15)) {
                    dotOpacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    dotOffset = 0
                }
            }
        }
    }
}

// MARK: - DashedLine

private struct DashedLine: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: geo.size.width / 2, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width / 2, y: geo.size.height))
            }
            .stroke(
                color,
                style: StrokeStyle(lineWidth: 2, dash: [4, 3])
            )
        }
    }
}

// MARK: - SubscriberNode

private struct SubscriberNode: View {
    let label: String
    let value: String
    let color: Color
    let pulseCount: Int

    @State private var scale: CGFloat = 1.0
    @State private var bgOpacity: Double = 0

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundColor(color)
                .id("val-\(pulseCount)")

            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.07 + bgOpacity * 0.15))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.2 + bgOpacity * 0.6), lineWidth: 1.5)
        )
        .scaleEffect(scale)
        .onChange(of: pulseCount) { _ in
            animateReceive()
        }
    }

    private func animateReceive() {
        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
            scale = 1.1
            bgOpacity = 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                scale = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.4)) {
                bgOpacity = 0
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RxSwiftStateFlowView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RxSwiftStateFlowView(viewModel: RxSwiftStateFlowViewModel())
        }
    }
}
#endif
