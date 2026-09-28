import Foundation

extension String {
    var vintageSafe: String {
        folding(options: [.diacriticInsensitive, .widthInsensitive], locale: .current)
    }
}
