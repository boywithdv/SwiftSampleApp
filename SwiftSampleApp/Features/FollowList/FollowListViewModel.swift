//
//  FollowListViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class FollowListViewModel: BaseViewModel {

    // MARK: - Outputs

    let users        = BehaviorRelay<[UserModel]>(value: [])
    let errorMessage = PublishRelay<String>()

    // MARK: - Private

    private let uid: String
    private let mode: FollowListViewController.Mode
    private let userRepository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(uid: String,
         mode: FollowListViewController.Mode,
         userRepository: UserRepositoryProtocol = UserRepository.shared) {
        self.uid            = uid
        self.mode           = mode
        self.userRepository = userRepository
        super.init()
        loadUsers()
    }

    func selectUser(uid: String) {
        steps.accept(AppStep.userProfile(uid))
    }

    private func loadUsers() {
        let fetch = mode == .followers
            ? userRepository.fetchFollowers(uid: uid)
            : userRepository.fetchFollowing(uid: uid)

        fetch
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                self?.users.accept(users)
            }, onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
