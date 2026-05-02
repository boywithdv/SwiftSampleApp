//
//  LoginViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class LoginViewModel: BaseViewModel {

    // MARK: - Inputs

    let emailRelay    = BehaviorRelay<String>(value: "")
    let passwordRelay = BehaviorRelay<String>(value: "")
    let loginTrigger  = PublishRelay<Void>()
    let registerTrigger = PublishRelay<Void>()

    // MARK: - Outputs

    let errorMessage = PublishRelay<String>()

    var isFormValid: Observable<Bool> {
        Observable.combineLatest(emailRelay, passwordRelay)
            .map { email, password in
                !email.trimmingCharacters(in: .whitespaces).isEmpty && password.count >= 6
            }
    }

    // MARK: - Private

    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(authService: AuthServiceProtocol = AuthService.shared,
         userRepository: UserRepositoryProtocol = UserRepository.shared) {
        self.authService   = authService
        self.userRepository = userRepository
        super.init()
        bindInputs()
    }

    // MARK: - Bindings

    private func bindInputs() {
        loginTrigger
            .withLatestFrom(Observable.combineLatest(emailRelay, passwordRelay))
            .do(onNext: { [weak self] _ in self?.isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] email, password -> Observable<Event<Void>> in
                guard let self else { return .empty() }
                return self.authService.signIn(email: email, password: password)
                    .map { _ in }
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

        registerTrigger
            .subscribe(onNext: { [weak self] in
                self?.steps.accept(AppStep.showRegister)
            })
            .disposed(by: disposeBag)
    }
}
