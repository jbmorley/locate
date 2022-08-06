import SwiftUI

extension String {

    static let tagSeparatorCharacterSet = CharacterSet(charactersIn: ", ")

    func asTags() -> [String] {
        return components(separatedBy: Self.tagSeparatorCharacterSet)
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var containsCompleteTags: Bool {
        guard let lastCharacter = self.last else {
            return false
        }
        let characterSet = CharacterSet(charactersIn: String(lastCharacter))
        return characterSet.isSubset(of: Self.tagSeparatorCharacterSet)
    }

}

#warning("TODO: Can this access the model from the environment?")
#warning("TODO: Move into separate file")
class PlaceFormModel: ObservableObject {

    @MainActor @Published var id = UUID()
    @MainActor @Published var address = ""
    @MainActor @Published var link = ""
    @MainActor @Published var isUpdating = false
    @MainActor @Published var tags: Set<String> = []
    @MainActor @Published var nextTag: String = ""

    private var model: Model

    @MainActor init(model: Model, place: Place? = nil) {
        self.model = model
        if let place = place {
            id =  place.id
            address = place.address
            link = place.link
            tags = Set(place.tags ?? [])
        }
    }

    @MainActor func submit() {
        model.update(place: Place(id: id, address: address, link: link, tags: Array(tags)))
    }

    @MainActor func submitTags() {
        tags = tags.union(nextTag.asTags())
        nextTag = ""
    }

#warning("TODO: Debounce the changes and guard against identical URLs")
    @Sendable func fetchTitles() async {
        for await link in $link.values {
            guard let url = URL(string: link) else {
                continue
            }
            let addressIsEmpty = await MainActor.run {
                return address.isEmpty
            }
            guard addressIsEmpty else {
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

    @Sendable func detectTags() async {
        for await nextTag in $nextTag.values {
            await MainActor.run {
                guard nextTag.containsCompleteTags else {
                    return
                }
                tags = tags.union(nextTag.asTags())
                self.nextTag = ""
            }
            print(nextTag)
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
                        TagList(items: $placeFormModel.tags)
                        TextField("", text: $placeFormModel.nextTag)
                            .lineLimit(1)
                            .frame(minWidth: 0)
                            .onSubmit {
                                placeFormModel.submitTags()
                            }
                            .submitScope(!placeFormModel.nextTag.isEmpty)
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
        .task(placeFormModel.detectTags)
    }

}
