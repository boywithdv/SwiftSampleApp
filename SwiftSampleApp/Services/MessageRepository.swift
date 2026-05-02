//
//  MessageRepository.swift
//  SwiftSampleApp
//

import Foundation
import FirebaseFirestore
import RxSwift

protocol MessageRepositoryProtocol {
    func fetchMessages(senderId: String, receiverId: String) -> Observable<[Message]>
    func fetchConversationPartners(userId: String) -> Observable<[Message]>
    func sendMessage(_ message: Message) -> Single<Void>
    func markAsRead(messageId: String) -> Single<Void>
}

final class MessageRepository: MessageRepositoryProtocol {

    static let shared = MessageRepository()
    private let firestoreService = FirestoreService.shared
    private let db = Firestore.firestore()

    private init() {}

    func fetchMessages(senderId: String, receiverId: String) -> Observable<[Message]> {
        // Messages between two users (query both directions and merge)
        let sentObs = firestoreService.listenToCollection(Message.self, collection: Message.collectionName) { ref in
            ref.whereField("senderId", isEqualTo: senderId)
               .whereField("receiverId", isEqualTo: receiverId)
               .order(by: "timestamp", descending: false)
        }
        let receivedObs = firestoreService.listenToCollection(Message.self, collection: Message.collectionName) { ref in
            ref.whereField("senderId", isEqualTo: receiverId)
               .whereField("receiverId", isEqualTo: senderId)
               .order(by: "timestamp", descending: false)
        }

        return Observable.combineLatest(sentObs, receivedObs)
            .map { sent, received in
                (sent + received).sorted { $0.timestamp < $1.timestamp }
            }
    }

    func fetchConversationPartners(userId: String) -> Observable<[Message]> {
        // Latest message per conversation (simplified: fetch recent messages involving userId)
        firestoreService.listenToCollection(Message.self, collection: Message.collectionName) { ref in
            ref.whereField("senderId", isEqualTo: userId)
               .order(by: "timestamp", descending: true)
               .limit(to: 30)
        }
    }

    func sendMessage(_ message: Message) -> Single<Void> {
        let messageId = db.collection(Message.collectionName).document().documentID
        var msg = message
        msg = Message(
            messageId: messageId,
            senderId: message.senderId,
            senderEmail: message.senderEmail,
            receiverId: message.receiverId,
            message: message.message,
            timestamp: Date().timeIntervalSince1970,
            isRead: false
        )
        return firestoreService.setDocument(msg, collection: Message.collectionName, documentId: messageId)
    }

    func markAsRead(messageId: String) -> Single<Void> {
        firestoreService.updateDocument(
            ["isRead": true],
            collection: Message.collectionName,
            documentId: messageId
        )
    }
}
