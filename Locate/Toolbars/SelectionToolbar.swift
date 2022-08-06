import SwiftUI

struct SelectionToolbar: CustomizableToolbarContent {

    var id: String
    @ObservedObject var model: Model

    var body: some CustomizableToolbarContent {

        ToolbarItem(id: "open") {
            Button {
                model.open(ids: model.selection)
            } label: {
                Label("Open", systemImage: "safari")
            }
            .help("Open selected items in default web browser")
            .keyboardShortcut(.return, modifiers: [])
            .disabled(model.selection.isEmpty)
        }

        ToolbarItem(id: "edit") {
            Button {
                guard let selectedPlace = model.selectedPlace else {
                    return
                }
                model.sheet = .editPlace(selectedPlace)
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .help("Edit selected items")
            .keyboardShortcut(.return)
            .disabled(model.selection.count != 1)
        }

        ToolbarItem(id: "delete") {
            Button {
                model.delete(ids: model.selection)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .help("Delete selected items")
            .keyboardShortcut(.delete)
            .disabled(model.selection.isEmpty)
        }

        ToolbarItem(id: "share") {
            ShareLink(items: model.selectedUrls()) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .help("Share selected items")
            .disabled(model.selection.isEmpty)
        }

    }

}
