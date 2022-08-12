import SwiftUI

struct AboutCommands: Commands {

    @Environment(\.openWindow) private var openWindow

    @MainActor var body: some Commands {

        CommandGroup(replacing: .appInfo) {
            Button("About \(Bundle.main.displayName ?? "")") {
                openWindow(id: AboutWindow.windowID)
            }
        }

    }

}
