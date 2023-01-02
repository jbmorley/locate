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
