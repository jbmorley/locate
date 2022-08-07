import SwiftUI

struct SelectionToolbar: CustomizableToolbarContent {

    @EnvironmentObject var selection: Selection

    var id: String

    var body: some CustomizableToolbarContent {

        ToolbarItem(id: "open") {
            Button {
                selection.open()
            } label: {
                Label("Open", systemImage: "safari")
            }
            .help("Open selected items in default web browser")
            .keyboardShortcut(.return, modifiers: [])
            .disabled(selection.isEmpty)
        }

        ToolbarItem(id: "edit") {
            Button {
                selection.edit()
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .help("Edit selected items")
            .keyboardShortcut(.return)
            .disabled(!selection.canEdit)
        }

        ToolbarItem(id: "delete") {
            Button {
                selection.delete()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .help("Delete selected items")
            .disabled(selection.isEmpty)
        }

        ToolbarItem(id: "share") {
            ShareLink(items: selection.urls) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            .help("Share selected items")
            .disabled(selection.isEmpty)
        }

    }

}
