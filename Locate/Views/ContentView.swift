import SwiftUI

// TODO: Show progress when geocoding
// TODO: Can NewPlaceFormModel pluck the model out of the environment?
// TODO: Model in environment

struct ContentView: View {

    @ObservedObject var model: Model

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    PlaceList(model: model)
                        .frame(width: geometry.size.width * 0.3)
                    if model.isUpdating {
                        Text("Updating Locations...")
                        .padding()
                    }
                }
                HStack(spacing: 0) {
                    MapView(model: model)
                    if let url = model.selectedPlace?.url {
                        WebView(url: url)
                    }
                }
            }
            .toolbar(id: "main") {
                SelectionToolbar(id: "selection", model: model)
                ItemToolbar(id: "items", model: model)
                MapToolbar(id: "map", model: model)
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
        .task(model.geocode)
        .task(model.save)
        .task(model.thumbnails)
        .task(model.collectTags)
        .onAppear {
            model.start()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model())
    }
}
