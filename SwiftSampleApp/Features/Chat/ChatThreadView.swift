//
//  ChatThreadView.swift
//  SwiftSampleApp
//

import SwiftUI

struct ChatThreadView: View {

    @ObservedObject var viewModel: ChatThreadViewModel
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(viewModel.messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .onChange(of: viewModel.messages.count) { _ in
                    if let last = viewModel.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            inputBar
        }
        .background(Color.appBackground)
        .navigationTitle(viewModel.recipient.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 8) {
            TextField("メッセージを入力...", text: $viewModel.messageText)
                .focused($isInputFocused)
                .padding(10)
                .background(Color.appSurface)
                .cornerRadius(20)

            if viewModel.isSending {
                ProgressView()
                    .frame(width: 36, height: 36)
            } else {
                Button(action: { viewModel.sendMessage() }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(viewModel.messageText.isEmpty
                                         ? Color.appTextSecondary
                                         : Color.appPrimary)
                }
                .frame(width: 36, height: 36)
                .disabled(viewModel.messageText.isEmpty)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.appBackground)
        .overlay(Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.2)), alignment: .top)
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isMine { Spacer(minLength: 60) }

            VStack(alignment: message.isMine ? .trailing : .leading, spacing: 4) {
                Text(message.message)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isMine ? Color.appPrimary : Color.appSurface)
                    .foregroundColor(message.isMine ? .white : Color.appTextPrimary)
                    .cornerRadius(18)

                Text(formattedTime(message.date))
                    .font(.system(size: 10))
                    .foregroundColor(Color.appTextSecondary)
            }

            if !message.isMine { Spacer(minLength: 60) }
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
