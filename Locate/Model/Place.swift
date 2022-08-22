// Copyright (c) 2022 Jason Morley
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

import Foundation

struct Place: Identifiable, Hashable, Codable {

    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }

    var url: URL? {
        return URL(string: link)
    }

    let id: UUID
    let address: String
    let link: String
    let tags: [String]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func matches(filter: String, tags: Set<String>) -> Bool {
        guard !filter.isEmpty || !tags.isEmpty else {
            return true
        }
        let placeTags = Set(self.tags ?? [])
        let matchesTags = !tags.intersection(placeTags).isEmpty
        let matchesFilter = !filter.isEmpty && address.localizedCaseInsensitiveContains(filter)
        return matchesTags || matchesFilter
    }

}
