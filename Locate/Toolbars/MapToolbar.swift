import SwiftUI

struct MapToolbar: CustomizableToolbarContent {

    @EnvironmentObject var model: Model

    var id: String

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
