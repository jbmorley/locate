import Foundation

struct Place: Identifiable, Hashable, Codable {

    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.id == rhs.id
    }

    let id: UUID
    let address: String
    let link: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
