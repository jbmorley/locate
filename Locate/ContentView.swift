import SwiftUI

// TODO: Show progress when geocoding
// TODO: Can NewPlaceFormModel pluck the model out of the environment?
// TODO: Model in environment

struct ContentView: View {

    enum Sheet: Identifiable {
        var id: Self { self }
        case newPlace
    }

    @ObservedObject var model: Model
    @State var sheet: Sheet? = nil

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    PlaceList(model: model)
                        .frame(width: geometry.size.width * 0.2)
                    if model.isUpdating {
                        Text("Updating Locations...")
                        .padding()
                    }
                }
                HStack {
                    MapView(model: model)
                    if let url = model.selectedPlace?.url {
                        WebView(url: url)
                    }
                }
            }
            .toolbar {

                ToolbarItemGroup {

                    Button {
                        model.open(ids: model.selection)
                    } label: {
                        Image(systemName: "safari")
                    }
                    .help("Open in Safari")
                    .keyboardShortcut(.return, modifiers: [])
                    .disabled(model.selection.isEmpty)

                    Button {
                        model.delete(ids: model.selection)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .help("Delete")
                    .keyboardShortcut(.delete)
                    .disabled(model.selection.isEmpty)

                    ShareLink(items: model.selectedUrls()) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .disabled(model.selection.isEmpty)

                }

                ToolbarItemGroup {

                    Button {
                        model.center()
                    } label: {
                        Image(systemName: "location")
                    }

                }

                ToolbarItemGroup {
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
                    NewPlaceForm(model: model)
                }
            }
        }
        .task(model.geocode)
        .task(model.save)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: Model())
    }
}
