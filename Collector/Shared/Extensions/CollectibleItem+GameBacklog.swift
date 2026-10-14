import Foundation

extension CollectibleItem {
    var resolvedGameBacklogStatus: GameBacklogStatus {
        if let gameBacklogStatus {
            return gameBacklogStatus
        }

        let values = ([templateDetails?["completion"], notes] + tags.map(Optional.some))
            .compactMap { value in
                value?.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            }

        if values.contains(where: { $0.contains("100%") || $0.contains("platin") || $0.contains("complet") }) {
            return .completed
        }

        if values.contains(where: { $0.contains("termin") || $0.contains("finished") || $0.contains("beat") }) {
            return .finished
        }

        if values.contains(where: { $0.contains("jugando") || $0.contains("playing") || $0.contains("actual") || $0.contains("current") }) {
            return .playing
        }

        if values.contains(where: { $0.contains("abandon") || $0.contains("drop") }) {
            return .abandoned
        }

        return .pending
    }
}
