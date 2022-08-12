import Foundation

@resultBuilder struct ActionsBuilder {

    static func buildBlock() -> [Action] {
        return []
    }

    static func buildBlock(_ actions: Action...) -> [Action] {
        return actions
    }

}
