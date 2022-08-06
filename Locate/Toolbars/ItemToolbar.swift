import SwiftUI

struct ItemToolbar: CustomizableToolbarContent {

    @EnvironmentObject var model: Model

    var id: String

    var body: some CustomizableToolbarContent {

        ToolbarItem(id: "add") {
            Button {
                model.add()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .help("Add new item")
            .keyboardShortcut("n")
        }

    }

}
