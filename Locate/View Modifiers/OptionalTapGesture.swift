import SwiftUI

struct OptionalTapGesture: ViewModifier {

    let perform: (() -> Void)?

    func body(content: Content) -> some View {
        if let perform = perform {
            content.onTapGesture(perform: perform)
        } else {
            content
        }
    }

}

extension View {

    func onOptionalTapGesture(_ perform: (() -> Void)?) -> some View {
        return modifier(OptionalTapGesture(perform: perform))
    }

}
