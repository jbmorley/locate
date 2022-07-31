import SwiftUI

import HashRainbow

extension Array where Element == Color {

    static let system: [Color] = [
        .pink,
        .purple,
        .orange,
        .green,
        .mint,
        .yellow,
        .teal,
        .red,
        .indigo,
        .cyan,
    ]

}

extension String {

    func color() -> Color {
        return HashRainbow.colorForString(self, colors: .system)
    }

}
