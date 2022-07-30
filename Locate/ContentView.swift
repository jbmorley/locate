import SwiftUI

// TODO: Show progress when geocoding
// TODO: Can NewPlaceFormModel pluck the model out of the environment?
// TODO: Model in environment

struct ContentView: View {

    enum Sheet: Identifiable {
        var id: Self { self }
        case newPlace
    }

    @StateObject var model = Model()
    @State var sheet: Sheet? = nil

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                PlaceList(model: model)
                    .frame(width: geometry.size.width * 0.3)
                MapView(model: model)
            }
            .toolbar {

                if model.isUpdating {
                    ToolbarItem(placement: .navigation) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .controlSize(.small)
                    }
                }

                // TODO: Separate these actions out into groups.
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
                }
                ToolbarItem {
                    Button {
                        model.center()
                    } label: {
                        Image(systemName: "location")
                    }
                }
                ToolbarItem {
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
