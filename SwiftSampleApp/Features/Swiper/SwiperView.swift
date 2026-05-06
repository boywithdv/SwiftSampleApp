//
//  SwiperView.swift
//  SwiftSampleApp
//

import SwiftUI
import UIKit

struct SwiperView: View {

    @ObservedObject var viewModel: SwiperViewModel

    @State private var offset: CGSize = .zero

    private let swipeThreshold: CGFloat = 110

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isFetching {
                loadingView
            } else if viewModel.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    cardDeck
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    actionBar
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                }
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(Color.appPrimary)
            Text("読み込み中...")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 68))
                .foregroundStyle(Color.appTextSecondary.opacity(0.45))
            VStack(spacing: 8) {
                Text("ユーザーが見つかりません")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("また後で確認してみてください")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(40)
    }

    // MARK: - Card Deck

    private var cardDeck: some View {
        GeometryReader { geo in
            let cardHeight = min(geo.size.height, 500)

            ZStack {
                // Back cards (non-interactive, scale + raise effect)
                ForEach(Array(backCards().enumerated()), id: \.element.uid) { idx, user in
                    let depthScale: CGFloat = 1 - CGFloat(idx + 1) * 0.042
                    let depthOffset: CGFloat = CGFloat(idx + 1) * -12

                    UserCardView(user: user, onProfile: {})
                        .frame(width: geo.size.width, height: cardHeight)
                        .scaleEffect(depthScale)
                        .offset(y: depthOffset)
                        .allowsHitTesting(false)
                }

                // Top card — draggable
                if let top = viewModel.cards.last {
                    UserCardView(user: top, onProfile: { viewModel.tapProfile(user: top) })
                        .frame(width: geo.size.width, height: cardHeight)
                        .offset(offset)
                        .rotationEffect(cardRotation, anchor: UnitPoint(x: 0.5, y: 1.1))
                        .overlay(stampLayer)
                        .gesture(dragGesture(for: top))
                        .zIndex(1)
                        .animation(.interactiveSpring(response: 0.32, dampingFraction: 0.68), value: offset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    // Back cards: second and third from the top
    private func backCards() -> [UserModel] {
        let count = viewModel.cards.count
        guard count > 1 else { return [] }
        return Array(viewModel.cards.dropLast().suffix(2).reversed())
    }

    // MARK: - Rotation

    private var cardRotation: Angle {
        let degrees = Double(offset.width / 22)
        return .degrees(min(max(degrees, -15), 15))
    }

    // MARK: - LIKE / NOPE Stamps

    private var stampLayer: some View {
        ZStack(alignment: .topLeading) {
            // LIKE — right swipe
            stampView(text: "LIKE", color: .green, rotation: -20)
                .opacity(likeOpacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 36).padding(.leading, 24)

            // NOPE — left swipe
            stampView(text: "NOPE", color: .red, rotation: 20)
                .opacity(nopeOpacity)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 36).padding(.trailing, 24)
        }
    }

    private func stampView(text: String, color: Color, rotation: Double) -> some View {
        Text(text)
            .font(.system(size: 38, weight: .heavy))
            .foregroundStyle(color)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(color, lineWidth: 4))
            .rotationEffect(.degrees(rotation))
    }

    private var likeOpacity: Double { min(1, max(0, Double(offset.width) / Double(swipeThreshold))) }
    private var nopeOpacity: Double { min(1, max(0, Double(-offset.width) / Double(swipeThreshold))) }

    // MARK: - Drag Gesture

    private func dragGesture(for user: UserModel) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { value in
                if value.translation.width > swipeThreshold {
                    commit(direction: .right, user: user)
                } else if value.translation.width < -swipeThreshold {
                    commit(direction: .left, user: user)
                } else {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.68)) {
                        offset = .zero
                    }
                }
            }
    }

    private enum Direction { case left, right }

    private func commit(direction: Direction, user: UserModel) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        let targetX: CGFloat = direction == .right ? 800 : -800
        withAnimation(.easeOut(duration: 0.32)) {
            offset = CGSize(width: targetX, height: offset.height * 0.5)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            offset = .zero
            direction == .right ? viewModel.swipeRight(user: user) : viewModel.swipeLeft(user: user)
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: 0) {
            Spacer()

            // Undo
            ActionButton(icon: "arrow.uturn.left", color: Color(hex: "F5A623"), size: 52, iconSize: 19) {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.68)) { offset = .zero }
            }
            .accessibilityLabel("元に戻す")

            Spacer()

            // Nope
            ActionButton(icon: "xmark", color: Color(hex: "FF3B30"), size: 68, iconSize: 28) {
                if let top = viewModel.cards.last { commit(direction: .left, user: top) }
            }
            .accessibilityLabel("スキップ")

            Spacer()

            // Star (super like)
            ActionButton(icon: "star.fill", color: Color(hex: "007AFF"), size: 52, iconSize: 19) {
                if let top = viewModel.cards.last { commit(direction: .right, user: top) }
            }
            .accessibilityLabel("スーパーいいね")

            Spacer()

            // Like
            ActionButton(icon: "heart.fill", color: Color(hex: "34C759"), size: 68, iconSize: 28) {
                if let top = viewModel.cards.last { commit(direction: .right, user: top) }
            }
            .accessibilityLabel("いいね")

            Spacer()
        }
    }
}

// MARK: - ActionButton

private struct ActionButton: View {
    let icon: String
    let color: Color
    var size: CGFloat = 56
    var iconSize: CGFloat = 24
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.white)
                    .shadow(color: color.opacity(0.32), radius: 12, x: 0, y: 5)
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(color)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color(hex:)

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8)  & 0xff) / 255
        let b = Double(int         & 0xff) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension SwiperViewModel {
    static var preview: SwiperViewModel {
        let vm = SwiperViewModel()
        vm.cards = [
            UserModel(uid: "uid-c", email: "carol@example.com", displayName: "Carol White"),
            UserModel(uid: "uid-b", email: "bob@example.com",   displayName: "Bob Johnson"),
            UserModel(uid: "uid-a", email: "alice@example.com", displayName: "田中 アリス"),
        ]
        vm.isFetching = false
        vm.isEmpty    = false
        return vm
    }

    static var previewLoading: SwiperViewModel {
        let vm = SwiperViewModel()
        vm.isFetching = true
        return vm
    }

    static var previewEmpty: SwiperViewModel {
        let vm = SwiperViewModel()
        vm.isFetching = false
        vm.isEmpty    = true
        return vm
    }
}
#endif

#Preview("スワイプ") {
    SwiperView(viewModel: .preview)
}

#Preview("ロード中") {
    SwiperView(viewModel: .previewLoading)
}

#Preview("ユーザーなし") {
    SwiperView(viewModel: .previewEmpty)
}
