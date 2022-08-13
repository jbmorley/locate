import SwiftUI

struct MacIcon: View {

    struct LayoutMetrics {
        static let size = 152.0
    }

    let name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: LayoutMetrics.size, height: LayoutMetrics.size)
    }

}
