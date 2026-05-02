//
//  UserModel.swift
//  SwiftSampleApp
//

import Foundation

struct UserModel: Codable, Equatable, Identifiable {
    var id: String { uid }
    var uid: String
    var email: String
    var displayName: String
    var photoUrl: String
    var followers: [String]
    var following: [String]
    // GeoPoint は FirebaseFirestore 型のため、lat/lng として格納
    var latitude: Double?
    var longitude: Double?

    static let collectionName = "users"

    var initials: String {
        let parts = displayName.components(separatedBy: " ")
        let first = parts.first?.prefix(1) ?? ""
        let last  = parts.count > 1 ? parts.last?.prefix(1) ?? "" : ""
        return (first + last).uppercased()
    }
}

extension UserModel {
    init(uid: String, email: String, displayName: String) {
        self.uid         = uid
        self.email       = email
        self.displayName = displayName
        self.photoUrl    = ""
        self.followers   = []
        self.following   = []
    }
}
