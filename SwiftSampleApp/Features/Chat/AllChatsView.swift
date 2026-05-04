//
//  AllChatsView.swift
//  SwiftSampleApp
//

import SwiftUI

struct AllChatsView: View {
    @StateObject var viewModel: AllChatsViewModel

    var body: some View {
        Group {
            if viewModel.displayConversations.isEmpty {
                emptyView
            } else {
                conversationList
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: - Conversation List

    private var conversationList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.displayConversations, id: \.0.id) { message, user in
                    Button {
                        if let user { viewModel.selectConversation(user: user) }
                    } label: {
                        ChatListRow(message: message, user: user)
                    }
                    .buttonStyle(.plain)
                    Divider().padding(.leading, 76)
                }
            }
        }
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 56))
                .foregroundStyle(Color.appTextSecondary)
            Text("メッセージはまだありません")
                .font(.system(size: 16))
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - ChatListRow

private struct ChatListRow: View {
    let message: Message
    let user: UserModel?

    var body: some View {
        HStack(spacing: 12) {
            AvatarView(
                url: user?.photoUrl,
                initials: user?.initials ?? "?",
                size: 52
            )
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(user?.displayName ?? "Unknown")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Text(message.formattedTime)
                        .font(.system(size: 12))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Text(message.message)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.appTextSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Message extension

private extension Message {
    var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - UserModel extension

private extension UserModel {
    var initials: String {
        let parts = displayName.trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last  = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return (first + last).uppercased()
    }
}
