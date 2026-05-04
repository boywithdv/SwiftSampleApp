//
//  PostRowView.swift
//  SwiftSampleApp
//
//  Twitter/X スタイルの全面レイアウト投稿セル
//

import SwiftUI

struct PostRowView: View {
    let post: UserPost
    let currentUserId: String?
    var onLike:    (String) -> Void = { _ in }
    var onTapUser: (String) -> Void = { _ in }
    var onTapPost: (UserPost) -> Void = { _ in }

    private var isLiked: Bool { post.isLikedBy(currentUserId ?? "") }

    var body: some View {
        Button { onTapPost(post) } label: {
            HStack(alignment: .top, spacing: 12) {
                Button { onTapUser(post.userId) } label: {
                    AvatarView(url: nil, initials: post.username.initials)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 4) {
                    headerRow
                    Text(post.message)
                        .font(.system(size: 15))
                        .foregroundStyle(Color.appTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    actionRow
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subviews

    private var headerRow: some View {
        HStack(spacing: 4) {
            Text(post.username)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
            Text("· \(post.formattedDate)")
                .font(.system(size: 14))
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
        }
    }

    private var actionRow: some View {
        HStack(spacing: 0) {
            // Like
            Button {
                onLike(post.postId)
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 16))
                        .foregroundStyle(isLiked ? Color.appSecondary : Color.appTextSecondary)
                    Text("\(post.likes.count)")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .buttonStyle(.plain)

            Spacer().frame(width: 24)

            // Comment (tap goes to post detail)
            Button { onTapPost(post) } label: {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 16))
                        .foregroundStyle(Color.appTextSecondary)
                    Text("0")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - String extension

private extension String {
    var initials: String {
        let parts = trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last  = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return (first + last).uppercased()
    }
}
