//
//  SearchViewModel.swift
//  SwiftSampleApp
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxFlow

final class SearchViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published

    @Published var displayUsers: [UserModel] = []
    @Published var displayIsSearching: Bool = false
    @Published var query: String = "" {
        didSet { queryRelay.accept(query) }
    }

    // MARK: - RxSwift Relays

    let queryRelay   = BehaviorRelay<String>(value: "")
    let userResults  = BehaviorRelay<[UserModel]>(value: [])
    let isSearching  = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()

    let trendingHashtags: [String] = [
        "#locasocial", "#位置情報", "#近くの人", "#友達募集", "#散歩",
        "#カフェ", "#Tokyo", "#Osaka", "#旅行", "#グルメ"
    ]

    // MARK: - Private

    private let userRepository: UserRepositoryProtocol
    private let disposeBag = DisposeBag()

    init(userRepository: UserRepositoryProtocol = UserRepository.shared) {
        self.userRepository = userRepository
        super.init()
        bindRelaysToPublished()
        bindInputs()
    }

    // MARK: - Public

    func selectUser(uid: String) { steps.accept(AppStep.userProfile(uid)) }

    // MARK: - Private

    private func bindRelaysToPublished() {
        userResults
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayUsers = $0 })
            .disposed(by: disposeBag)

        isSearching
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayIsSearching = $0 })
            .disposed(by: disposeBag)
    }

    private func bindInputs() {
        queryRelay
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [weak self] q in
                self?.isSearching.accept(!q.isEmpty)
                if q.isEmpty { self?.userResults.accept([]) }
            })
            .filter { !$0.isEmpty }
            .flatMapLatest { [weak self] q -> Observable<[UserModel]> in
                guard let self else { return .just([]) }
                return self.userRepository.searchUsers(query: q)
                    .asObservable().catchAndReturn([])
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.isSearching.accept(false) })
            .bind(to: userResults)
            .disposed(by: disposeBag)
    }
}
