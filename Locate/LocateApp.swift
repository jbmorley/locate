import SwiftUI

@main
struct LocateApp: App {

    @StateObject var model = Model()

    var body: some Scene {
        Window("Locate", id: "main") {
            ContentView(model: model)
        }
        .commands {
            ToolbarCommands()

            CommandMenu("Edit") {
                Button("Copy") {
                    model.copy(ids: model.selection)
                }
                .keyboardShortcut("c")
            }
        }
    }
}
