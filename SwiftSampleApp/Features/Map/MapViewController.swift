//
//  MapViewController.swift
//  SwiftSampleApp
//

import UIKit
import MapKit
import RxSwift
import RxCocoa

final class MapViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MapViewModel
    private let disposeBag = DisposeBag()

    // MARK: - UI Components

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        return map
    }()

    // MARK: - Init

    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = AppTheme.Color.background
        title = "マップ"

        mapView.delegate = self
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.currentLocation
            .compactMap { $0 }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] location in
                let region = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 5000,
                    longitudinalMeters: 5000
                )
                self?.mapView.setRegion(region, animated: true)
            })
            .disposed(by: disposeBag)

        viewModel.nearbyUsers
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] users in
                guard let self else { return }
                let existing = self.mapView.annotations.filter { !($0 is MKUserLocation) }
                self.mapView.removeAnnotations(existing)

                let annotations = users.compactMap { user -> UserAnnotation? in
                    guard let lat = user.latitude, let lon = user.longitude else { return nil }
                    return UserAnnotation(user: user, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                }
                self.mapView.addAnnotations(annotations)
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let userAnnotation = annotation as? UserAnnotation else { return nil }

        let view = MKMarkerAnnotationView(annotation: userAnnotation, reuseIdentifier: "user")
        view.markerTintColor = AppTheme.Color.primary
        view.glyphImage = UIImage(systemName: "person.fill")
        view.canShowCallout = true

        let button = UIButton(type: .detailDisclosure)
        button.tintColor = AppTheme.Color.primary
        view.rightCalloutAccessoryView = button

        return view
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? UserAnnotation else { return }
        viewModel.tapUser(uid: annotation.user.uid)
    }
}
