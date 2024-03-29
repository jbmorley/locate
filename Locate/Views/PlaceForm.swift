// Copyright (c) 2022-2023 Jason Morley
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import SwiftUI

import SwiftSoup

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

enum ParseError: Error {
    case invalidEncoding
}

extension URL {

    func document() async throws -> Document {
        let request = URLRequest(url: self)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let contents = String(data: data, encoding: .utf8) else {
            throw ParseError.invalidEncoding
        }
        return try SwiftSoup.parse(contents, absoluteString)
    }

    func addresses() async -> [String] {
        return []
    }

}

extension Document {

    func structuredText() throws -> String {
        let elements = try getAllElements()
        var multilineContents: String = ""
        for element in elements {
            for textNode in element.textNodes() {
                let element = textNode.text().trimmingCharacters(in: .whitespacesAndNewlines)
                guard !element.isEmpty else {
                    continue
                }
                multilineContents.append(contentsOf: textNode.text())
                multilineContents.append(contentsOf: "\n")
            }
        }
        return multilineContents
    }

    func addresses() throws -> [String] {
        return try structuredText().addresses()
    }

}

extension String {

    func addresses() throws -> [String] {
        let types: NSTextCheckingResult.CheckingType = [.address]
        let detector = try NSDataDetector(types: types.rawValue)
        let range = NSRange(startIndex..<endIndex, in: self)
        var addresses: [String] = []
        detector.enumerateMatches(in: self, options: [], range: range) { result, flags, _ in
            guard let range = result?.range else {
                return
            }
            let nsContents = self as NSString
            addresses.append(nsContents.substring(with: range) as String)
        }
        return addresses
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
            let title = try? await url.document().addresses().first
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
