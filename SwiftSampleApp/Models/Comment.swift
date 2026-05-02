//
//  Comment.swift
//  SwiftSampleApp
//

import Foundation

struct Comment: Codable, Equatable, Identifiable {
    var commentId: String
    var postId: String
    var userId: String
    var username: String
    var text: String
    var timestamp: Double   // Unix timestamp

    var id: String { commentId }

    static let collectionName = "comment"

    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
