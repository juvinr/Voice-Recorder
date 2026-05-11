import Foundation

struct RecordingMetadata: Codable {
    var title: String
    var date: Date
    var duration: TimeInterval
    var isStarred: Bool
    var isShared: Bool
}
