//
//  EditProfileViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class EditProfileViewModel: BaseViewModel {

    // MARK: - Inputs

    let displayNameRelay = BehaviorRelay<String>(value: "")
    let saveTrigger      = PublishRelay<Void>()
    let cancelTrigger    = PublishRelay<Void>()

    // MARK: - Outputs

    let saveSuccess  = PublishRelay<Void>()
    let errorMessage = PublishRelay<String>()

    var isFormValid: Observable<Bool> {
        displayNameRelay.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    // MARK: - Private

    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(authService: AuthServiceProtocol = AuthService.shared,
         userRepository: UserRepositoryProtocol = UserRepository.shared) {
        self.authService    = authService
        self.userRepository = userRepository
        super.init()
        loadCurrentProfile()
        bindInputs()
    }

    // MARK: - Private

    private func loadCurrentProfile() {
        guard let uid = authService.currentUserId else { return }
        userRepository.fetchUser(uid: uid)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] user in
                self?.displayNameRelay.accept(user?.displayName ?? "")
            })
            .disposed(by: disposeBag)
    }

    private func bindInputs() {
        saveTrigger
            .withLatestFrom(displayNameRelay)
            .do(onNext: { [weak self] _ in self?.isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] name -> Observable<Event<Void>> in
                guard let self, let uid = self.authService.currentUserId else { return .empty() }
                return self.userRepository.fetchUser(uid: uid)
                    .flatMap { current -> Single<Void> in
                        guard var user = current else { return .just(()) }
                        user.displayName = name
                        return self.userRepository.updateUser(user)
                    }
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.isLoadingRelay.accept(false) })
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next:
                    self?.saveSuccess.accept(())
                case .error(let error):
                    self?.errorMessage.accept(error.localizedDescription)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
