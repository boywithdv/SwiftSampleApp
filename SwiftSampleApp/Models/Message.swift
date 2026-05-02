//
//  Message.swift
//  SwiftSampleApp
//

import Foundation

struct Message: Codable, Equatable, Identifiable {
    var messageId: String
    var senderId: String
    var senderEmail: String
    var receiverId: String
    var message: String
    var timestamp: Double   // Unix timestamp
    var isRead: Bool

    var id: String { messageId }

    static let collectionName = "messages"

    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }

    var isMine: Bool = false  // Set by ViewModel based on currentUser
}
