//
//  PostRepository.swift
//  SwiftSampleApp
//

import Foundation
import FirebaseFirestore
import RxSwift

protocol PostRepositoryProtocol {
    func fetchTimeline() -> Observable<[UserPost]>
    func fetchPostsByUser(userId: String) -> Single<[UserPost]>
    func fetchPost(postId: String) -> Single<UserPost?>
    func createPost(userId: String, username: String, message: String) -> Single<Void>
    func deletePost(postId: String) -> Single<Void>
    func likePost(postId: String, userId: String) -> Single<Void>
    func unlikePost(postId: String, userId: String) -> Single<Void>
}

final class PostRepository: PostRepositoryProtocol {

    static let shared = PostRepository()
    private let firestoreService = FirestoreService.shared
    private let db = Firestore.firestore()

    private init() {}

    func fetchTimeline() -> Observable<[UserPost]> {
        firestoreService.listenToCollection(UserPost.self, collection: UserPost.collectionName) { ref in
            ref.order(by: "timestamp", descending: true).limit(to: 50)
        }
    }

    func fetchPostsByUser(userId: String) -> Single<[UserPost]> {
        firestoreService.fetchCollection(UserPost.self, collection: UserPost.collectionName) { ref in
            ref.whereField("userId", isEqualTo: userId)
               .order(by: "timestamp", descending: true)
        }
    }

    func fetchPost(postId: String) -> Single<UserPost?> {
        firestoreService.fetchDocument(UserPost.self, collection: UserPost.collectionName, documentId: postId)
    }

    func createPost(userId: String, username: String, message: String) -> Single<Void> {
        let postId = db.collection(UserPost.collectionName).document().documentID
        let post = UserPost(
            postId: postId,
            userId: userId,
            username: username,
            message: message,
            timestamp: Date().timeIntervalSince1970,
            likes: []
        )
        return firestoreService.setDocument(post, collection: UserPost.collectionName, documentId: postId)
    }

    func deletePost(postId: String) -> Single<Void> {
        firestoreService.deleteDocument(collection: UserPost.collectionName, documentId: postId)
    }

    func likePost(postId: String, userId: String) -> Single<Void> {
        firestoreService.updateDocument(
            ["likes": FieldValue.arrayUnion([userId])],
            collection: UserPost.collectionName,
            documentId: postId
        )
    }

    func unlikePost(postId: String, userId: String) -> Single<Void> {
        firestoreService.updateDocument(
            ["likes": FieldValue.arrayRemove([userId])],
            collection: UserPost.collectionName,
            documentId: postId
        )
    }
}
