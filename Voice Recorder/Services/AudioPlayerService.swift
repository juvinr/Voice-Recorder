import AVFoundation
import Observation

@Observable
final class AudioPlayerService: NSObject {

    // MARK: - Observable state
    private(set) var playingID: UUID? = nil
    private(set) var isPlaying: Bool = false
    private(set) var progress: Double = 0
    private(set) var elapsed: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    // MARK: - Private
    private var player: AVAudioPlayer?
    private var progressTimer: Timer?

    // MARK: - Public API

    func play(recording: Recording) {
        guard let fileURL = recording.fileURL,
              FileManager.default.fileExists(atPath: fileURL.path) else { return }

        stop()

        #if canImport(UIKit)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        #endif

        do {
            player = try AVAudioPlayer(contentsOf: fileURL)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()

            playingID = recording.id
            duration = player?.duration ?? recording.duration
            elapsed = 0
            progress = 0
            isPlaying = true

            startProgressTimer()
        } catch {
            // silently fail
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        stopProgressTimer()
    }

    func resume() {
        player?.play()
        isPlaying = true
        startProgressTimer()
    }

    func stop() {
        player?.stop()
        player = nil
        stopProgressTimer()
        playingID = nil
        isPlaying = false
        progress = 0
        elapsed = 0
        duration = 0

        #if canImport(UIKit)
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation
        )
        #endif
    }

    func seek(to fraction: Double) {
        guard let player else { return }
        let clamped = max(0, min(1, fraction))
        player.currentTime = clamped * player.duration
        elapsed = player.currentTime
        progress = clamped
    }

    // MARK: - Private helpers

    private func startProgressTimer() {
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }

    private func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
    }

    private func updateProgress() {
        guard let player, player.isPlaying else { return }
        elapsed = player.currentTime
        duration = player.duration
        progress = duration > 0 ? elapsed / duration : 0
    }
}

// MARK: - AVAudioPlayerDelegate
extension AudioPlayerService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopProgressTimer()
        isPlaying = false
        progress = 0
        elapsed = 0
        playingID = nil

        #if canImport(UIKit)
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation
        )
        #endif
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        stop()
    }
}
