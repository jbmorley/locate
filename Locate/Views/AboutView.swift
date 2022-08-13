import SwiftUI

import Diligence
import Interact

struct AboutView: View {

    @Environment(\.openURL) private var openURL
    @Environment(\.openWindow) private var openWindow

    let actions: [Action]
    let acknowledgements: [Acknowledgements]
    let licenses: [License]

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack {
                    MacIcon("Icon")
                    Spacer()
                }
                .padding()
                .padding([.horizontal])
                ScrollView {
                    VStack {
                        ApplicationNameTitle()
                            .horizontalSpace(.trailing)
                            .padding(.bottom, 2.0)
                        ForEach(acknowledgements) { acknowledgements in
                            AboutSection(acknowledgements.title) {
                                ForEach(acknowledgements.credits) { credit in
                                    if let url = credit.url {
                                        Text(credit.name)
                                            .hyperlink {
                                                openURL(url)
                                            }
                                    } else {
                                        Text(credit.name)
                                    }
                                }
                            }
                        }
                        AboutSection("Licenses") {
                            ForEach(licenses) { license in
                                Text(license.name)
                                    .hyperlink {
                                        openWindow(id: LicenseWindowGroup.windowID, value: license.id)
                                    }
                            }
                        }
                    }
                    .padding(.top)
                }
                .textSelection(.enabled)
            }
            HStack {
                Text("Version \(Bundle.main.version ?? "") (\(Bundle.main.build ?? ""))")
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
                if let url = Bundle.main.commitUrl(for: "inseven/anytime"),
                   let commit = Bundle.main.commit {
                    Text(commit)
                        .hyperlink {
                            openURL(url)
                        }
                }
                Spacer()
                ForEach(actions) { action in
                    Button(action.title) {
                        openURL(action.url)
                    }
                }
            }
            .padding()
        }
    }

}
