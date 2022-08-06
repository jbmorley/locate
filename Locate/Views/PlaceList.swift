import SwiftUI

struct PlaceList: View {

    @ObservedObject var model: Model

    var body: some View {
        List(selection: $model.selection.ids) {
            ForEach(model.filteredPlaces) { place in
                HStack {
                    if let image = model.images[place.id] {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 6.0))
                    }
                    VStack(alignment: .leading) {
                        Text(place.address)
                        if let tags = place.tags, !tags.isEmpty {
                            TagList(items: Set(tags))
                        }
                    }
                    .lineLimit(1)
                }
            }
        }
        .contextAction(forSelectionType: Place.ID.self) { selection in
            model.open(ids: selection)
        }
        .contextMenu(forSelectionType: Place.ID.self) { selection in
            Button("Open") {
                model.open(ids: selection)
            }
            Divider()
            if selection.count == 1, let id = selection.first {
                Button("Edit") {
                    model.edit(id: id)
                }
                Divider()
            }
            Button("Copy") {
                model.copy(ids: selection)
            }
            Divider()
            Button("Delete", role: .destructive) {
                model.delete(ids: selection)
            }
        }
        .searchable(text: $model.filter,
                    tokens: $model.filterTokens,
                    suggestedTokens: $model.suggestedTokens) { token in
            Text(token)
        }
    }

}
