//
//  UserRepository.swift
//  SwiftSampleApp
//

import Foundation
import FirebaseFirestore
import RxSwift

protocol UserRepositoryProtocol {
    func createUser(_ model: UserModel) -> Single<Void>
    func fetchUser(uid: String) -> Single<UserModel?>
    func updateUser(_ model: UserModel) -> Single<Void>
    func updateLocation(uid: String, latitude: Double, longitude: Double) -> Single<Void>
    func fetchAllUsers() -> Single<[UserModel]>
    func searchUsers(query: String) -> Single<[UserModel]>
    func follow(targetUid: String, currentUid: String) -> Single<Void>
    func unfollow(targetUid: String, currentUid: String) -> Single<Void>
    func fetchFollowers(uid: String) -> Single<[UserModel]>
    func fetchFollowing(uid: String) -> Single<[UserModel]>
}

final class UserRepository: UserRepositoryProtocol {

    static let shared = UserRepository()
    private let firestoreService = FirestoreService.shared
    private let db = Firestore.firestore()

    private init() {}

    func createUser(_ model: UserModel) -> Single<Void> {
        firestoreService.setDocument(model, collection: UserModel.collectionName, documentId: model.uid)
    }

    func fetchUser(uid: String) -> Single<UserModel?> {
        firestoreService.fetchDocument(UserModel.self, collection: UserModel.collectionName, documentId: uid)
    }

    func updateUser(_ model: UserModel) -> Single<Void> {
        firestoreService.setDocument(model, collection: UserModel.collectionName, documentId: model.uid)
    }

    func updateLocation(uid: String, latitude: Double, longitude: Double) -> Single<Void> {
        firestoreService.updateDocument(
            ["latitude": latitude, "longitude": longitude],
            collection: UserModel.collectionName,
            documentId: uid
        )
    }

    func fetchAllUsers() -> Single<[UserModel]> {
        firestoreService.fetchCollection(UserModel.self, collection: UserModel.collectionName)
    }

    func searchUsers(query: String) -> Single<[UserModel]> {
        firestoreService.fetchCollection(UserModel.self, collection: UserModel.collectionName) { ref in
            ref.whereField("displayName", isGreaterThanOrEqualTo: query)
               .whereField("displayName", isLessThan: query + "\u{f8ff}")
               .limit(to: 20)
        }
    }

    func follow(targetUid: String, currentUid: String) -> Single<Void> {
        let batch = db.batch()

        let currentRef = db.collection(UserModel.collectionName).document(currentUid)
        batch.updateData(["following": FieldValue.arrayUnion([targetUid])], forDocument: currentRef)

        let targetRef = db.collection(UserModel.collectionName).document(targetUid)
        batch.updateData(["followers": FieldValue.arrayUnion([currentUid])], forDocument: targetRef)

        return Single.create { single in
            batch.commit { error in
                if let error = error { single(.failure(error)) }
                else { single(.success(())) }
            }
            return Disposables.create()
        }
    }

    func unfollow(targetUid: String, currentUid: String) -> Single<Void> {
        let batch = db.batch()

        let currentRef = db.collection(UserModel.collectionName).document(currentUid)
        batch.updateData(["following": FieldValue.arrayRemove([targetUid])], forDocument: currentRef)

        let targetRef = db.collection(UserModel.collectionName).document(targetUid)
        batch.updateData(["followers": FieldValue.arrayRemove([currentUid])], forDocument: targetRef)

        return Single.create { single in
            batch.commit { error in
                if let error = error { single(.failure(error)) }
                else { single(.success(())) }
            }
            return Disposables.create()
        }
    }

    func fetchFollowers(uid: String) -> Single<[UserModel]> {
        fetchUser(uid: uid)
            .flatMap { [weak self] user -> Single<[UserModel]> in
                guard let self, let followers = user?.followers, !followers.isEmpty else {
                    return .just([])
                }
                let fetches = followers.map { self.fetchUser(uid: $0).map { $0.map { [$0] } ?? [] } }
                return Single.zip(fetches).map { $0.flatMap { $0 } }
            }
    }

    func fetchFollowing(uid: String) -> Single<[UserModel]> {
        fetchUser(uid: uid)
            .flatMap { [weak self] user -> Single<[UserModel]> in
                guard let self, let following = user?.following, !following.isEmpty else {
                    return .just([])
                }
                let fetches = following.map { self.fetchUser(uid: $0).map { $0.map { [$0] } ?? [] } }
                return Single.zip(fetches).map { $0.flatMap { $0 } }
            }
    }
}
