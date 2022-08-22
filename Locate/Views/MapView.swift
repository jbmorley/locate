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
