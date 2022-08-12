import SwiftUI

import Diligence

struct About: Scene {

    let actions: [Action]
    let acknowledgements: [Acknowledgements]
    let licenses: [License]

    init(@ActionsBuilder actions: () -> [Action],
         @AcknowledgementsBuilder acknowledgements: () -> [Acknowledgements],
         @LicensesBuilder licenses: () -> [License]) {
        self.actions = actions()
        self.acknowledgements = acknowledgements()
        self.licenses = licenses()
    }

    var body: some Scene {
        AboutWindow(actions: actions, acknowledgements: acknowledgements, licenses: licenses)
        LicenseWindows(licenses: licenses)
    }

}
