import Foundation

import Diligence

@resultBuilder struct CreditsBuilder {

    static func buildBlock() -> [Credit] {
        return []
    }

    static func buildBlock(_ credits: Credit...) -> [Credit] {
        return credits
    }

}
