//
//  EditProfileView.swift
//  SwiftSampleApp
//

import SwiftUI

struct EditProfileView: View {
    @StateObject var viewModel: EditProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                AvatarView(url: nil, initials: viewModel.displayName.initials, size: 80)
                    .padding(.top, 32)

                SNSTextField(text: $viewModel.displayName,
                             placeholder: "表示名",
                             icon: "person")
                    .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("プロフィール編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                        .foregroundStyle(Color.appTextSecondary)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.save()
                    } label: {
                        if viewModel.isSaving {
                            ProgressView().scaleEffect(0.8)
                        } else {
                            Text("保存").bold().foregroundStyle(Color.appPrimary)
                        }
                    }
                    .disabled(viewModel.isSaving || viewModel.displayName.isEmpty)
                }
            }
            .onChange(of: viewModel.didSave) { saved in
                if saved { dismiss() }
            }
        }
    }
}

private extension String {
    var initials: String {
        let parts = trimmingCharacters(in: .whitespaces).components(separatedBy: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last  = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return (first + last).uppercased()
    }
}
