import SwiftUI

import Diligence

struct AboutWindow: Scene {

    static let windowID = "diligence-about-window"

    let actions: [Action]
    let acknowledgements: [Acknowledgements]
    let licenses: [License]

    var body: some Scene {
        Window("About", id: Self.windowID) {
            AboutView(actions: actions, acknowledgements: acknowledgements, licenses: licenses)
                .frame(width: 600, height: 360)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .windowStyle(.hiddenTitleBar)
    }

}
