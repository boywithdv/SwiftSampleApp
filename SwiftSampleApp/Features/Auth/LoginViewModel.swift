//
//  LoginViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class LoginViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isSigningIn: Bool = false
    @Published var errorText: String? = nil

    // MARK: - RxSwift Relays

    let emailRelay      = BehaviorRelay<String>(value: "")
    let passwordRelay   = BehaviorRelay<String>(value: "")
    let loginTrigger    = PublishRelay<Void>()
    let registerTrigger = PublishRelay<Void>()
    let errorMessage    = PublishRelay<String>()

    var isFormValid: Observable<Bool> {
        Observable.combineLatest(emailRelay, passwordRelay)
            .map { e, p in !e.trimmingCharacters(in: .whitespaces).isEmpty && p.count >= 6 }
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
        bindPublishedToRelays()
        bindInputs()
    }

    // MARK: - Public (SwiftUI actions)

    func signIn() {
        loginTrigger.accept(())
    }

    func goToRegister() {
        steps.accept(AppStep.showRegister)
    }

    // MARK: - Private

    private func bindPublishedToRelays() {
        $email
            .sink { [weak self] in self?.emailRelay.accept($0) }
            .store(in: &cancellables)
        $password
            .sink { [weak self] in self?.passwordRelay.accept($0) }
            .store(in: &cancellables)
    }

    private var cancellables = Set<AnyCancellable>()

    private func bindInputs() {
        loginTrigger
            .withLatestFrom(Observable.combineLatest(emailRelay, passwordRelay))
            .do(onNext: { [weak self] _ in
                DispatchQueue.main.async { self?.isSigningIn = true }
            })
            .flatMapLatest { [weak self] email, password -> Observable<Event<Void>> in
                guard let self else { return .empty() }
                return self.authService.signIn(email: email, password: password)
                    .map { _ in }
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                self?.isSigningIn = false
                switch event {
                case .next:
                    self?.steps.accept(AppStep.loginComplete)
                case .error(let error):
                    self?.errorText = error.localizedDescription
                    self?.errorMessage.accept(error.localizedDescription)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)

        registerTrigger
            .subscribe(onNext: { [weak self] in self?.steps.accept(AppStep.showRegister) })
            .disposed(by: disposeBag)
    }
}
