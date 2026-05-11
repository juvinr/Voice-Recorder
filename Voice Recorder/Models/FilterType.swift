import Foundation

enum FilterType: CaseIterable, Hashable {
    case all, shared, starred

    var title: String {
        switch self {
        case .all: return "All"
        case .shared: return "Shared"
        case .starred: return "Starred"
        }
    }
}
