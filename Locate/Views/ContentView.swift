// Copyright (c) 2022-2023 Jason Morley
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

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var model: Model
    @EnvironmentObject var selection: Selection

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                PlaceList(model: model)
                    .safeAreaInset(edge: .bottom) {
                        if model.isUpdating {
                            Text("Updating Locations...")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.regularMaterial)
                        }
                    }
                    .frame(width: geometry.size.width * 0.3)
                HStack(spacing: 0) {
                    MapView(model: model)
                    if let url = model.selectedPlace?.url {
                        WebView(url: url)
                    }
                }
            }
            .toolbar(id: "main") {
                SelectionToolbar(id: "selection")
                ItemToolbar(id: "items")
                MapToolbar(id: "map")
            }
            .sheet(item: $model.sheet) { sheet in
                switch sheet {
                case .newPlace:
                    PlaceForm(model: model)
                case .editPlace(let place):
                    PlaceForm(model: model, place: place)
                }
            }
        }
        .task(model.run)
        .onAppear {
            model.start()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
