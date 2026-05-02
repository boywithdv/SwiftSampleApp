//
//  PostDetailView.swift
//  SwiftSampleApp
//

import SwiftUI

struct PostDetailView: View {

    @ObservedObject var viewModel: PostDetailViewModel
    @FocusState private var isCommentFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Post card
                        postCard
                            .padding()

                        Divider()

                        // Comments
                        LazyVStack(alignment: .leading, spacing: 0) {
                            if viewModel.comments.isEmpty {
                                Text("コメントはまだありません")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appTextSecondary)
                                    .padding()
                            } else {
                                ForEach(viewModel.comments) { comment in
                                    CommentRow(comment: comment)
                                        .id(comment.id)
                                }
                            }
                        }
                    }
                }
                .onChange(of: viewModel.comments.count) { _ in
                    if let last = viewModel.comments.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            // Comment input bar
            commentInputBar
        }
        .background(Color.appBackground)
        .navigationTitle("投稿")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Post Card

    private var postCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.appPrimary.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(viewModel.post.username.prefix(2)).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.appPrimary)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.post.username)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Color.appTextPrimary)
                    Text(viewModel.post.formattedDate)
                        .font(.system(size: 12))
                        .foregroundColor(Color.appTextSecondary)
                }
            }

            Text(viewModel.post.message)
                .font(.system(size: 16))
                .foregroundColor(Color.appTextPrimary)

            HStack {
                Button(action: { viewModel.toggleLike() }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.currentUserId.map { viewModel.post.isLikedBy($0) } ?? false
                              ? "heart.fill" : "heart")
                        Text("\(viewModel.post.likes.count)")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(Color(uiColor: AppTheme.Color.secondary))
                }
                .buttonStyle(.plain)

                Spacer()

                Text("\(viewModel.comments.count) コメント")
                    .font(.system(size: 13))
                    .foregroundColor(Color.appTextSecondary)
            }
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(AppTheme.CornerRadius.card)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    // MARK: - Comment Input

    private var commentInputBar: some View {
        HStack(spacing: 8) {
            TextField("コメントを追加...", text: $viewModel.commentText)
                .focused($isCommentFocused)
                .padding(10)
                .background(Color.appSurface)
                .cornerRadius(20)

            if viewModel.isSending {
                ProgressView()
                    .frame(width: 36, height: 36)
            } else {
                Button(action: { viewModel.submitComment() }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(viewModel.commentText.isEmpty
                                         ? Color.appTextSecondary
                                         : Color.appPrimary)
                }
                .disabled(viewModel.commentText.isEmpty)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.appBackground)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.2)), alignment: .top)
    }
}

// MARK: - Comment Row

struct CommentRow: View {
    let comment: Comment

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.appPrimary.opacity(0.15))
                .frame(width: 32, height: 32)
                .overlay(
                    Text(String(comment.username.prefix(2)).uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color.appPrimary)
                )

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.username)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.appTextPrimary)
                    Spacer()
                    Text(comment.formattedDate)
                        .font(.system(size: 11))
                        .foregroundColor(Color.appTextSecondary)
                }

                Text(comment.text)
                    .font(.system(size: 14))
                    .foregroundColor(Color.appTextPrimary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        Divider().padding(.leading, 58)
    }
}
