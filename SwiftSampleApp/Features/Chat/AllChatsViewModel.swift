//
//  AllChatsViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class AllChatsViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published

    @Published var displayConversations: [(Message, UserModel?)] = []

    // MARK: - RxSwift Relays

    let conversations = BehaviorRelay<[(Message, UserModel?)]>(value: [])
    let errorMessage  = PublishRelay<String>()

    // MARK: - Private

    private let messageRepository: MessageRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()

    init(messageRepository: MessageRepositoryProtocol = MessageRepository.shared,
         userRepository: UserRepositoryProtocol = UserRepository.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.messageRepository = messageRepository
        self.userRepository    = userRepository
        self.authService       = authService
        super.init()
        bindRelaysToPublished()
        loadConversations()
    }

    // MARK: - Public

    func selectConversation(user: UserModel) {
        steps.accept(AppStep.chatThread(user))
    }

    // MARK: - Private

    private func bindRelaysToPublished() {
        conversations
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayConversations = $0 })
            .disposed(by: disposeBag)
    }

    private func loadConversations() {
        guard let uid = authService.currentUserId else { return }

        messageRepository.fetchConversationPartners(userId: uid)
            .flatMap { [weak self] messages -> Observable<[(Message, UserModel?)]> in
                guard let self else { return .just([]) }
                var seen = Set<String>()
                let unique = messages.filter { seen.insert($0.receiverId).inserted }
                let fetches = unique.map { message in
                    self.userRepository.fetchUser(uid: message.receiverId)
                        .map { (message, $0) }
                        .asObservable()
                        .catchAndReturn((message, nil))
                }
                return Observable.zip(fetches)
            }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] pairs in
                self?.conversations.accept(pairs)
            }, onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
