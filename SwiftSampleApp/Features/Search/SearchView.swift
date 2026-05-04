//
//  SearchView.swift
//  SwiftSampleApp
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: SearchViewModel
    @FocusState private var isSearchFocused: Bool
    @State private var recentSearches: [String] = []

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            Divider()
            contentArea
        }
        .background(Color.appBackground.ignoresSafeArea())
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.appTextSecondary)
                TextField("ユーザーを検索", text: $viewModel.query)
                    .focused($isSearchFocused)
                    .submitLabel(.search)
                    .onSubmit {
                        if !viewModel.query.isEmpty {
                            addToRecent(viewModel.query)
                        }
                    }
                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.query = ""
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color(uiColor: .systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            if isSearchFocused || !viewModel.query.isEmpty {
                Button("キャンセル") {
                    viewModel.query = ""
                    isSearchFocused = false
                }
                .foregroundStyle(Color.appPrimary)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.appBackground)
    }

    // MARK: - Content Area (3ステート)

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.displayIsSearching {
            // ローディング
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if !viewModel.query.isEmpty {
            // 検索結果
            searchResultsList
        } else if isSearchFocused && !recentSearches.isEmpty {
            // 最近の検索
            recentSearchesList
        } else {
            // 初期状態: トレンドハッシュタグ
            initialStateView
        }
    }

    // MARK: - Search Results

    private var searchResultsList: some View {
        Group {
            if viewModel.displayUsers.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.appTextSecondary)
                    Text("「\(viewModel.query)」に一致するユーザーはいません")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.displayUsers) { user in
                            UserSearchRow(user: user) {
                                viewModel.selectUser(uid: user.uid)
                            }
                            Divider().padding(.leading, 68)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Recent Searches

    private var recentSearchesList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("最近の検索")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Spacer()
                    Button("すべて消去") { recentSearches.removeAll() }
                        .font(.system(size: 14))
                        .foregroundStyle(Color.appPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                ForEach(recentSearches, id: \.self) { term in
                    Button {
                        viewModel.query = term
                        isSearchFocused = false
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(Color.appTextSecondary)
                            Text(term)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    Divider().padding(.leading, 16)
                }
            }
        }
    }

    // MARK: - Initial State (トレンドハッシュタグ)

    private var initialStateView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("トレンド")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                FlowLayout(items: viewModel.trendingHashtags) { hashtag in
                    Button {
                        viewModel.query = hashtag
                    } label: {
                        Text(hashtag)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.appPrimary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.appPrimary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Helpers

    private func addToRecent(_ term: String) {
        guard !recentSearches.contains(term) else { return }
        recentSearches.insert(term, at: 0)
        if recentSearches.count > 10 { recentSearches.removeLast() }
    }
}

// MARK: - UserSearchRow

private struct UserSearchRow: View {
    let user: UserModel
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AvatarView(url: user.photoUrl.isEmpty ? nil : user.photoUrl,
                           initials: user.initials)
                VStack(alignment: .leading, spacing: 2) {
                    Text(user.displayName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text("\(user.followers.count) フォロワー")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FlowLayout（ハッシュタグ折り返しレイアウト）

private struct FlowLayout<Content: View>: View {
    let items: [String]
    let content: (String) -> Content

    init(items: [String], @ViewBuilder content: @escaping (String) -> Content) {
        self.items   = items
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            self.generateContent(in: geo)
        }
    }

    private func generateContent(in geo: GeometryProxy) -> some View {
        var width  = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                    .alignmentGuide(.leading)  { d in
                        if abs(width - d.width) > geo.size.width {
                            width = 0; height -= d.height
                        }
                        let result = width
                        if item == items.last { width = 0 } else { width -= d.width }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last { height = 0 }
                        return result
                    }
            }
        }
    }
}
