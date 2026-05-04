//
//  EditProfileViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class EditProfileViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published

    @Published var displayName: String = ""
    @Published var isSaving: Bool = false
    @Published var errorText: String? = nil
    @Published var didSave: Bool = false

    // MARK: - RxSwift Relays

    let displayNameRelay = BehaviorRelay<String>(value: "")
    let saveTrigger      = PublishRelay<Void>()
    let cancelTrigger    = PublishRelay<Void>()
    let saveSuccess      = PublishRelay<Void>()
    let errorMessage     = PublishRelay<String>()

    var isFormValid: Observable<Bool> {
        displayNameRelay.map { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
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
        loadCurrentProfile()
        bindInputs()
    }

    // MARK: - Public

    func save()   { saveTrigger.accept(()) }
    func cancel() { cancelTrigger.accept(()) }

    // MARK: - Private

    private func bindPublishedToRelays() {
        $displayName.sink { [weak self] in self?.displayNameRelay.accept($0) }.store(in: &cancellables)
    }

    private func loadCurrentProfile() {
        guard let uid = authService.currentUserId else { return }
        userRepository.fetchUser(uid: uid)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] user in
                let name = user?.displayName ?? ""
                self?.displayNameRelay.accept(name)
                DispatchQueue.main.async { self?.displayName = name }
            })
            .disposed(by: disposeBag)
    }

    private func bindInputs() {
        saveTrigger
            .withLatestFrom(displayNameRelay)
            .do(onNext: { [weak self] _ in
                DispatchQueue.main.async { self?.isSaving = true }
            })
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
            .subscribe(onNext: { [weak self] event in
                self?.isSaving = false
                switch event {
                case .next:
                    self?.didSave = true
                    self?.saveSuccess.accept(())
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
