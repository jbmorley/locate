import SwiftUI

struct SelectionCommands: Commands {

    @ObservedObject var selection: Selection

    @MainActor var body: some Commands {

        CommandGroup(after: .textEditing) {

            Button("Copy") {
                selection.copy()
            }
            .keyboardShortcut("c")
            .disabled(selection.isEmpty)

            Divider()

            Button("Edit Item") {
                selection.edit()
            }
            .keyboardShortcut("i")
            .disabled(!selection.canEdit)

            Button("Delete Selected Items") {
                selection.delete()
            }
            .keyboardShortcut(.delete)
            .disabled(selection.isEmpty)

        }

    }

}
