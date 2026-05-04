//
//  FollowListViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

enum FollowListMode {
    case followers
    case following

    var title: String {
        switch self {
        case .followers: return "フォロワー"
        case .following: return "フォロー中"
        }
    }
}

final class FollowListViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published

    @Published var displayUsers: [UserModel] = []

    // MARK: - RxSwift Relays

    let users        = BehaviorRelay<[UserModel]>(value: [])
    let errorMessage = PublishRelay<String>()

    // MARK: - Public

    let mode: FollowListMode

    // MARK: - Private

    private let uid: String
    private let userRepository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(uid: String,
         mode: FollowListMode,
         userRepository: UserRepositoryProtocol = UserRepository.shared) {
        self.uid            = uid
        self.mode           = mode
        self.userRepository = userRepository
        super.init()
        bindRelaysToPublished()
        loadUsers()
    }

    // MARK: - Public

    func selectUser(uid: String) { steps.accept(AppStep.userProfile(uid)) }

    // MARK: - Private

    private func bindRelaysToPublished() {
        users
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayUsers = $0 })
            .disposed(by: disposeBag)
    }

    private func loadUsers() {
        let fetch = mode == .followers
            ? userRepository.fetchFollowers(uid: uid)
            : userRepository.fetchFollowing(uid: uid)

        fetch
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.users.accept($0) },
                       onError:  { [weak self] in self?.errorMessage.accept($0.localizedDescription) })
            .disposed(by: disposeBag)
    }
}
