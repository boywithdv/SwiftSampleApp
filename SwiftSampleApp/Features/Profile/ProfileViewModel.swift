//
//  ProfileViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class ProfileViewModel: BaseViewModel {

    // MARK: - Outputs

    let currentUser  = BehaviorRelay<UserModel?>(value: nil)
    let posts        = BehaviorRelay<[UserPost]>(value: [])
    let errorMessage = PublishRelay<String>()

    // MARK: - Inputs

    let logoutTrigger    = PublishRelay<Void>()
    let editTrigger      = PublishRelay<Void>()
    let chatsTrigger     = PublishRelay<Void>()
    let followersTrigger = PublishRelay<Void>()
    let followingTrigger = PublishRelay<Void>()

    // MARK: - Private

    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let postRepository: PostRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(authService: AuthServiceProtocol = AuthService.shared,
         userRepository: UserRepositoryProtocol = UserRepository.shared,
         postRepository: PostRepositoryProtocol = PostRepository.shared) {
        self.authService    = authService
        self.userRepository = userRepository
        self.postRepository = postRepository
        super.init()
        loadProfile()
        bindInputs()
    }

    // MARK: - Private

    private func loadProfile() {
        guard let uid = authService.currentUserId else { return }

        userRepository.fetchUser(uid: uid)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.currentUser.accept(user)
            })
            .disposed(by: disposeBag)

        postRepository.fetchPostsByUser(userId: uid)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] posts in
                self?.posts.accept(posts)
            })
            .disposed(by: disposeBag)
    }

    private func bindInputs() {
        logoutTrigger
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                try? self.authService.signOut()
                self.steps.accept(AppStep.logoutComplete)
            })
            .disposed(by: disposeBag)

        editTrigger
            .subscribe(onNext: { [weak self] in
                self?.steps.accept(AppStep.editProfile)
            })
            .disposed(by: disposeBag)

        chatsTrigger
            .subscribe(onNext: { [weak self] in
                self?.steps.accept(AppStep.allChats)
            })
            .disposed(by: disposeBag)

        followersTrigger
            .subscribe(onNext: { [weak self] in
                guard let uid = self?.authService.currentUserId else { return }
                self?.steps.accept(AppStep.followersList(uid))
            })
            .disposed(by: disposeBag)

        followingTrigger
            .subscribe(onNext: { [weak self] in
                guard let uid = self?.authService.currentUserId else { return }
                self?.steps.accept(AppStep.followingList(uid))
            })
            .disposed(by: disposeBag)
    }
}
