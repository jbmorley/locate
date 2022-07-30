import MapKit
import SwiftUI

struct MapView: View {

    struct LayoutMetrics {
        static let markerSize = 32.0
        static let selectionLineWidth = 4.0
    }

    @ObservedObject var model: Model

    var body: some View {
        Map(coordinateRegion: $model.region, showsUserLocation: true, annotationItems: model.locations) { location in
            MapAnnotation(coordinate: location.coordinate) {
                Image(systemName: "mappin.circle.fill")
                    .resizable()
                    .foregroundColor(.orange)
                    .frame(width: LayoutMetrics.markerSize, height: LayoutMetrics.markerSize)
                    .background(Color.white)
                    .clipShape(Circle())
                    .overlay(Circle()
                        .stroke(Color.accentColor,
                                lineWidth: model.selection.contains(location.id) ? LayoutMetrics.selectionLineWidth : 0))
                    .onTapGesture(count: 2) {
                        model.open(ids: [location.id])
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        model.selection = [location.id]
                    })
            }
        }
    }
}
