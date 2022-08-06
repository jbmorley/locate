import SwiftUI

struct ItemCommands: Commands {

    var model: Model

    @MainActor var body: some Commands {
        CommandGroup(before: .newItem) {
            Button("New Item") {
                model.add()
            }
            .keyboardShortcut("n")
        }
    }

}
