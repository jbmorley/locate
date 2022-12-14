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

struct TagList: View {

    struct LayoutMetrics {
        static let cornerRadius = 4.0
    }

    @Binding var items: Set<String>
    private var isEditable: Bool

    init(items: Set<String>) {
        _items = Binding.constant(items)
        isEditable = false
    }

    init(items: Binding<Set<String>>) {
        _items = items
        isEditable = true
    }

    var body: some View {
        HStack {
            ForEach(items.sorted()) { item in
                HStack(spacing: 0) {
                    Text(item)
                        .lineLimit(1)
                        .font(.footnote)
                        .padding([.top, .bottom], 2)
                        .padding([.leading, .trailing], 6)
                    if isEditable {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
                .padding(2)
                .foregroundColor(item.color())
                .background(item.color()
                    .opacity(0.3)
                    .background(Color.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: LayoutMetrics.cornerRadius))
                .onOptionalTapGesture(isEditable ? {
                    guard isEditable else {
                        return
                    }
                    items.remove(item)
                } : nil)
            }
            Spacer()
        }
    }

}
