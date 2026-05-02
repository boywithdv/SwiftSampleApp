//
//  PostDetailViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class PostDetailViewModel: BaseViewModel, ObservableObject {

    // MARK: - Outputs

    @Published var post: UserPost
    @Published var comments: [Comment] = []
    @Published var isSending: Bool = false
    @Published var commentText: String = ""

    let errorMessage = PublishRelay<String>()

    var currentUserId: String? { authService.currentUserId }

    // MARK: - Private

    private let commentRepository: CommentRepositoryProtocol
    private let postRepository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()

    init(post: UserPost,
         commentRepository: CommentRepositoryProtocol = CommentRepository.shared,
         postRepository: PostRepositoryProtocol = PostRepository.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.post = post
        self.commentRepository = commentRepository
        self.postRepository    = postRepository
        self.authService       = authService
        super.init()
        listenToComments()
    }

    // MARK: - Public

    func toggleLike() {
        guard let uid = authService.currentUserId else { return }
        if post.isLikedBy(uid) {
            postRepository.unlikePost(postId: post.postId, userId: uid)
                .subscribe().disposed(by: disposeBag)
        } else {
            postRepository.likePost(postId: post.postId, userId: uid)
                .subscribe().disposed(by: disposeBag)
        }
    }

    func submitComment() {
        guard let uid = authService.currentUserId,
              !commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isSending = true
        let comment = Comment(
            commentId: "",
            postId: post.postId,
            userId: uid,
            username: "",
            text: commentText,
            timestamp: Date().timeIntervalSince1970
        )
        commentRepository.addComment(comment)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.isSending = false
                self?.commentText = ""
            }, onFailure: { [weak self] error in
                self?.isSending = false
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private

    private func listenToComments() {
        commentRepository.fetchComments(postId: post.postId)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] comments in
                self?.comments = comments
            })
            .disposed(by: disposeBag)
    }
}
