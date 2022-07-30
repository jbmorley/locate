import Foundation
import MapKit

struct Location: Identifiable {

    let id: UUID
    let place: Place
    let coordinate: CLLocationCoordinate2D

}
