//
//  TimelineViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class TimelineViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published (SwiftUI binding)

    @Published var displayPosts: [UserPost] = []

    // MARK: - RxSwift Relays

    let posts        = BehaviorRelay<[UserPost]>(value: [])
    let errorMessage = PublishRelay<String>()
    let likeTrigger  = PublishRelay<String>()
    let createTrigger = PublishRelay<Void>()

    var currentUserId: String? { authService.currentUserId }

    // MARK: - Private

    private let postRepository: PostRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()

    init(postRepository: PostRepositoryProtocol = PostRepository.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.postRepository = postRepository
        self.authService    = authService
        super.init()
        bindRelaysToPublished()
        bindInputs()
        startListening()
    }

    // MARK: - Public actions (SwiftUI callbacks)

    func tapPost(_ post: UserPost) { steps.accept(AppStep.postDetail(post)) }
    func tapUser(uid: String)     { steps.accept(AppStep.userProfile(uid)) }
    func tapChat()                { steps.accept(AppStep.allChats) }
    func tapCreate()              { steps.accept(AppStep.createPost) }

    func toggleLike(postId: String) { likeTrigger.accept(postId) }

    // MARK: - Private

    private func bindRelaysToPublished() {
        posts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayPosts = $0 })
            .disposed(by: disposeBag)
    }

    private func startListening() {
        postRepository.fetchTimeline()
            .observe(on: MainScheduler.instance)
            .bind(to: posts)
            .disposed(by: disposeBag)
    }

    private func bindInputs() {
        likeTrigger
            .withLatestFrom(posts) { postId, posts in posts.first { $0.postId == postId } }
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
            .subscribe(onNext: { [weak self] in self?.steps.accept(AppStep.createPost) })
            .disposed(by: disposeBag)
    }
}
