import SwiftUI

import Diligence

struct AboutWindow: Scene {

    private struct LayoutMetrics {
        static let width = 600.0
        static let height = 360.0
    }

    static let windowID = "diligence-about-window"

    private let repository: String?
    private let actions: [Action]
    private let acknowledgements: [Acknowledgements]
    private let licenses: [License]

    public init(repository: String? = nil,
                actions: [Action],
                acknowledgements: [Acknowledgements],
                licenses: [License]) {
        self.repository = repository
        self.actions = actions
        self.acknowledgements = acknowledgements
        self.licenses = licenses
    }

    var body: some Scene {
        Window("About", id: Self.windowID) {
            MacAboutView(repository: repository,
                         actions: actions,
                         acknowledgements: acknowledgements,
                         licenses: licenses)
            .frame(width: LayoutMetrics.width, height: LayoutMetrics.height)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .windowStyle(.hiddenTitleBar)
    }

}
