//
//  CreatePostView.swift
//  SwiftSampleApp
//

import SwiftUI
import RxRelay

struct CreatePostView: View {
    @StateObject var viewModel: CreatePostViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Divider()

                HStack(alignment: .top, spacing: 12) {
                    AvatarView(url: nil, initials: "ME")
                        .padding(.top, 4)

                    ZStack(alignment: .topLeading) {
                        if viewModel.postText.isEmpty {
                            Text("今何してる？")
                                .foregroundStyle(Color.appTextSecondary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $viewModel.postText)
                            .font(.system(size: 16))
                            .frame(minHeight: 120)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                HStack {
                    Spacer()
                    Text("\(viewModel.remainingChars)")
                        .font(.system(size: 13))
                        .foregroundStyle(viewModel.remainingChars < 20
                            ? Color.appSecondary : Color.appTextSecondary)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

                Divider()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("新しい投稿")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("投稿") {
                        viewModel.submitTrigger.accept(())
                    }
                    .bold()
                    .foregroundStyle(viewModel.postText.isEmpty
                        ? Color.appTextSecondary : Color.appPrimary)
                    .disabled(viewModel.postText.isEmpty)
                }
            }
            .onChange(of: viewModel.didPost) { posted in
                if posted { dismiss() }
            }
        }
    }
}
