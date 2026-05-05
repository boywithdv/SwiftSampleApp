//
//  SwiperView.swift
//  SwiftSampleApp
//

import SwiftUI

struct SwiperView: View {

    @ObservedObject var viewModel: SwiperViewModel

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            if viewModel.isFetching {
                ProgressView().scaleEffect(1.5)

            } else if viewModel.isEmpty {
                emptyStateView

            } else {
                VStack(spacing: 0) {
                    cardStack
                        .frame(maxHeight: .infinity)
                    actionButtons
                        .padding(.bottom, 28)
                }
            }
        }
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width - 40
            ZStack {
                ForEach(viewModel.cards.reversed()) { user in
                    if user.uid == viewModel.cards.last?.uid {
                        UserCardView(user: user, onProfile: { viewModel.tapProfile(user: user) })
                            .frame(width: cardWidth, height: 440)
                            .offset(offset)
                            .rotationEffect(.degrees(rotation))
                            .gesture(
                                DragGesture(minimumDistance: 10)
                                    .onChanged { g in
                                        offset = g.translation
                                        rotation = Double(g.translation.width / 20)
                                    }
                                    .onEnded { g in
                                        let threshold: CGFloat = 100
                                        if g.translation.width > threshold {
                                            swipeRight(user: user)
                                        } else if g.translation.width < -threshold {
                                            swipeLeft(user: user)
                                        } else {
                                            withAnimation(.spring()) { offset = .zero; rotation = 0 }
                                        }
                                    }
                            )
                            .animation(.spring(), value: offset)
                            .overlay(swipeIndicators)
                    } else {
                        UserCardView(user: user, onProfile: {})
                            .frame(width: cardWidth, height: 440)
                            .scaleEffect(0.95)
                            .opacity(0.8)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Flutter 風 4ボタン（undo / skip / star / like）

    private var actionButtons: some View {
        HStack(spacing: 0) {
            Spacer()
            CircleActionButton(icon: "arrow.uturn.left",
                               color: Color(hex: "F5A623"), size: 52, iconSize: 22) {
                withAnimation(.spring()) { offset = .zero; rotation = 0 }
            }
            Spacer()
            CircleActionButton(icon: "xmark",
                               color: Color(hex: "FF3B30"), size: 64, iconSize: 30) {
                if let user = viewModel.cards.last { swipeLeft(user: user) }
            }
            Spacer()
            CircleActionButton(icon: "star.fill",
                               color: Color(hex: "007AFF"), size: 52, iconSize: 22) {
                if let user = viewModel.cards.last { swipeRight(user: user) }
            }
            Spacer()
            CircleActionButton(icon: "heart.fill",
                               color: Color(hex: "4CD964"), size: 64, iconSize: 30) {
                if let user = viewModel.cards.last { swipeRight(user: user) }
            }
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }

    // MARK: - Swipe Indicators

    private var swipeIndicators: some View {
        HStack {
            Text("SKIP")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.red)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.red, lineWidth: 3))
                .opacity(offset.width < -30 ? Double(-offset.width / 80) : 0)
                .rotationEffect(.degrees(-20))
            Spacer()
            Text("LIKE")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color.appPrimary)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.appPrimary, lineWidth: 3))
                .opacity(offset.width > 30 ? Double(offset.width / 80) : 0)
                .rotationEffect(.degrees(20))
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .frame(maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(Color.appTextSecondary)
            Text("近くのユーザーが見つかりません")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color.appTextPrimary)
            Text("また後で確認してみてください")
                .font(.system(size: 14))
                .foregroundColor(Color.appTextSecondary)
        }
    }

    // MARK: - Swipe Actions

    private func swipeRight(user: UserModel) {
        withAnimation(.easeOut(duration: 0.3)) { offset = CGSize(width: 600, height: 0) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.swipeRight(user: user)
            offset = .zero; rotation = 0
        }
    }

    private func swipeLeft(user: UserModel) {
        withAnimation(.easeOut(duration: 0.3)) { offset = CGSize(width: -600, height: 0) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.swipeLeft(user: user)
            offset = .zero; rotation = 0
        }
    }
}

// MARK: - CircleActionButton

private struct CircleActionButton: View {
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
                    .shadow(color: color.opacity(0.3), radius: 12, x: 0, y: 4)
                Image(systemName: icon)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(color)
            }
            .frame(width: size, height: size)
        }
    }
}

// MARK: - Color hex init (private to this file)

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int & 0xff0000) >> 16) / 255
        let g = Double((int & 0x00ff00) >> 8)  / 255
        let b = Double(int & 0x0000ff)          / 255
        self.init(red: r, green: g, blue: b)
    }
}
