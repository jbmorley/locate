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

struct PlaceList: View {

    @ObservedObject var model: Model

    var body: some View {
        List(selection: $model.selection.ids) {
            ForEach(model.filteredPlaces) { place in
                HStack {
                    if let image = model.images[place.id] {
                        Image(nsImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 6.0))
                    }
                    VStack(alignment: .leading) {
                        Text(place.address)
                        if let tags = place.tags, !tags.isEmpty {
                            TagList(items: Set(tags))
                        }
                    }
                    .lineLimit(1)
                }
            }
        }
        .contextMenu(forSelectionType: Place.ID.self) { selection in
            Button("Open") {
                model.open(ids: selection)
            }
            Divider()
            if selection.count == 1, let id = selection.first {
                Button("Edit") {
                    model.edit(id: id)
                }
                Divider()
            }
            Button("Copy") {
                model.copy(ids: selection)
            }
            Divider()
            Button("Delete", role: .destructive) {
                model.delete(ids: selection)
            }
        } primaryAction: { selection in
            model.open(ids: selection)
        }
        .searchable(text: $model.filter,
                    tokens: $model.filterTokens,
                    suggestedTokens: $model.suggestedTokens) { token in
            Text(token)
        }
    }

}
