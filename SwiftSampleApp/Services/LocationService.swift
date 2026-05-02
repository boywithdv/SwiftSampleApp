//
//  LocationService.swift
//  SwiftSampleApp
//

import Foundation
import CoreLocation
import RxSwift

protocol LocationServiceProtocol {
    var currentLocation: Observable<CLLocation> { get }
    func requestPermission()
}

final class LocationService: NSObject, LocationServiceProtocol {

    static let shared = LocationService()

    private let locationManager = CLLocationManager()
    private let locationSubject = PublishSubject<CLLocation>()

    var currentLocation: Observable<CLLocation> {
        locationSubject.asObservable()
    }

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        locationSubject.onNext(location)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            break
        }
    }
}
