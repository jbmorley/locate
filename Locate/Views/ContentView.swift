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
