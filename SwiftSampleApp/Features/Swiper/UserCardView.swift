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
            // Background
            RoundedRectangle(cornerRadius: AppTheme.CornerRadius.card)
                .fill(Color.appSurface)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 2)

            // Avatar area
            ZStack {
                Circle()
                    .fill(Color.appPrimary.opacity(0.15))
                    .frame(width: 120, height: 120)

                Text(user.initials)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color.appPrimary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom info overlay
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.displayName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)

                        Text(user.email)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                    }

                    Spacer()

                    Button(action: onProfile) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white)
                    }
                }
                .padding()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(AppTheme.CornerRadius.card)
            )
        }
    }
}
