import SwiftUI

struct ContentView: View {

    @EnvironmentObject var model: Model
    @EnvironmentObject var selection: Selection

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
                HSplitView {
                    MapView(model: model)
                        .frame(minWidth: 100)
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
