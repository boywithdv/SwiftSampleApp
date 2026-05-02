//
//  SearchViewModel.swift
//  SwiftSampleApp
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

final class SearchViewModel: BaseViewModel {

    // MARK: - Inputs

    let queryRelay = BehaviorRelay<String>(value: "")

    // MARK: - Outputs

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
        bindInputs()
    }

    // MARK: - Public

    func selectUser(uid: String) {
        steps.accept(AppStep.userProfile(uid))
    }

    // MARK: - Private

    private func bindInputs() {
        queryRelay
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .do(onNext: { [weak self] query in
                self?.isSearching.accept(!query.isEmpty)
                if query.isEmpty { self?.userResults.accept([]) }
            })
            .filter { !$0.isEmpty }
            .flatMapLatest { [weak self] query -> Observable<[UserModel]> in
                guard let self else { return .just([]) }
                return self.userRepository.searchUsers(query: query)
                    .asObservable()
                    .catchAndReturn([])
            }
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] _ in self?.isSearching.accept(false) })
            .bind(to: userResults)
            .disposed(by: disposeBag)
    }
}
