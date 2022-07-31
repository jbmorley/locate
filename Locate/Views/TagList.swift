import SwiftUI

struct TagList: View {

    var items: [String]
    var color: Color

    var body: some View {
        HStack {
            ForEach(items) { item in
                Text(item)
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundColor(color)
                    .padding([.top, .bottom], 4)
                    .padding([.leading, .trailing], 8)
                    .background(color.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
    }

}
