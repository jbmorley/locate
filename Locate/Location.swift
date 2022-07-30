import Foundation
import MapKit

struct Location: Identifiable, Equatable {

    static func == (lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }

    let id: UUID
    let place: Place
    let coordinate: CLLocationCoordinate2D

}
