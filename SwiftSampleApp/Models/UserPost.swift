//
//  UserPost.swift
//  SwiftSampleApp
//

import Foundation

struct UserPost: Codable, Equatable, Identifiable {
    var postId: String
    var userId: String
    var username: String
    var message: String
    var timestamp: Double   // Unix timestamp (seconds)
    var likes: [String]     // array of uid

    var id: String { postId }

    static let collectionName = "post"

    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }

    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    var isLiked: Bool {
        // Caller should pass currentUserId to check
        false
    }

    func isLikedBy(_ uid: String) -> Bool {
        likes.contains(uid)
    }
}
