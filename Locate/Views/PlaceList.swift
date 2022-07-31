import SwiftUI

struct TagList: View {

    var items: [String]

    var body: some View {
        HStack {
            ForEach(items) { item in
                Text(item)
                    .padding([.top, .bottom], 4)
                    .padding([.leading, .trailing], 8)
                    .background(Color.gray.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
    }

}

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
                        TagList(items: tags)
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
