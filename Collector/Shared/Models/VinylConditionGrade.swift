import Foundation

enum VinylConditionGrade: String, CaseIterable, Identifiable, Codable, Hashable {
    case unknown
    case mint
    case nearMint
    case veryGoodPlus
    case veryGood
    case goodPlus
    case good
    case fair
    case poor

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .unknown:
            L10n.VinylCondition.unknown
        case .mint:
            L10n.VinylCondition.mint
        case .nearMint:
            L10n.VinylCondition.nearMint
        case .veryGoodPlus:
            L10n.VinylCondition.veryGoodPlus
        case .veryGood:
            L10n.VinylCondition.veryGood
        case .goodPlus:
            L10n.VinylCondition.goodPlus
        case .good:
            L10n.VinylCondition.good
        case .fair:
            L10n.VinylCondition.fair
        case .poor:
            L10n.VinylCondition.poor
        }
    }

    var isKnown: Bool {
        self != .unknown
    }
}
