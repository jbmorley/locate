import Combine
import CoreLocation
import MapKit
import SwiftUI

import SwiftSoup

class Model: NSObject, ObservableObject {

    var cancellables: Set<AnyCancellable> = []

    @Environment(\.openURL) private var openURL

    @MainActor @Published var places: [Place] = []
    @MainActor @Published var locations: [Location] = []  // TODO: Read only?
    @MainActor @Published var isUpdating: Bool = false
    @MainActor var centeredLocation: CLLocationCoordinate2D? = nil
    @MainActor @Published var images: [Place.ID:NSImage] = [:]

    // Derived.
    @MainActor @Published var tags: Set<String> = []
    @MainActor @Published var filteredPlaces: [Place] = []

    // Search.
    @MainActor @Published var filter: String = ""
    @MainActor @Published var filterTokens: [String] = []
    @MainActor @Published var suggestedTokens: [String] = []

    @MainActor var selectedPlace: Place? {
        guard selection.count == 1 else {
            return nil
        }
        return places.first { $0.id == selection.first }
    }

    @MainActor var selectedLocation: Location? {
        guard selection.count == 1 else {
            return nil
        }
        return locations.first { $0.id == selection.first }
    }

    private var userLocation: CLLocationCoordinate2D? = nil

    private var locationManager: CLLocationManager?

    var storeUrl: URL {
        let libraryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        return libraryUrl!.appending(path: "places.json")
    }

    // TODO: Introduce a second view model for the map selection
    // TODO: Better default location

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
        selection = []
        places.removeAll { ids.contains($0.id) }
    }

    @MainActor func update(place: Place) {
        guard let index = places.firstIndex(where: { $0.id == place.id }) else {
            places.append(place)
            selection = [place.id]
            return
        }
        places[index] = place
        selection = [place.id]
    }

    @MainActor func selectedUrls() -> [URL] {
        let urls = selection.compactMap { id in
            return places.first { $0.id == id }
        }.compactMap {
            return URL(string: $0.link)
        }
        return urls
    }

    @MainActor func copy(ids: Set<Place.ID>) {
        let urls = selectedUrls().map {
            return $0 as NSURL
        }
        print("copy: \(urls)")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects(urls)
        NSPasteboard.general.writeObjects(urls.compactMap({ $0.absoluteString as? NSString }))
    }

    @MainActor func center() {
        guard let userLocation = userLocation else {
            return
        }
        self.objectWillChange.send()
        self.centeredLocation = userLocation
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

    @Sendable func thumbnails() async {

        for await places in $places.values {
            for place in places {
                guard let url = place.url else {
                    continue
                }
                print(url)
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    // TODO: Check the response
                    guard let html = String(data: data, encoding: .utf8) else {
                        continue
                    }
                    let document = try SwiftSoup.parse(html)
                    let meta = try document.getElementsByTag("meta")
                    for tag in meta {
                        let property = try tag.attr("property")
                        if property == "og:image" {
                            let content = try tag.attr("content")
                            guard let url = URL(string: content) else {
                                continue
                            }
                            let (data, _) = try await URLSession.shared.data(from: url)
                            let image = NSImage(data: data)
                            DispatchQueue.main.async {
                                // TODO: This is ugly.
                                self.images[place.id] = image
                            }
                            break
                        }
                    }
                } catch {
                    print("Failed to download URL with error")
                    continue
                }
            }
        }

    }

    @Sendable func collectTags() async {
        for await places in $places.values {
            let tags = Set(places.map { $0.tags ?? [] }.flatMap { $0 })
            await MainActor.run {
                self.tags = tags
            }
        }
    }

    @MainActor func start() {

        // Update the suggested tokens whenever the filter or places change.
        $filter
            .combineLatest($tags)
            .compactMap { (filter, tags) in
                guard !filter.isEmpty else {
                    return []
                }
                return Array(tags.filter { $0.starts(with: filter) })
            }
            .receive(on: DispatchQueue.main)  // TODO: Express as MainActor?
            .sink { suggestedTokens in
                self.suggestedTokens = suggestedTokens
            }
            .store(in: &cancellables)


        // Update the filtered places whenever the filter, tokens, or places change.
        $filter
            .combineLatest($filterTokens)
            .combineLatest($places)
            .compactMap { (arg0, places) in
                let (filter, tokens) = arg0
                let tokenSet = Set(tokens)
                let places = places.filter { place in
                    guard !filter.isEmpty || !tokens.isEmpty else {
                        return true
                    }
                    let placeTags = Set(place.tags ?? [])
                    let matchesTags = !tokenSet.intersection(placeTags).isEmpty
                    let matchesFilter = !filter.isEmpty && place.address.localizedCaseInsensitiveContains(filter)
                    return matchesTags || matchesFilter
                }
                return places
            }
            .receive(on: DispatchQueue.main)  // TODO: Express as MainActor?
            .sink { places in
                self.filteredPlaces = places
            }
            .store(in: &cancellables)
    }

//    @Sendable func run() async {
//        _ = await [geocode(), selection()]
//    }

}

extension Model: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            manager.startUpdatingLocation()
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

}
