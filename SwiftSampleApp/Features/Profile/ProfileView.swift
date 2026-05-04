//
//  ProfileView.swift
//  SwiftSampleApp
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel
    @State private var showLogoutAlert = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 1), count: 2)

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                profileHeader
                Divider()
                postsGrid
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .alert("ログアウト", isPresented: $showLogoutAlert) {
            Button("キャンセル", role: .cancel) {}
            Button("ログアウト", role: .destructive) { viewModel.tapLogout() }
        } message: {
            Text("ログアウトしますか？")
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                Button {
                    showLogoutAlert = true
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(.trailing, 16)
            }
            .padding(.top, 8)

            // Avatar
            AvatarView(
                url: viewModel.displayUser?.photoUrl,
                initials: viewModel.displayUser?.initials ?? "",
                size: 80
            )

            // Name
            Text(viewModel.displayUser?.displayName ?? "")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)

            // Stats row
            HStack(spacing: 0) {
                StatView(label: "投稿", value: viewModel.displayPosts.count)
                Divider().frame(height: 40)
                Button { viewModel.tapFollowers() } label: {
                    StatView(label: "フォロワー",
                             value: viewModel.displayUser?.followers.count ?? 0)
                }
                Divider().frame(height: 40)
                Button { viewModel.tapFollowing() } label: {
                    StatView(label: "フォロー中",
                             value: viewModel.displayUser?.following.count ?? 0)
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color.appSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)

            // Action buttons
            HStack(spacing: 12) {
                Button { viewModel.tapEdit() } label: {
                    Label("プロフィール編集", systemImage: "pencil")
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color(uiColor: .systemGray5))
                        .foregroundStyle(Color.appTextPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                Button { viewModel.tapChats() } label: {
                    Label("メッセージ", systemImage: "bubble.left.and.bubble.right")
                        .font(.system(size: 14, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(Color.appPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.appSurface)
    }

    // MARK: - Posts Grid

    @ViewBuilder
    private var postsGrid: some View {
        if viewModel.displayPosts.isEmpty {
            VStack(spacing: 12) {
                Image(systemName: "square.grid.2x2")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.appTextSecondary)
                Text("まだ投稿がありません")
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
        } else {
            LazyVGrid(columns: columns, spacing: 1) {
                ForEach(viewModel.displayPosts) { post in
                    Button { viewModel.tapPost(post) } label: {
                        ZStack(alignment: .bottomLeading) {
                            Color.appSurface
                            Text(post.message)
                                .font(.system(size: 13))
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(4)
                                .padding(10)
                        }
                        .frame(height: 120)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 1)
        }
    }
}

// MARK: - StatView

private struct StatView: View {
    let label: String
    let value: Int

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}
