//
//  TimelineViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class TimelineViewModel: BaseViewModel {

    // MARK: - Outputs

    let posts = BehaviorRelay<[UserPost]>(value: [])
    let errorMessage = PublishRelay<String>()

    // MARK: - Inputs

    let likeTrigger    = PublishRelay<String>()   // postId
    let createTrigger  = PublishRelay<Void>()
    let refreshTrigger = PublishRelay<Void>()

    // MARK: - Private

    private let postRepository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()

    var currentUserId: String? { authService.currentUserId }

    init(postRepository: PostRepositoryProtocol = PostRepository.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.postRepository = postRepository
        self.authService    = authService
        super.init()
        bindInputs()
        startListening()
    }

    // MARK: - Private

    private func startListening() {
        postRepository.fetchTimeline()
            .observe(on: MainScheduler.instance)
            .bind(to: posts)
            .disposed(by: disposeBag)
    }

    private func bindInputs() {
        likeTrigger
            .withLatestFrom(posts) { postId, posts in
                posts.first(where: { $0.postId == postId })
            }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] post in
                guard let self, let uid = self.currentUserId else { return }
                if post.isLikedBy(uid) {
                    self.postRepository.unlikePost(postId: post.postId, userId: uid)
                        .subscribe().disposed(by: self.disposeBag)
                } else {
                    self.postRepository.likePost(postId: post.postId, userId: uid)
                        .subscribe().disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)

        createTrigger
            .subscribe(onNext: { [weak self] in
                self?.steps.accept(AppStep.createPost)
            })
            .disposed(by: disposeBag)
    }
}
