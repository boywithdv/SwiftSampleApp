//
//  AvatarView.swift
//  SwiftSampleApp
//

import SwiftUI

struct AvatarView: View {
    let url: String?
    let initials: String
    var size: CGFloat = 40

    var body: some View {
        Group {
            if let urlString = url, let imageUrl = URL(string: urlString), !urlString.isEmpty {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        ZStack {
            Color.appPrimary.opacity(0.15)
            Text(initials.isEmpty ? "?" : initials)
                .font(.system(size: size * 0.35, weight: .semibold))
                .foregroundStyle(Color.appPrimary)
        }
    }
}
