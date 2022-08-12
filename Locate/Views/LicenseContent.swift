import SwiftUI

import Diligence

struct LicenseContent: View {

    var license: License

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("Author")
                    Spacer()
                    Text(license.author)
                        .foregroundColor(.secondary)
                }
                Divider()
                Text(license.text)
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                Divider()
                HStack {
                    Spacer()
                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(license.text, forType: .string)
                    }
                }
                .padding()
            }
            .background(Color.textBackgroundColor)
        }
        .background(Color.textBackgroundColor)
    }

}
