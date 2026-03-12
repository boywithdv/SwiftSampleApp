//
//  TileDetailView.swift
//  SwiftSampleApp
//
//  Created by 佃 寿希也 on 2026/03/12.
//

import SwiftUI

struct TileDetailView: View {

    @StateObject private var viewModel: TileDetailViewModel

    init(viewModel: TileDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {

                // アイコン
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 120, height: 120)
                    Image(systemName: viewModel.item.iconName)
                        .font(.system(size: 52))
                        .foregroundColor(.blue)
                }
                .padding(.top, 48)

                // タイトル・説明
                VStack(spacing: 12) {
                    Text(viewModel.item.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(viewModel.item.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // プレースホルダーコンテンツ
                VStack(spacing: 16) {
                    ForEach(0..<3) { index in
                        PlaceholderCard(index: index + 1, title: viewModel.item.title)
                    }
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 32)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(viewModel.item.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - PlaceholderCard

private struct PlaceholderCard: View {
    let index: Int
    let title: String

    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 6) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray4))
                    .frame(height: 14)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.systemGray5))
                    .frame(width: 120, height: 12)
            }

            Spacer()
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }
}

// MARK: - SwiftUI Preview

#if DEBUG
import SwiftUI

struct TileDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TileDetailView(viewModel: TileDetailViewModel(item: .reservation))
            }
            .previewDisplayName("予約管理")

            NavigationView {
                TileDetailView(viewModel: TileDetailViewModel(item: .favorite))
            }
            .previewDisplayName("お気に入り")

            NavigationView {
                TileDetailView(viewModel: TileDetailViewModel(item: .browsing))
            }
            .previewDisplayName("閲覧履歴")
        }
    }
}
#endif
