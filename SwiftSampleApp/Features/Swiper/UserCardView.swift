//
//  UserCardView.swift
//  SwiftSampleApp
//

import SwiftUI

struct UserCardView: View {
    let user: UserModel
    let onProfile: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            cardBackground
            avatarSection
            infoOverlay
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.20), radius: 20, x: 0, y: 10)
    }

    // MARK: - Card Background

    private var cardBackground: some View {
        LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Centered Avatar

    private var avatarSection: some View {
        VStack {
            Spacer().frame(height: 52)
            ZStack {
                Circle()
                    .fill(.white.opacity(0.18))
                    .frame(width: 168, height: 168)
                Circle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 136, height: 136)
                Text(user.initials.isEmpty ? "?" : user.initials)
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom Info Overlay

    private var infoOverlay: some View {
        HStack(alignment: .bottom, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(user.displayName.isEmpty ? "ゲスト" : user.displayName)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Label("\(user.followers.count) フォロワー", systemImage: "person.2.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.90))
            }

            Spacer()

            Button(action: onProfile) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.22))
                        .frame(width: 48, height: 48)
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("プロフィールを見る")
        }
        .padding(.horizontal, 22)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(bottomGradient)
    }

    private var bottomGradient: some View {
        LinearGradient(
            colors: [.clear, .black.opacity(0.35), .black.opacity(0.72)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Gradient Colors (uid hash → consistent color per user)

    private var gradientColors: [Color] {
        let palettes: [[Color]] = [
            [Color(hex: "667eea"), Color(hex: "764ba2")],
            [Color(hex: "f093fb"), Color(hex: "f5576c")],
            [Color(hex: "4facfe"), Color(hex: "00f2fe")],
            [Color(hex: "43e97b"), Color(hex: "38f9d7")],
            [Color(hex: "fa709a"), Color(hex: "fee140")],
            [Color(hex: "30cfd0"), Color(hex: "667eea")],
            [Color(hex: "a18cd1"), Color(hex: "fbc2eb")],
            [Color(hex: "f77062"), Color(hex: "fe5196")],
        ]
        let index = abs(user.uid.hashValue) % palettes.count
        return palettes[index]
    }
}

// MARK: - Color(hex:)

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xff) / 255
        let g = Double((int >> 8)  & 0xff) / 255
        let b = Double(int         & 0xff) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview

#Preview("カード - 通常") {
    UserCardView(
        user: UserModel(uid: "uid-preview-1", email: "alice@example.com", displayName: "Alice Smith"),
        onProfile: {}
    )
    .frame(width: 360, height: 520)
    .padding(24)
    .background(Color(.systemGroupedBackground))
}

#Preview("カード - 日本語名") {
    UserCardView(
        user: UserModel(uid: "uid-preview-2", email: "taro@example.com", displayName: "田中 太郎"),
        onProfile: {}
    )
    .frame(width: 360, height: 520)
    .padding(24)
    .background(Color(.systemGroupedBackground))
}
