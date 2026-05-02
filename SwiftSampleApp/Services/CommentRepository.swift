//
//  CommentRepository.swift
//  SwiftSampleApp
//

import Foundation
import FirebaseFirestore
import RxSwift

protocol CommentRepositoryProtocol {
    func fetchComments(postId: String) -> Observable<[Comment]>
    func addComment(_ comment: Comment) -> Single<Void>
    func deleteComment(commentId: String) -> Single<Void>
}

final class CommentRepository: CommentRepositoryProtocol {

    static let shared = CommentRepository()
    private let firestoreService = FirestoreService.shared
    private let db = Firestore.firestore()

    private init() {}

    func fetchComments(postId: String) -> Observable<[Comment]> {
        // Flutter app stores comments in sub-collection: post/{postId}/comment/
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let listener = self.db
                .collection(UserPost.collectionName)
                .document(postId)
                .collection(Comment.collectionName)
                .order(by: "timestamp", descending: false)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    let comments = snapshot?.documents.compactMap { doc -> Comment? in
                        try? doc.data(as: Comment.self)
                    } ?? []
                    observer.onNext(comments)
                }
            return Disposables.create { listener.remove() }
        }
    }

    func addComment(_ comment: Comment) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let commentId = self.db
                .collection(UserPost.collectionName)
                .document(comment.postId)
                .collection(Comment.collectionName)
                .document().documentID
            var c = comment
            c = Comment(
                commentId: commentId,
                postId: comment.postId,
                userId: comment.userId,
                username: comment.username,
                text: comment.text,
                timestamp: Date().timeIntervalSince1970
            )
            do {
                let data = try Firestore.Encoder().encode(c)
                self.db
                    .collection(UserPost.collectionName)
                    .document(comment.postId)
                    .collection(Comment.collectionName)
                    .document(commentId)
                    .setData(data) { error in
                        if let error = error { single(.failure(error)) }
                        else { single(.success(())) }
                    }
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func deleteComment(commentId: String) -> Single<Void> {
        // Requires postId to delete from sub-collection — simplified for now
        .just(())
    }
}
