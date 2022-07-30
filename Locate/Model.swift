import CoreLocation
import MapKit
import SwiftUI

class Model: NSObject, ObservableObject {

    @Environment(\.openURL) private var openURL

    @MainActor @Published var places: [Place] = []
    @MainActor @Published var locations: [Location] = []  // TODO: Read only?
    @MainActor @Published var isUpdating: Bool = false
    private var userLocation: CLLocationCoordinate2D? = nil

    private var locationManager: CLLocationManager?

    var storeUrl: URL {
        let libraryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        return libraryUrl!.appending(path: "places.json")
    }

    // TODO: Introduce a second view model for the map selection
    // TODO: Better default location
    @MainActor var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334_900,
                                                                              longitude: -122.009_020),
                                               latitudinalMeters: 10000,
                                               longitudinalMeters: 10000)

    @MainActor @Published var selection: Set<Place.ID> = []

    private let geocoder = CLGeocoder()

    @MainActor override init() {
        super.init()
        do {
            let data = try Data(contentsOf: storeUrl)
            let places = try JSONDecoder().decode([Place].self, from: data)
            self.places = places
        } catch {
            print("Failed to load places with error \(error).")
        }

        self.requestAuthorization()
    }

    @MainActor private func requestAuthorization() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
    }

    @MainActor func open(ids: Set<Place.ID>) {
        for id in ids {
            guard let place = places.first(where: { $0.id == id }) else {
                return
            }
            guard let url = URL(string: place.link) else {
                return
            }
            openURL(url)
        }
    }

    @MainActor func delete(ids: Set<Place.ID>) {
        places.removeAll { ids.contains($0.id) }
    }

    @MainActor func add(place: Place) {
        places.append(place)
        selection = [place.id]
    }

    @MainActor func center() {
        guard let userLocation = userLocation else {
            return
        }
        self.objectWillChange.send()
        region.center = userLocation
    }

    @Sendable func save() async {
        for await places in $places.values {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(places)
                try data.write(to: storeUrl, options: .atomic)
            } catch {
                // TODO: Model error in meaningful way
                print("Failed to save with error \(error).")
            }
        }
    }

    @Sendable func geocode() async {
        for await places in $places.values {
            await MainActor.run {
                isUpdating = true
            }
            let locationPlaces = await locations.map { $0.place }
            for operation in places.difference(from: locationPlaces) {
                switch operation {
                case .insert(offset: _, element: let place, associatedWith: _):
                    do {
                        print("Geocoding '\(place.address)'...")
                        guard let location = try await geocoder.geocodeAddressString(place.address).first?.location else {
                            continue
                        }
                        await MainActor.run {
                            locations.append(Location(id: place.id, place: place, coordinate: location.coordinate))
                        }
                    } catch {
                        print("Unable to geocode address")
                    }
                case .remove(offset: _, element: let place, associatedWith: _):
                    await MainActor.run {
                        locations.removeAll { $0.id == place.id }
                    }
                }
            }
            await MainActor.run {
                isUpdating = false
            }
        }
    }

    //    @Sendable func run() async {
    //        _ = await [geocode(), selection()]
    //    }

}

extension Model: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("location status -> \(status)")
        if status == .authorizedAlways {
//            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
//                if CLLocationManager.isRangingAvailable() {
//                    // do stuff
//                }
//            }
            manager.startUpdatingLocation()
            print("AUTHORIZED")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }
    }

//    deinit {
//        locationManager?.stopUpdatingLocation()
//    }

}
