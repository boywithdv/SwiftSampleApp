//
//  CreatePostViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class CreatePostViewModel: BaseViewModel {

    // MARK: - Inputs

    let messageRelay   = BehaviorRelay<String>(value: "")
    let submitTrigger  = PublishRelay<Void>()
    let cancelTrigger  = PublishRelay<Void>()

    // MARK: - Outputs

    let errorMessage   = PublishRelay<String>()
    let postSuccess    = PublishRelay<Void>()

    var isFormValid: Observable<Bool> {
        messageRelay.map { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    // MARK: - Private

    private let postRepository: PostRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()

    init(postRepository: PostRepositoryProtocol = PostRepository.shared,
         userRepository: UserRepositoryProtocol = UserRepository.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.postRepository = postRepository
        self.userRepository = userRepository
        self.authService    = authService
        super.init()
        bindInputs()
    }

    private func bindInputs() {
        submitTrigger
            .withLatestFrom(messageRelay)
            .do(onNext: { [weak self] _ in self?.isLoadingRelay.accept(true) })
            .flatMapLatest { [weak self] message -> Observable<Event<Void>> in
                guard let self, let uid = self.authService.currentUserId else { return .empty() }
                return self.userRepository.fetchUser(uid: uid)
                    .flatMap { user -> Single<Void> in
                        let username = user?.displayName ?? "匿名"
                        return self.postRepository.createPost(userId: uid, username: username, message: message)
                    }
                    .asObservable()
                    .materialize()
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.isLoadingRelay.accept(false) })
            .subscribe(onNext: { [weak self] event in
                switch event {
                case .next:
                    self?.postSuccess.accept(())
                case .error(let error):
                    self?.errorMessage.accept(error.localizedDescription)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}
