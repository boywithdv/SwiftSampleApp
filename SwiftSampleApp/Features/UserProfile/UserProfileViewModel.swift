//
//  UserProfileViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class UserProfileViewModel: BaseViewModel {

    // MARK: - Outputs

    let targetUser   = BehaviorRelay<UserModel?>(value: nil)
    let posts        = BehaviorRelay<[UserPost]>(value: [])
    let isFollowing  = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()

    // MARK: - Inputs

    let followTrigger  = PublishRelay<Void>()
    let messageTrigger = PublishRelay<Void>()
    let followersTrigger = PublishRelay<Void>()
    let followingTrigger = PublishRelay<Void>()

    // MARK: - Private

    private let targetUid: String
    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let postRepository: PostRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(targetUid: String,
         authService: AuthServiceProtocol = AuthService.shared,
         userRepository: UserRepositoryProtocol = UserRepository.shared,
         postRepository: PostRepositoryProtocol = PostRepository.shared) {
        self.targetUid      = targetUid
        self.authService    = authService
        self.userRepository = userRepository
        self.postRepository = postRepository
        super.init()
        loadProfile()
        bindInputs()
    }

    // MARK: - Private

    private func loadProfile() {
        guard let currentUid = authService.currentUserId else { return }

        userRepository.fetchUser(uid: targetUid)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let self, let user else { return }
                self.targetUser.accept(user)
                self.isFollowing.accept(user.followers.contains(currentUid))
            })
            .disposed(by: disposeBag)

        postRepository.fetchPostsByUser(userId: targetUid)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                self?.posts.accept(posts)
            })
            .disposed(by: disposeBag)
    }

    private func bindInputs() {
        followTrigger
            .withLatestFrom(isFollowing)
            .subscribe(onNext: { [weak self] isFollowing in
                guard let self, let currentUid = self.authService.currentUserId else { return }
                if isFollowing {
                    self.userRepository.unfollow(targetUid: self.targetUid, currentUid: currentUid)
                        .subscribe().disposed(by: self.disposeBag)
                    self.isFollowing.accept(false)
                } else {
                    self.userRepository.follow(targetUid: self.targetUid, currentUid: currentUid)
                        .subscribe().disposed(by: self.disposeBag)
                    self.isFollowing.accept(true)
                }
            })
            .disposed(by: disposeBag)

        messageTrigger
            .withLatestFrom(targetUser)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] user in
                self?.steps.accept(AppStep.chatThread(user))
            })
            .disposed(by: disposeBag)

        followersTrigger
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.steps.accept(AppStep.followersList(self.targetUid))
            })
            .disposed(by: disposeBag)

        followingTrigger
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                self.steps.accept(AppStep.followingList(self.targetUid))
            })
            .disposed(by: disposeBag)
    }
}
