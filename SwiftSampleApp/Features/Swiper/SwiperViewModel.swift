//
//  SwiperViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class SwiperViewModel: BaseViewModel, ObservableObject {

    // MARK: - Outputs

    @Published var cards: [UserModel] = []
    @Published var isFetching: Bool = false
    @Published var isEmpty: Bool = false

    let errorMessage = PublishRelay<String>()

    // MARK: - Private

    private let userRepository: UserRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()
    private var skippedIds = Set<String>()

    init(userRepository: UserRepositoryProtocol = UserRepository.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.userRepository = userRepository
        self.authService    = authService
        super.init()
        loadUsers()
    }

    // MARK: - Public

    func swipeRight(user: UserModel) {
        guard let currentUid = authService.currentUserId else { return }
        removeCard(user: user)
        userRepository.follow(targetUid: user.uid, currentUid: currentUid)
            .subscribe().disposed(by: disposeBag)
    }

    func swipeLeft(user: UserModel) {
        skippedIds.insert(user.uid)
        removeCard(user: user)
    }

    func tapProfile(user: UserModel) {
        steps.accept(AppStep.userProfile(user.uid))
    }

    // MARK: - Private

    private func loadUsers() {
        guard let currentUid = authService.currentUserId else { return }
        isFetching = true

        userRepository.fetchAllUsers()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                guard let self else { return }
                self.isFetching = false
                let filtered = users.filter { $0.uid != currentUid && !self.skippedIds.contains($0.uid) }
                self.cards = filtered
                self.isEmpty = filtered.isEmpty
            }, onError: { [weak self] error in
                self?.isFetching = false
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    private func removeCard(user: UserModel) {
        cards.removeAll { $0.uid == user.uid }
        isEmpty = cards.isEmpty
    }
}
