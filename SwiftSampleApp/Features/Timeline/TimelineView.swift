//
//  TimelineView.swift
//  SwiftSampleApp
//

import SwiftUI

struct TimelineView: View {
    @StateObject var viewModel: TimelineViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            postList
            fabButton
        }
        .background(Color.appBackground.ignoresSafeArea())
        .onAppear { configureNavigationBar() }
    }

    // MARK: - Post List

    private var postList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.displayPosts) { post in
                    PostRowView(
                        post: post,
                        currentUserId: viewModel.currentUserId,
                        onLike:    { viewModel.toggleLike(postId: $0) },
                        onTapUser: { viewModel.tapUser(uid: $0) },
                        onTapPost: { viewModel.tapPost($0) }
                    )
                    Divider()
                        .padding(.leading, 68)
                }
            }
        }
        .refreshable {
            // pull-to-refresh — fetchTimeline は real-time listener なので再接続不要
        }
    }

    // MARK: - FAB

    private var fabButton: some View {
        Button { viewModel.tapCreate() } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.appPrimary)
                .clipShape(Circle())
                .shadow(color: Color.appPrimary.opacity(0.4), radius: 8, x: 0, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }

    // MARK: - Navigation Bar

    private func configureNavigationBar() {
        // UIKit navigation bar に chat ボタンを設定（UIHostingController 経由）
    }
}
