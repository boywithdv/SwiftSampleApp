//
//  LoginView.swift
//  SwiftSampleApp
//
//  NOTE: RiveRuntime が SPM で追加済みの場合のみ Rive ロゴが表示されます。
//  未追加の場合は SF Symbol のフォールバックが使われます。
//  SPM: https://github.com/rive-app/rive-ios
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @State private var showError = false

    var body: some View {
        ZStack {
            loginBackground
            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.08)
                    logoArea
                    Spacer().frame(height: UIScreen.main.bounds.height * 0.04)
                    formArea
                }
                .padding(.horizontal, 28)
            }
        }
        .ignoresSafeArea()
        .alert("ログインエラー", isPresented: $showError, presenting: viewModel.errorText) { _ in
            Button("OK") {}
        } message: { msg in
            Text(msg)
        }
        .onChange(of: viewModel.errorText) { text in
            showError = text != nil
        }
    }

    // MARK: - Background

    private var loginBackground: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            // デコレーション円（Flutter の LoginRegisterBackground 相当）
            Circle()
                .fill(Color.appPrimary.opacity(0.12))
                .frame(width: 300, height: 300)
                .offset(x: -120, y: -200)
            Circle()
                .fill(Color.appPrimary.opacity(0.08))
                .frame(width: 200, height: 200)
                .offset(x: 160, y: -120)
            Circle()
                .fill(Color.appSecondary.opacity(0.08))
                .frame(width: 150, height: 150)
                .offset(x: 120, y: 300)
        }
    }

    // MARK: - Logo

    private var logoArea: some View {
        VStack(spacing: 16) {
            RiveLogoView()
                .frame(width: 140, height: 140)

            Text("Welcome Personal Station!")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.appTextSecondary)
        }
    }

    // MARK: - Form

    private var formArea: some View {
        VStack(spacing: 12) {
            SNSTextField(
                text: $viewModel.email,
                placeholder: "Email",
                icon: "envelope",
                keyboardType: .emailAddress
            )

            SNSTextField(
                text: $viewModel.password,
                placeholder: "Password",
                icon: "lock",
                isSecure: true
            )

            Spacer().frame(height: 8)

            // Sign in button
            Button {
                viewModel.signIn()
            } label: {
                ZStack {
                    if viewModel.isSigningIn {
                        ProgressView().tint(.white)
                    } else {
                        Text("Sign in")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    viewModel.email.isEmpty || viewModel.password.count < 6
                        ? Color.appPrimary.opacity(0.5)
                        : Color.appPrimary
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isSigningIn || viewModel.email.isEmpty || viewModel.password.count < 6)

            Spacer().frame(height: 16)

            HStack(spacing: 4) {
                Text("Not a member?")
                    .foregroundStyle(Color.appTextSecondary)
                Button("Register now") {
                    viewModel.goToRegister()
                }
                .foregroundStyle(.blue)
                .fontWeight(.bold)
            }
            .font(.system(size: 14))
        }
    }
}

// MARK: - Rive Logo View

private struct RiveLogoView: View {
    var body: some View {
        // RiveRuntime が利用可能な場合は以下のコードを使用:
        // RiveViewModel(fileName: "icons", artboardName: "USER",
        //               stateMachineName: "USER_Interactivity").view()
        //     .clipShape(Circle())

        // フォールバック: SF Symbol ベースのロゴ
        ZStack {
            Circle()
                .fill(Color.appPrimary)
            Image(systemName: "location.north.fill")
                .font(.system(size: 54, weight: .medium))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - SNSTextField

struct SNSTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    @State private var isPasswordVisible = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 20)

            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }

            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color(uiColor: .systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
