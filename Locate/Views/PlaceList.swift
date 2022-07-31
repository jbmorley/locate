import SwiftUI

struct PlaceList: View {

    @ObservedObject var model: Model

    // TODO: Push this into the model
    var places: [Place] {
        return model.places.sorted { $0.address.localizedCompare($1.address) == .orderedAscending }
    }

    var body: some View {
        List(selection: $model.selection) {
            ForEach(places) { place in
                VStack(alignment: .leading) {
                    Text(place.address)
                    if let tags = place.tags, !tags.isEmpty {
                        TagList(items: tags, color: .purple)
                    }
                }
                .lineLimit(1)
            }
        }
        .contextMenu(forSelectionType: Place.ID.self) { selection in
            Button("Open") {
                model.open(ids: selection)
            }
            Divider()
            Button("Copy") {
                model.copy(ids: selection)
            }
            Divider()
            Button("Delete", role: .destructive) {
                model.delete(ids: selection)
            }
        }
    }

}
