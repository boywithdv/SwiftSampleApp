//
//  ChatThreadViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class ChatThreadViewModel: BaseViewModel, ObservableObject {

    // MARK: - Outputs

    @Published var messages: [Message] = []
    @Published var messageText: String = ""
    @Published var isSending: Bool = false

    let recipient: UserModel
    let errorMessage = PublishRelay<String>()

    var currentUserId: String? { authService.currentUserId }

    // MARK: - Private

    private let messageRepository: MessageRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let disposeBag = DisposeBag()

    init(recipient: UserModel,
         messageRepository: MessageRepositoryProtocol = MessageRepository.shared,
         authService: AuthServiceProtocol = AuthService.shared) {
        self.recipient         = recipient
        self.messageRepository = messageRepository
        self.authService       = authService
        super.init()
        listenToMessages()
    }

    // MARK: - Public

    func sendMessage() {
        guard let uid = authService.currentUserId,
              !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        isSending = true
        let msg = Message(
            messageId: "",
            senderId: uid,
            senderEmail: "",
            receiverId: recipient.uid,
            message: messageText,
            timestamp: Date().timeIntervalSince1970,
            isRead: false
        )

        messageRepository.sendMessage(msg)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.isSending = false
                self?.messageText = ""
            }, onFailure: { [weak self] error in
                self?.isSending = false
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Private

    private func listenToMessages() {
        guard let uid = authService.currentUserId else { return }

        messageRepository.fetchMessages(senderId: uid, receiverId: recipient.uid)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msgs in
                guard let self else { return }
                self.messages = msgs.map { msg in
                    var m = msg
                    m.isMine = (msg.senderId == uid)
                    return m
                }
            }, onError: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }
}
