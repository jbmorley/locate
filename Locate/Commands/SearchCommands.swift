import SwiftUI

extension NSWindow {

    var searchBarItem: NSSearchToolbarItem? {
        guard let toolbar = NSApp.keyWindow?.toolbar,
              let item = toolbar.items.first(where: { item in
                  item.itemIdentifier.rawValue == "com.apple.SwiftUI.search"
              }),
              let searchBarItem = item as? NSSearchToolbarItem
        else {
            return nil
        }
        return searchBarItem
    }

}

// See https://developer.apple.com/forums/thread/688679
struct SearchCommands: Commands {

    @MainActor var body: some Commands {
        CommandGroup(before: .textEditing) {
            Button("Search") {
                guard let searchBarItem = NSApp.keyWindow?.searchBarItem else {
                    return
                }
                searchBarItem.beginSearchInteraction()
            }
            .keyboardShortcut("f", modifiers: .command)

            Divider()
        }
    }
}
