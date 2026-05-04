//
//  UserProfileViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class UserProfileViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published

    @Published var displayTargetUser: UserModel? = nil
    @Published var displayPosts: [UserPost] = []
    @Published var displayIsFollowing: Bool = false

    // MARK: - RxSwift Relays

    let targetUser   = BehaviorRelay<UserModel?>(value: nil)
    let posts        = BehaviorRelay<[UserPost]>(value: [])
    let isFollowing  = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()

    let followTrigger    = PublishRelay<Void>()
    let messageTrigger   = PublishRelay<Void>()
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
        bindRelaysToPublished()
        loadProfile()
        bindInputs()
    }

    // MARK: - Public actions

    func tapFollow()     { followTrigger.accept(()) }
    func tapMessage()    { messageTrigger.accept(()) }
    func tapFollowers()  { followersTrigger.accept(()) }
    func tapFollowing()  { followingTrigger.accept(()) }
    func tapPost(_ p: UserPost) { steps.accept(AppStep.postDetail(p)) }

    // MARK: - Private

    private func bindRelaysToPublished() {
        targetUser
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayTargetUser = $0 })
            .disposed(by: disposeBag)

        posts
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayPosts = $0 })
            .disposed(by: disposeBag)

        isFollowing
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayIsFollowing = $0 })
            .disposed(by: disposeBag)
    }

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
            .subscribe(onNext: { [weak self] in self?.posts.accept($0) })
            .disposed(by: disposeBag)
    }

    private func bindInputs() {
        followTrigger
            .withLatestFrom(isFollowing)
            .subscribe(onNext: { [weak self] following in
                guard let self, let uid = self.authService.currentUserId else { return }
                if following {
                    self.userRepository.unfollow(targetUid: self.targetUid, currentUid: uid)
                        .subscribe().disposed(by: self.disposeBag)
                    self.isFollowing.accept(false)
                } else {
                    self.userRepository.follow(targetUid: self.targetUid, currentUid: uid)
                        .subscribe().disposed(by: self.disposeBag)
                    self.isFollowing.accept(true)
                }
            })
            .disposed(by: disposeBag)

        messageTrigger
            .withLatestFrom(targetUser).compactMap { $0 }
            .subscribe(onNext: { [weak self] in self?.steps.accept(AppStep.chatThread($0)) })
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
