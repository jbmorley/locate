import SwiftUI

import Diligence

struct AboutWindow: Scene {

    static let windowID = "diligence-about-window"

    let actions: [Action]
    let credits: [Acknowledgements]
    let licenses: [License]

    var body: some Scene {
        Window("About \(Bundle.main.displayName ?? "")", id: Self.windowID) {
            AboutView(actions: actions, credits: credits, licenses: licenses)
                .frame(width: 640, height: 460)
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
    }

}
