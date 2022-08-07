import SwiftUI

@main
struct LocateApp: App {

    var model: Model

    init() {
        model = Model()
    }

    var body: some Scene {
        Window("Locate", id: "main") {
            ContentView()
                .environmentObject(model)
                .environmentObject(model.selection)
        }
        .commands {
            ToolbarCommands()
            SearchCommands()
            ItemCommands(model: model)
            SelectionCommands(selection: model.selection)
        }
    }
}
