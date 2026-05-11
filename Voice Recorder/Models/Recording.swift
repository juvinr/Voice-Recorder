import Foundation

struct Recording: Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var duration: TimeInterval
    var isStarred: Bool
    var isShared: Bool
    var fileURL: URL? = nil
}

extension Recording {
    static let samples: [Recording] = [
        Recording(
            id: UUID(),
            title: "Momentum in FIFA and Startup Strategy",
            date: Date(),
            duration: 83,
            isStarred: false,
            isShared: false
        ),
        Recording(
            id: UUID(),
            title: "Morning Sync on Video Messages to Prod and Express Payouts",
            date: Date(),
            duration: 142,
            isStarred: false,
            isShared: true
        )
    ]
}
