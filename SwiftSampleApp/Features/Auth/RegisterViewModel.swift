//
//  RegisterViewModel.swift
//  SwiftSampleApp
//

import Foundation
import FirebaseAuth
import RxSwift
import RxCocoa
import RxFlow

final class RegisterViewModel: BaseViewModel {

    // MARK: - Inputs

    let displayNameRelay  = BehaviorRelay<String>(value: "")
    let emailRelay        = BehaviorRelay<String>(value: "")
    let passwordRelay     = BehaviorRelay<String>(value: "")
    let confirmPasswordRelay = BehaviorRelay<String>(value: "")
    let registerTrigger   = PublishRelay<Void>()

    // MARK: - Outputs

    let errorMessage = PublishRelay<String>()

    var isFormValid: Observable<Bool> {
        Observable.combineLatest(displayNameRelay, emailRelay, passwordRelay, confirmPasswordRelay)
            .map { name, email, password, confirm in
                !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                !email.trimmingCharacters(in: .whitespaces).isEmpty &&
                password.count >= 6 &&
                password == confirm
            }
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
        bindInputs()
    }

    // MARK: - Bindings

    private func bindInputs() {
        registerTrigger
            .withLatestFrom(Observable.combineLatest(displayNameRelay, emailRelay, passwordRelay))
            .do(onNext: { [weak self] _ in self?.isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] name, email, password -> Observable<Event<Void>> in
                guard let self else { return .empty() }
                return self.authService.register(email: email, password: password)
                    .flatMap { user -> Single<Void> in
                        var model = UserModel(uid: user.uid, email: email, displayName: name)
                        return self.userRepository.createUser(model)
                    }
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.isLoadingRelay.accept(false) })
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next:
                    self?.steps.accept(AppStep.loginComplete)
                case .error(let error):
                    self?.errorMessage.accept(error.localizedDescription)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
