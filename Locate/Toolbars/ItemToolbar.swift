import SwiftUI

struct ItemToolbar: CustomizableToolbarContent {

    var id: String
    @ObservedObject var model: Model

    var body: some CustomizableToolbarContent {

        ToolbarItem(id: "add") {
            Button {
                model.sheet = .newPlace
            } label: {
                Label("Add", systemImage: "plus")
            }
            .help("Add new item")
            .keyboardShortcut("n")
        }

    }

}