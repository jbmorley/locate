import SwiftUI

struct TagList: View {

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
                .background(item.color().opacity(0.3))
                .clipShape(Capsule())
                .onTapGesture {
                    guard isEditable else {
                        return
                    }
                    items.remove(item)
                }
            }
            Spacer()
        }
    }

}
