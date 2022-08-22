// Copyright (c) 2022 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Combine
import CoreLocation
import MapKit
import SwiftUI

import SwiftSoup

#warning("TODO: Separate model and store")
class Model: NSObject, ObservableObject {

    enum Sheet: Identifiable {

        var id: String {
            switch self {
            case .newPlace:
                return "new-place"
            case .editPlace(let place):
                return "edit-place-\(place.id)"
            }
        }

        case newPlace
        case editPlace(Place)
    }

    @Environment(\.openURL) private var openURL

    @MainActor @Published var places: [Place] = []
    @MainActor @Published var locations: [Location] = []
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

    // UI.
    @MainActor @Published var sheet: Sheet? = nil
#warning("TODO: Remove selection from model")
    @MainActor var selection: Selection!

#warning("TODO: Push selectedPlace into selection")
    @MainActor var selectedPlace: Place? {
        guard selection.ids.count == 1 else {
            return nil
        }
        return places.first { $0.id == selection.ids.first }
    }

#warning("TODO: Push selectedLocation into selection")
    @MainActor var selectedLocation: Location? {
        guard selection.ids.count == 1 else {
            return nil
        }
        return locations.first { $0.id == selection.ids.first }
    }

    private var userLocation: CLLocationCoordinate2D? = nil
    private var locationManager: CLLocationManager?
    private var cancellables: Set<AnyCancellable> = []

    private var storeUrl: URL {
        let libraryUrl = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first
        return libraryUrl!.appending(path: "places.json")
    }

#warning("TODO: Introduce a second view model for the map selection")
#warning("TODO: Better default location")

    private let geocoder = CLGeocoder()

    @MainActor override init() {
        super.init()
        selection = Selection(model: self)
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
        for url in urls(ids: ids) {
            openURL(url)
        }
    }

    @MainActor func add() {
        sheet = .newPlace
    }

    @MainActor func delete(ids: Set<Place.ID>) {
        selection.ids = []
        places.removeAll { ids.contains($0.id) }
    }

    @MainActor func edit(id: Place.ID) {
        guard let place = places.first(where: { $0.id == id }) else {
            return
        }
        sheet = .editPlace(place)
    }

    @MainActor func update(place: Place) {
        guard let index = places.firstIndex(where: { $0.id == place.id }) else {
            places.append(place)
            selection.ids = [place.id]
            return
        }
        places[index] = place
        selection.ids = [place.id]
    }

    @MainActor func places(ids: Set<Place.ID>) -> [Place] {
        return ids.compactMap { id in
            return places.first { $0.id == id }
        }
    }

    @MainActor func urls(ids: Set<Place.ID>) -> [URL] {
        return places(ids: ids).compactMap {
            return URL(string: $0.link)
        }
    }

    @MainActor func copy(ids: Set<Place.ID>) {
        let urls = urls(ids: ids).map {
            return $0 as NSURL
        }
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

    private func save() async {
        for await places in $places.values {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(places)
                try data.write(to: storeUrl, options: .atomic)
            } catch {
#warning("TODO: Model error in meaningful way")
                print("Failed to save with error \(error).")
            }
        }
    }

    private func geocodePlaces() async {
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

    private func fetchThumbnails() async {
        for await places in $places.values {
            for place in places {
                guard let url = place.url else {
                    continue
                }
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
#warning("TODO: Check HTTP response")
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

    private func collectTags() async {
        for await places in $places.values {
            let tags = Set(places.map { $0.tags ?? [] }.flatMap { $0 })
            await MainActor.run {
                self.tags = tags
            }
        }
    }

    @MainActor func start() {

#warning("TODO: Is it possible to express DisaptchQueue.main as MainActor?")

        // Update the suggested tokens whenever the filter or places change.
        $filter
            .combineLatest($tags)
            .compactMap { (filter, tags) in
                guard !filter.isEmpty else {
                    return []
                }
                return Array(tags.filter { $0.starts(with: filter) })
            }
            .receive(on: DispatchQueue.main)
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
                return places
                    .filter { $0.matches(filter: filter, tags: Set(tokens)) }
                    .sorted { $0.address.localizedCompare($1.address) == .orderedAscending }
            }
            .receive(on: DispatchQueue.main)
            .sink { places in
                self.filteredPlaces = places
            }
            .store(in: &cancellables)

    }

    @Sendable func run() async {
        async let geocodePlaces: () = await geocodePlaces()
        async let save: () = await save()
        async let fetchThumbnails: () = await fetchThumbnails()
        async let collectTags: () = await collectTags()
        _ = await [geocodePlaces, save, fetchThumbnails, collectTags]
    }

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
