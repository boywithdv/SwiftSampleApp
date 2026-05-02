//
//  UserAnnotation.swift
//  SwiftSampleApp
//

import MapKit

final class UserAnnotation: NSObject, MKAnnotation {
    let user: UserModel
    var coordinate: CLLocationCoordinate2D
    var title: String? { user.displayName }
    var subtitle: String? { nil }

    init(user: UserModel, coordinate: CLLocationCoordinate2D) {
        self.user = user
        self.coordinate = coordinate
    }
}
