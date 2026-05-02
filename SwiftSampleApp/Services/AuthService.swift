//
//  AuthService.swift
//  SwiftSampleApp
//

import Foundation
import FirebaseAuth
import RxSwift

protocol AuthServiceProtocol {
    var currentUser: Observable<User?> { get }
    var isLoggedIn: Bool { get }
    var currentUserId: String? { get }
    func signIn(email: String, password: String) -> Single<User>
    func register(email: String, password: String) -> Single<User>
    func signOut() throws
}

final class AuthService: AuthServiceProtocol {

    static let shared = AuthService()

    private let currentUserSubject: BehaviorSubject<User?>

    var currentUser: Observable<User?> {
        currentUserSubject.asObservable()
    }

    var isLoggedIn: Bool {
        Auth.auth().currentUser != nil
    }

    var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    private var stateHandle: AuthStateDidChangeListenerHandle?

    private init() {
        currentUserSubject = BehaviorSubject(value: Auth.auth().currentUser)
        stateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUserSubject.onNext(user)
        }
    }

    deinit {
        if let handle = stateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) -> Single<User> {
        Single.create { single in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    single(.failure(error))
                } else if let user = result?.user {
                    single(.success(user))
                }
            }
            return Disposables.create()
        }
    }

    func register(email: String, password: String) -> Single<User> {
        Single.create { single in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    single(.failure(error))
                } else if let user = result?.user {
                    single(.success(user))
                }
            }
            return Disposables.create()
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
