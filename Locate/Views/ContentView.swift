import SwiftUI

// TODO: Show progress when geocoding
// TODO: Can NewPlaceFormModel pluck the model out of the environment?
// TODO: Model in environment

struct ContentView: View {

    // TODO: Push this down into the model?
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

    @ObservedObject var model: Model
    @State var sheet: Sheet? = nil

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

                ToolbarItem(id: "open") {
                    Button {
                        model.open(ids: model.selection)
                    } label: {
                        Image(systemName: "safari")
                    }
                    .help("Open in Safari")
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(model.selection.isEmpty)
                }

                ToolbarItem(id: "edit") {
                    Button {
                        guard let selectedPlace = model.selectedPlace else {
                            return
                        }
                        sheet = .editPlace(selectedPlace)
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .help("Edit")
                    .keyboardShortcut(.return)
                    .disabled(model.selection.count != 1)
                }

                ToolbarItem(id: "delete") {
                    Button {
                        model.delete(ids: model.selection)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .help("Delete")
                    .keyboardShortcut(.delete)
                    .disabled(model.selection.isEmpty)
                }

                ToolbarItem(id: "share") {
                    ShareLink(items: model.selectedUrls()) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(model.selection.isEmpty)
                }

                ToolbarItem(id: "center") {
                    Button {
                        model.center()
                    } label: {
                        Image(systemName: "location")
                    }
                }

                ToolbarItem(id: "add") {
                    Button {
                        sheet = .newPlace
                    } label: {
                        Image(systemName: "plus")
                    }
                    .keyboardShortcut("n")
                }

            }
            .sheet(item: $sheet) { sheet in
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
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model())
    }
}
