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
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()

                if viewModel.isFetching {
                    ProgressView()
                        .scaleEffect(1.5)

                } else if viewModel.isEmpty {
                    emptyStateView

                } else {
                    cardStack
                }
            }
            .navigationTitle("スワイプ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack {
            ForEach(viewModel.cards.reversed()) { user in
                if user.uid == viewModel.cards.last?.uid {
                    UserCardView(user: user, onProfile: { viewModel.tapProfile(user: user) })
                        .frame(width: UIScreen.main.bounds.width - 40, height: 460)
                        .offset(offset)
                        .rotationEffect(.degrees(rotation))
                        .gesture(
                            DragGesture(minimumDistance: 10)
                                .onChanged { gesture in
                                    offset = gesture.translation
                                    rotation = Double(gesture.translation.width / 20)
                                }
                                .onEnded { gesture in
                                    let threshold: CGFloat = 100
                                    if gesture.translation.width > threshold {
                                        swipeRight(user: user)
                                    } else if gesture.translation.width < -threshold {
                                        swipeLeft(user: user)
                                    } else {
                                        withAnimation(.spring()) {
                                            offset = .zero
                                            rotation = 0
                                        }
                                    }
                                }
                        )
                        .animation(.spring(), value: offset)
                        .overlay(swipeIndicators)
                } else {
                    UserCardView(user: user, onProfile: {})
                        .frame(width: UIScreen.main.bounds.width - 40, height: 460)
                        .scaleEffect(0.95)
                        .opacity(0.8)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Swipe Indicators

    private var swipeIndicators: some View {
        HStack {
            // Left: Skip
            Text("SKIP")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.red)
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.red, lineWidth: 3))
                .opacity(offset.width < -30 ? Double(-offset.width / 80) : 0)
                .rotationEffect(.degrees(-20))

            Spacer()

            // Right: Like
            Text("LIKE")
                .font(.system(size: 24, weight: .bold))
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
        withAnimation(.easeOut(duration: 0.3)) {
            offset = CGSize(width: 600, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.swipeRight(user: user)
            offset = .zero
            rotation = 0
        }
    }

    private func swipeLeft(user: UserModel) {
        withAnimation(.easeOut(duration: 0.3)) {
            offset = CGSize(width: -600, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            viewModel.swipeLeft(user: user)
            offset = .zero
            rotation = 0
        }
    }
}
