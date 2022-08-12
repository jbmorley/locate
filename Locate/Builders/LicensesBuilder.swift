import Foundation

import Diligence

@resultBuilder struct LicensesBuilder {

    static func buildBlock() -> [License] {
        return []
    }

    static func buildBlock(_ licenses: License...) -> [License] {
        return licenses
    }

}
