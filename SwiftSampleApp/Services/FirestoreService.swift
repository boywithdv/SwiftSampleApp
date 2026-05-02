//
//  FirestoreService.swift
//  SwiftSampleApp
//

import Foundation
import FirebaseFirestore
import RxSwift

final class FirestoreService {

    static let shared = FirestoreService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Write

    func setDocument<T: Encodable>(_ value: T, collection: String, documentId: String) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            do {
                let data = try Firestore.Encoder().encode(value)
                self.db.collection(collection).document(documentId).setData(data) { error in
                    if let error = error { single(.failure(error)) }
                    else { single(.success(())) }
                }
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func addDocument<T: Encodable>(_ value: T, collection: String) -> Single<String> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            do {
                let data = try Firestore.Encoder().encode(value)
                var ref: DocumentReference?
                ref = self.db.collection(collection).addDocument(data: data) { error in
                    if let error = error { single(.failure(error)) }
                    else { single(.success(ref?.documentID ?? "")) }
                }
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }

    func updateDocument(_ fields: [String: Any], collection: String, documentId: String) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.db.collection(collection).document(documentId).updateData(fields) { error in
                if let error = error { single(.failure(error)) }
                else { single(.success(())) }
            }
            return Disposables.create()
        }
    }

    func deleteDocument(collection: String, documentId: String) -> Single<Void> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.db.collection(collection).document(documentId).delete { error in
                if let error = error { single(.failure(error)) }
                else { single(.success(())) }
            }
            return Disposables.create()
        }
    }

    // MARK: - Read (One-shot)

    func fetchDocument<T: Decodable>(_ type: T.Type, collection: String, documentId: String) -> Single<T?> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            self.db.collection(collection).document(documentId).getDocument { snapshot, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                guard let snapshot, snapshot.exists else {
                    single(.success(nil))
                    return
                }
                do {
                    let value = try snapshot.data(as: T.self)
                    single(.success(value))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }

    func fetchCollection<T: Decodable>(_ type: T.Type, collection: String, query: ((CollectionReference) -> Query)? = nil) -> Single<[T]> {
        Single.create { [weak self] single in
            guard let self else { return Disposables.create() }
            let ref: Query = query?(self.db.collection(collection)) ?? self.db.collection(collection)
            ref.getDocuments { snapshot, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                let items = snapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                single(.success(items))
            }
            return Disposables.create()
        }
    }

    // MARK: - Real-time Listeners

    func listenToDocument<T: Decodable>(_ type: T.Type, collection: String, documentId: String) -> Observable<T?> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let listener = self.db.collection(collection).document(documentId)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        observer.onError(error)
                        return
                    }
                    let value = try? snapshot?.data(as: T.self)
                    observer.onNext(value)
                }
            return Disposables.create { listener.remove() }
        }
    }

    func listenToCollection<T: Decodable>(_ type: T.Type, collection: String, query: ((CollectionReference) -> Query)? = nil) -> Observable<[T]> {
        Observable.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            let ref: Query = query?(self.db.collection(collection)) ?? self.db.collection(collection)
            let listener = ref.addSnapshotListener { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                let items = snapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                observer.onNext(items)
            }
            return Disposables.create { listener.remove() }
        }
    }
}
