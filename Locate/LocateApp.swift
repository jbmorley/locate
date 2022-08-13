import SwiftUI

import Diligence

@main
struct LocateApp: App {

    var model: Model

    init() {
        model = Model()
    }

    var body: some Scene {
        Window("Locate", id: "main") {
            ContentView()
                .environmentObject(model)
                .environmentObject(model.selection)
        }
        .commands {
            ToolbarCommands()
            SearchCommands()
            ItemCommands(model: model)
            SelectionCommands(selection: model.selection)
            AboutCommands()
        }
        About(repository: "jbmorley/locate") {

            Action("GitHub", url: URL(string: "https://github.com/jbmorley/locate")!)

        } acknowledgements: {

            Acknowledgements("Developers") {
                Credit("Jason Morley", url: URL(string: "https://jbmorley.co.uk"))
            }

            Acknowledgements("Thanks") {
                Credit("Michael Dales")
                Credit("Sarah Barbour")
            }

        } licenses: {

            License("Diligence", author: "InSeven Limited", filename: "diligence-license")
            License("HashRainbow", author: "Sarah Barbour", filename: "hash-rainbow-license")
            License("Interact", author: "InSeven Limited", filename: "interact-license")
            License("SwiftSoup", author: "Nabil Chatbi", filename: "swift-soup-license")

        }
    }
}
