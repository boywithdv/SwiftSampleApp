//
//  RegisterView.swift
//  SwiftSampleApp
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel: RegisterViewModel
    @State private var showError = false

    var body: some View {
        ZStack {
            registerBackground
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.06)
                    logoArea
                    Spacer().frame(height: 32)
                    formArea
                }
                .padding(.horizontal, 28)
            }
        }
        .ignoresSafeArea()
        .alert("登録エラー", isPresented: $showError, presenting: viewModel.errorText) { _ in
            Button("OK") {}
        } message: { msg in
            Text(msg)
        }
        .onChange(of: viewModel.errorText) { text in
            showError = text != nil
        }
    }

    private var registerBackground: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            Circle()
                .fill(Color.appSecondary.opacity(0.10))
                .frame(width: 260, height: 260)
                .offset(x: 140, y: -180)
            Circle()
                .fill(Color.appPrimary.opacity(0.08))
                .frame(width: 180, height: 180)
                .offset(x: -130, y: -80)
        }
    }

    private var logoArea: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.appPrimary)
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(width: 120, height: 120)

            Text("アカウントを作成")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
        }
    }

    private var formArea: some View {
        VStack(spacing: 12) {
            SNSTextField(text: $viewModel.displayName, placeholder: "表示名", icon: "person")
            SNSTextField(text: $viewModel.email, placeholder: "Email", icon: "envelope",
                         keyboardType: .emailAddress)
            SNSTextField(text: $viewModel.password, placeholder: "パスワード (6文字以上)",
                         icon: "lock", isSecure: true)
            SNSTextField(text: $viewModel.confirmPassword, placeholder: "パスワード確認",
                         icon: "lock.fill", isSecure: true)

            Spacer().frame(height: 8)

            Button {
                viewModel.register()
            } label: {
                ZStack {
                    if viewModel.isRegistering {
                        ProgressView().tint(.white)
                    } else {
                        Text("登録")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(isFormFilled ? Color.appPrimary : Color.appPrimary.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isRegistering || !isFormFilled)

            Spacer().frame(height: 16)

            HStack(spacing: 4) {
                Text("すでにアカウントをお持ちですか？")
                    .foregroundStyle(Color.appTextSecondary)
                Button("ログイン") {
                    // ナビゲーションスタックをポップ
                }
                .foregroundStyle(.blue)
                .fontWeight(.bold)
            }
            .font(.system(size: 14))
        }
    }

    private var isFormFilled: Bool {
        !viewModel.displayName.isEmpty &&
        !viewModel.email.isEmpty &&
        viewModel.password.count >= 6 &&
        viewModel.password == viewModel.confirmPassword
    }
}
