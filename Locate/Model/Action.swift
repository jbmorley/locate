import Foundation

struct Action: Identifiable {

    let id = UUID()
    let title: String
    let url: URL

    init(_ title: String, url: URL) {
        self.title = title
        self.url = url
    }

}
