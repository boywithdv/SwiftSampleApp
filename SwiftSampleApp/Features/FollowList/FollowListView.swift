//
//  FollowListView.swift
//  SwiftSampleApp
//

import SwiftUI

struct FollowListView: View {
    @StateObject var viewModel: FollowListViewModel

    var body: some View {
        Group {
            if viewModel.displayUsers.isEmpty {
                emptyView
            } else {
                userList
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(viewModel.mode.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - User List

    private var userList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.displayUsers) { user in
                    Button {
                        viewModel.selectUser(uid: user.uid)
                    } label: {
                        UserRow(user: user)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 76)
                }
            }
        }
    }

    // MARK: - Empty State

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2")
                .font(.system(size: 56))
                .foregroundStyle(Color.appTextSecondary)
            Text("ユーザーはいません")
                .font(.system(size: 16))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - UserRow

private struct UserRow: View {
    let user: UserModel

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                url: user.photoUrl,
                initials: user.initials,
                size: 48
            )
            VStack(alignment: .leading, spacing: 2) {
                Text(user.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(user.followers.count) フォロワー")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}


