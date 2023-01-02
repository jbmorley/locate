// Copyright (c) 2022-2023 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
