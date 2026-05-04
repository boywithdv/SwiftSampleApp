//
//  MapViewModel.swift
//  SwiftSampleApp
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import RxFlow

final class MapViewModel: BaseViewModel, ObservableObject {

    // MARK: - @Published

    @Published var displayNearbyUsers: [UserModel] = []

    // MARK: - RxSwift Relays

    let nearbyUsers     = BehaviorRelay<[UserModel]>(value: [])
    let currentLocation = BehaviorRelay<CLLocation?>(value: nil)
    let errorMessage    = PublishRelay<String>()

    // MARK: - Private

    private let userRepository: UserRepositoryProtocol
    private let authService: AuthServiceProtocol
    private let locationService: LocationServiceProtocol
    private let disposeBag = DisposeBag()

    init(userRepository: UserRepositoryProtocol = UserRepository.shared,
         authService: AuthServiceProtocol = AuthService.shared,
         locationService: LocationServiceProtocol = LocationService.shared) {
        self.userRepository  = userRepository
        self.authService     = authService
        self.locationService = locationService
        super.init()
        bindRelaysToPublished()
        startLocationUpdates()
    }

    // MARK: - Public

    func selectUser(uid: String) { steps.accept(AppStep.userProfile(uid)) }

    func fetchNearbyUsers(from location: CLLocation) {
        userRepository.fetchAllUsers()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] users in
                guard let self, let currentUid = self.authService.currentUserId else { return }
                let filtered = users
                    .filter { $0.uid != currentUid }
                    .filter { user -> Bool in
                        guard let lat = user.latitude, let lon = user.longitude else { return false }
                        let userLocation = CLLocation(latitude: lat, longitude: lon)
                        return location.distance(from: userLocation) < 10_000 // 10km radius
                    }
                self.nearbyUsers.accept(filtered)
            }, onFailure: { [weak self] error in
                self?.errorMessage.accept(error.localizedDescription)
            })
            .disposed(by: disposeBag)
    }

    func tapUser(uid: String) {
        steps.accept(AppStep.userProfile(uid))
    }

    // MARK: - Private

    private func bindRelaysToPublished() {
        nearbyUsers
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in self?.displayNearbyUsers = $0 })
            .disposed(by: disposeBag)
    }

    private func startLocationUpdates() {
        locationService.requestPermission()

        locationService.currentLocation
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                guard let self else { return }
                self.currentLocation.accept(location)
                self.fetchNearbyUsers(from: location)
                self.updateOwnLocation(location)
            })
            .disposed(by: disposeBag)
    }

    private func updateOwnLocation(_ location: CLLocation) {
        guard let uid = authService.currentUserId else { return }
        userRepository.updateLocation(
            uid: uid,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        .subscribe()
        .disposed(by: disposeBag)
    }
}
