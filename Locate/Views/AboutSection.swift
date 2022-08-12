import SwiftUI

struct AboutSection<Content: View>: View {

    var title: String?
    var content: Content

    public init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4.0) {
            if let title = title {
                Text(title)
                    .font(.title)
            }
            content
        }
        .horizontalSpace(.trailing)
        .padding([.bottom], 6.0)
    }

}
