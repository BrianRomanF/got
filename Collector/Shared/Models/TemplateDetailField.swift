import Foundation

struct TemplateDetailField: Identifiable, Hashable {
    let key: String
    let title: String
    let placeholder: String

    var id: String {
        key
    }
}
