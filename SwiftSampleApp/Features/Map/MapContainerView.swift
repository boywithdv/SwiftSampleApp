//
//  MapContainerView.swift
//  SwiftSampleApp
//

import SwiftUI
import MapKit

struct MapContainerView: View {
    @StateObject var viewModel: MapViewModel

    var body: some View {
        MapViewRepresentable(viewModel: viewModel)
            .ignoresSafeArea(edges: .top)
            .background(Color.appBackground)
    }
}

// MARK: - UIViewRepresentable

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var viewModel: MapViewModel

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.userTrackingMode = .follow
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        let existing = Set(mapView.annotations.compactMap { $0 as? UserAnnotation }.map { $0.user.uid })
        let updated  = Set(viewModel.displayNearbyUsers.map(\.uid))

        // Remove stale annotations
        let toRemove = mapView.annotations.compactMap { $0 as? UserAnnotation }
            .filter { !updated.contains($0.user.uid) }
        mapView.removeAnnotations(toRemove)

        // Add new annotations
        for user in viewModel.displayNearbyUsers where !existing.contains(user.uid) {
            guard let lat = user.latitude, let lon = user.longitude else { continue }
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            let annotation = UserAnnotation(user: user, coordinate: coord)
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(viewModel: viewModel) }

    final class Coordinator: NSObject, MKMapViewDelegate {
        let viewModel: MapViewModel

        init(viewModel: MapViewModel) { self.viewModel = viewModel }

        func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
            guard let userAnnotation = annotation as? UserAnnotation else { return }
            viewModel.selectUser(uid: userAnnotation.user.uid)
            mapView.deselectAnnotation(annotation, animated: true)
        }

        func mapView(_ mapView: MKMapView,
                     viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is UserAnnotation else { return nil }
            let id = "UserPin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id)
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            if let marker = view as? MKMarkerAnnotationView {
                marker.glyphImage = UIImage(systemName: "person.fill")
                marker.markerTintColor = AppTheme.Color.primary
                marker.canShowCallout = true
            }
            view.annotation = annotation
            return view
        }
    }
}
