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

#warning("TODO: Can I do @MainActor annotation here and get all the benefits?")
#warning("TODO: Selection should watch store for disappearing items")
class Selection: ObservableObject {

    var model: Model

    @MainActor @Published var ids: Set<Place.ID> = []

    @MainActor var isEmpty: Bool {
        return ids.isEmpty
    }

    @MainActor var canEdit: Bool {
        return ids.count == 1
    }

    @MainActor var urls: [URL] {
        return model.urls(ids: ids)
    }

    @MainActor init(model: Model) {
        self.model = model
    }

    @MainActor func delete() {
        model.delete(ids: ids)
        ids = []
    }

    @MainActor func open() {
        model.open(ids: ids)
    }

    @MainActor func copy() {
        model.copy(ids: ids)
    }

    @MainActor func edit() {
        guard let id = ids.first else {
            return
        }
        model.edit(id: id)
    }

}
