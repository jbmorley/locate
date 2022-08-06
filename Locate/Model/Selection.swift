import SwiftUI

#warning("TODO: Can I do @MainActor annotation here and get all the benefits?")
#warning("TODO: Selection should watch store for disappearing items")
class Selection: ObservableObject {

    var model: Model

    @MainActor @Published var ids: Set<Place.ID> = []

    @MainActor var isEmpty: Bool {
        return ids.isEmpty
    }

    @MainActor var canEdit: Bool {
        return ids.count == 1
    }

    @MainActor var urls: [URL] {
        return model.urls(ids: ids)
    }

    @MainActor init(model: Model) {
        self.model = model
    }

    @MainActor func delete() {
        model.delete(ids: ids)
        ids = []
    }

    @MainActor func open() {
        model.open(ids: ids)
    }

    @MainActor func copy() {
        model.copy(ids: ids)
    }

    @MainActor func edit() {
        guard let id = ids.first else {
            return
        }
        model.edit(id: id)
    }

}
