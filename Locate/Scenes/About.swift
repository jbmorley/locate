import SwiftUI

import Diligence

public struct About: Scene {

    private let repository: String?
    private let actions: [Action]
    private let acknowledgements: [Acknowledgements]
    private let licenses: [License]

    public init(repository: String? = nil,
                @ActionsBuilder actions: () -> [Action],
                @AcknowledgementsBuilder acknowledgements: () -> [Acknowledgements],
                @LicensesBuilder licenses: () -> [License]) {
        self.repository = repository
        self.actions = actions()
        self.acknowledgements = acknowledgements()
        self.licenses = licenses()
    }

    public var body: some Scene {
        AboutWindow(repository: repository, actions: actions, acknowledgements: acknowledgements, licenses: licenses)
        LicenseWindowGroup(licenses: licenses)
    }

}
