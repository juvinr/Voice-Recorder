import AVFoundation
import SwiftUI

@main
struct Voice_RecorderApp: App {
    init() {
        configureAudioSession()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }

    private func configureAudioSession() {
        #if canImport(UIKit)
        try? AVAudioSession.sharedInstance().setCategory(
            .playAndRecord,
            mode: .default,
            options: [.defaultToSpeaker, .allowBluetooth]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif
    }
}
