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
                    if !place.link  .isEmpty {
                        Text(place.link)
                            .foregroundColor(.secondary)
                    }
                }
                .lineLimit(1)
            }
        }
        .contextMenu(forSelectionType: Place.ID.self) { selection in
            Button("View") {
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
