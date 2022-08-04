import Foundation

import SwiftSoup

enum FetcherError: Error {
    case error
}

class Fetcher {

    // TODO: Clean this up?
    static func title(for url: URL) async -> String? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let html = String(data: data, encoding: .utf8) else {
                return nil
            }
            let document = try SwiftSoup.parse(html)
            return try document.title()
        } catch {
            print("Failed to fetch title with error \(error).")
            return nil
        }
    }

}
