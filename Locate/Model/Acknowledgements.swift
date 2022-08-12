import SwiftUI

import Diligence


@resultBuilder struct AcknowledgementsBuilder {

    static func buildBlock() -> [Acknowledgements] {
        return []
    }

    static func buildBlock(_ acknowledgements: Acknowledgements...) -> [Acknowledgements] {
        return acknowledgements
    }

}


struct Acknowledgements: Identifiable {

    let id = UUID()
    let title: String
    let credits: [Credit]

    init(_ title: String, credits: [Credit]) {
        self.title = title
        self.credits = credits
    }

    init(_ title: String, credits: [String]) {
        self.title = title
        self.credits = credits.map { Credit($0) }
    }

    init(_ title: String, @CreditsBuilder credits: () -> [Credit]) {
        self.title = title
        self.credits = credits()
    }

}
