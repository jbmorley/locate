import SwiftUI

@main
struct LocateApp: App {

    @StateObject var model = Model()

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
        }
        .commands {
            CommandMenu("Edit") {
                Button("Copy") {
                    model.copy(ids: model.selection)
                }
                .keyboardShortcut("c")
            }
        }
    }
}
