import SwiftUI

struct TagList: View {

    var items: [String]
    var onDelete: ((String) -> Void)? = nil

    var body: some View {
        HStack {
            ForEach(items) { item in
                HStack(spacing: 0) {
                    Text(item)
                        .lineLimit(1)
                        .font(.footnote)
                        .padding([.top, .bottom], 2)
                        .padding([.leading, .trailing], 6)
                    if let onDelete = onDelete {
                        Image(systemName: "xmark.circle.fill")
                            .onTapGesture {
                                onDelete(item)
                            }
                    }
                }
                .padding(2)
                .foregroundColor(item.color())
                .background(item.color().opacity(0.3))
                .clipShape(Capsule())
            }
            Spacer()
        }
    }

}
