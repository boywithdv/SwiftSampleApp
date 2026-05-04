//
//  RegisterViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import FirebaseAuth
import RxSwift
import RxCocoa
import RxFlow

final class RegisterViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published

    @Published var displayName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isRegistering: Bool = false
    @Published var errorText: String? = nil

    // MARK: - RxSwift Relays

    let displayNameRelay     = BehaviorRelay<String>(value: "")
    let emailRelay           = BehaviorRelay<String>(value: "")
    let passwordRelay        = BehaviorRelay<String>(value: "")
    let confirmPasswordRelay = BehaviorRelay<String>(value: "")
    let registerTrigger      = PublishRelay<Void>()
    let errorMessage         = PublishRelay<String>()

    var isFormValid: Observable<Bool> {
        Observable.combineLatest(displayNameRelay, emailRelay, passwordRelay, confirmPasswordRelay)
            .map { name, email, pw, confirm in
                !name.trimmingCharacters(in: .whitespaces).isEmpty &&
                !email.trimmingCharacters(in: .whitespaces).isEmpty &&
                pw.count >= 6 && pw == confirm
            }
    }

    // MARK: - Private

    private let authService: AuthServiceProtocol
    private let userRepository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol = AuthService.shared,
         userRepository: UserRepositoryProtocol = UserRepository.shared) {
        self.authService    = authService
        self.userRepository = userRepository
        super.init()
        bindPublishedToRelays()
        bindInputs()
    }

    // MARK: - Public

    func register() { registerTrigger.accept(()) }

    // MARK: - Private

    private func bindPublishedToRelays() {
        $displayName.sink { [weak self] in self?.displayNameRelay.accept($0) }.store(in: &cancellables)
        $email.sink       { [weak self] in self?.emailRelay.accept($0) }.store(in: &cancellables)
        $password.sink    { [weak self] in self?.passwordRelay.accept($0) }.store(in: &cancellables)
        $confirmPassword.sink { [weak self] in self?.confirmPasswordRelay.accept($0) }.store(in: &cancellables)
    }

    private func bindInputs() {
        registerTrigger
            .withLatestFrom(Observable.combineLatest(displayNameRelay, emailRelay, passwordRelay))
            .do(onNext: { [weak self] _ in
                DispatchQueue.main.async { self?.isRegistering = true }
            })
            .flatMapLatest { [weak self] name, email, password -> Observable<Event<Void>> in
                guard let self else { return .empty() }
                return self.authService.register(email: email, password: password)
                    .flatMap { user -> Single<Void> in
                        let model = UserModel(uid: user.uid, email: email, displayName: name)
                        return self.userRepository.createUser(model)
                    }
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] event in
                self?.isRegistering = false
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
    }
}
