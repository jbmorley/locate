import Foundation

struct Place: Identifiable, Hashable, Codable {

    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }

    var url: URL? {
        return URL(string: link)
    }

    let id: UUID
    let address: String
    let link: String
    let tags: [String]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
