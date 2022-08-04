import SwiftUI

class PlaceFormModel: ObservableObject {

    @MainActor @Published var id = UUID()
    @MainActor @Published var address = ""
    @MainActor @Published var link = ""
    @MainActor @Published var isUpdating = false

    // TODO: This should be a set.
    @MainActor @Published var tags: [String] = []

    private var model: Model

    @MainActor init(model: Model, place: Place? = nil) {
        self.model = model
        if let place = place {
            id =  place.id
            address = place.address
            link = place.link
            tags = place.tags ?? []
        }
    }

    @MainActor func submit() {
        model.update(place: Place(id: id, address: address, link: link, tags: tags))
    }

    // TODO: Debounce the changes and guard against identical URLs
    @Sendable func fetchTitles() async {
        for await link in $link.values {
            guard let url = URL(string: link) else {
                continue
            }
            await MainActor.run {
                isUpdating = true
            }
            let title = await Fetcher.title(for: url)
            await MainActor.run {
                isUpdating = false
                guard let title = title, address.isEmpty else {
                    return
                }
                address = title
            }
        }
    }

}

extension String: Identifiable {

    public var id: Self { self }

}

struct PlaceForm: View {

    struct LayoutMetrics {
        static let minimumTextFieldWidth = 300.0
    }

    @Environment(\.presentationMode) var presentationMode

    @StateObject var placeFormModel: PlaceFormModel
    @State var nextTag: String = ""

    @MainActor init(model: Model, place: Place? = nil) {
        _placeFormModel = StateObject(wrappedValue: PlaceFormModel(model: model, place: place))
    }

    func submit() {
        placeFormModel.submit()
        presentationMode.wrappedValue.dismiss()
    }

    var body: some View {
        VStack {
            Form {
                LabeledContent("Link") {
                    TextField("", text: $placeFormModel.link)
                        .lineLimit(1)
                        .frame(minWidth: LayoutMetrics.minimumTextFieldWidth)
                }
                LabeledContent("Address") {
                    TextField("", text: $placeFormModel.address)
                        .lineLimit(1)
                        .frame(minWidth: LayoutMetrics.minimumTextFieldWidth)
                }
                LabeledContent("Tags") {
                    VStack {
                        TagList(items: placeFormModel.tags) { tag in
                            placeFormModel.tags.removeAll { $0 == tag }
                        }
                        TextField("", text: $nextTag)
                            .lineLimit(1)
                            .frame(minWidth: 0)
                            .onSubmit {
                                guard !nextTag.isEmpty else {
                                    return
                                }
                                placeFormModel.tags.append(nextTag)
                                nextTag = ""
                            }
                            .submitScope(!nextTag.isEmpty)
                    }
                }
            }
            .onSubmit(submit)
            HStack {
                if placeFormModel.isUpdating {
                    ProgressView()
                        .controlSize(.small)
                }
                Spacer()
                Button("Cancel", role: .cancel) {
                    presentationMode.wrappedValue.dismiss()
                }
                .keyboardShortcut(.cancelAction)
                Button("OK", action: submit)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .task(placeFormModel.fetchTitles)
    }

}
