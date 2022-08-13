import SwiftUI

import Diligence

struct LicenseWindowGroup: Scene {

    static let windowID = "diligence-license-window"

    let licenses: [License]

    var body: some Scene {
        WindowGroup(id: Self.windowID, for: License.ID.self) { $licenseId in
            if let license = licenses.first(where: { $0.id == licenseId }) {
                LicenseContent(license: license)
                    .frame(width: 400, height: 500)
            }
        }
        .windowResizability(.contentSize)
    }

}
