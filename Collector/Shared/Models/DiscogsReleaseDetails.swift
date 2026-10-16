import Foundation

struct DiscogsReleaseDetails: Decodable {
    let tracklist: [Track]?
    let images: [Cover]?

    var tracks: [VinylTrackWidgetItem] { (tracklist ?? []).flatMap(\.songs) }
    var coverURL: URL? {
        let cover = images?.first(where: { $0.type == "primary" }) ?? images?.first
        return (cover?.uri150 ?? cover?.uri).flatMap(URL.init(string:))
    }

    struct Track: Decodable {
        let title: String
        let position: String?
        let duration: String?
        let type_: String?
        let sub_tracks: [Track]?

        var songs: [VinylTrackWidgetItem] {
            if let sub_tracks, !sub_tracks.isEmpty { return sub_tracks.flatMap(\.songs) }
            let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard type_ != "heading", type_ != "index", !name.isEmpty else { return [] }
            return [VinylTrackWidgetItem(title: name, position: position ?? "", duration: duration ?? "")]
        }
    }

    struct Cover: Decodable {
        let type: String?
        let uri: String?
        let uri150: String?
    }
}
