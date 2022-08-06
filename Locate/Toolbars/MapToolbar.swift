import SwiftUI

struct MapToolbar: CustomizableToolbarContent {

    var id: String
    @ObservedObject var model: Model

    var body: some CustomizableToolbarContent {

        ToolbarItem(id: "center") {
            Button {
                model.center()
            } label: {
                Label("Current Location", systemImage: "location")
            }
            .help("Show current location")
        }

    }

}
