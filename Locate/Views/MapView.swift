import MapKit
import SwiftUI

struct MapView: View {

    struct LayoutMetrics {
        static let markerSize = 32.0
        static let selectionLineWidth = 4.0
    }

    @ObservedObject var model: Model

    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.334_900,
                                                                          longitude: -122.009_020),
                                           latitudinalMeters: 10000,
                                           longitudinalMeters: 10000)

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: model.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .foregroundColor(.orange)
                    .frame(width: LayoutMetrics.markerSize, height: LayoutMetrics.markerSize)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle()
                        .stroke(Color.accentColor,
                                lineWidth: model.selection.ids.contains(location.id) ? LayoutMetrics.selectionLineWidth : 0))
                    .onTapGesture(count: 2) {
                        model.open(ids: [location.id])
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        model.selection.ids = [location.id]
                    })
            }
        }
        .onChange(of: model.selectedLocation) { selectedLocation in
            guard let selectedLocation = selectedLocation else {
                return
            }
            withAnimation {
                region.center = selectedLocation.coordinate
            }
        }
        .onChange(of: model.centeredLocation) { centeredLocation in
            guard let centeredLocation = centeredLocation else {
                return
            }
            withAnimation {
                region.center = centeredLocation
            }
        }
    }
}
