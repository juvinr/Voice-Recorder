import Foundation

extension TimeInterval {
    var mmss: String {
        String(format: "%02d:%02d", Int(self) / 60, Int(self) % 60)
    }
}
