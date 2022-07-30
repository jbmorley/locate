import SwiftUI

class NewPlaceFormModel: ObservableObject {

    @MainActor @Published var address = ""
    @MainActor @Published var link = ""

    private var model: Model

    init(model: Model) {
        self.model = model
    }

    @MainActor func submit() {
        // TODO: Push this into the model?
        model.add(place: Place(id: UUID(), address: address, link: link))
        address = ""
        link = ""
    }

}

struct NewPlaceForm: View {

    struct LayoutMetrics {
        static let minimumTextFieldWidth = 300.0
    }

    @Environment(\.presentationMode) var presentationMode

    @StateObject var placeFormModel: NewPlaceFormModel

    @MainActor init(model: Model) {
        _placeFormModel = StateObject(wrappedValue: NewPlaceFormModel(model: model))
    }

    func submit() {
        placeFormModel.submit()
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        VStack {
            Form {
                LabeledContent("Address") {
                    TextField("", text: $placeFormModel.address)
                        .frame(minWidth: LayoutMetrics.minimumTextFieldWidth)
                }
                LabeledContent("Link") {
                    TextField("", text: $placeFormModel.link)
                        .frame(minWidth: LayoutMetrics.minimumTextFieldWidth)
                }
            }
            .onSubmit(submit)
            HStack {
                Spacer()
                Button("Cancel", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("Add", action: submit)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

}
