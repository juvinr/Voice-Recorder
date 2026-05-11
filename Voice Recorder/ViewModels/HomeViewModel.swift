import AVFoundation
import Foundation
import Observation

@Observable
final class HomeViewModel {

    // MARK: - Services
    let recorderService = AudioRecorderService()
    let playerService = AudioPlayerService()

    // MARK: - State
    var searchText: String = ""
    var selectedFilter: FilterType = .all
    var recordings: [Recording] = []
    var showPermissionAlert: Bool = false

    // MARK: - Recording state (forwarded from service)
    var isRecording: Bool { recorderService.isRecording }
    var isPaused: Bool { recorderService.isPaused }
    var recordingElapsed: TimeInterval { recorderService.elapsedTime }
    var waveformSamples: [Float] { recorderService.waveformSamples }

    // MARK: - Filtered recordings
    var filteredRecordings: [Recording] {
        let byFilter: [Recording]
        switch selectedFilter {
        case .all:
            byFilter = recordings
        case .shared:
            byFilter = recordings.filter { $0.isShared }
        case .starred:
            byFilter = recordings.filter { $0.isStarred }
        }
        guard !searchText.isEmpty else { return byFilter }
        return byFilter.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    // MARK: - Playback convenience (keyed by recording)
    func isPlaying(_ recording: Recording) -> Bool {
        playerService.playingID == recording.id && playerService.isPlaying
    }

    func playbackProgress(_ recording: Recording) -> Double {
        playerService.playingID == recording.id ? playerService.progress : 0
    }

    func playbackElapsed(_ recording: Recording) -> TimeInterval {
        playerService.playingID == recording.id ? playerService.elapsed : 0
    }

    func playbackDuration(_ recording: Recording) -> TimeInterval {
        playerService.playingID == recording.id ? playerService.duration : recording.duration
    }

    // MARK: - Recording actions

    func startRecording() {
        playerService.stop()
        let title = "Recording \(Date().formatted(date: .abbreviated, time: .shortened))"
        Task {
            await recorderService.requestPermissionAndStart(title: title)
            if recorderService.permissionDenied {
                showPermissionAlert = true
            }
        }
    }

    func togglePause() {
        if recorderService.isPaused {
            recorderService.resume()
        } else {
            recorderService.pause()
        }
    }

    func stopRecording() {
        guard let recording = recorderService.stop() else { return }
        recordings.insert(recording, at: 0)
    }

    // MARK: - Playback actions

    func togglePlayback(for recording: Recording) {
        guard !isRecording else { return }
        if playerService.playingID == recording.id {
            playerService.isPlaying ? playerService.pause() : playerService.resume()
        } else {
            playerService.play(recording: recording)
        }
    }

    func seek(_ recording: Recording, to fraction: Double) {
        guard playerService.playingID == recording.id else { return }
        playerService.seek(to: fraction)
    }

    // MARK: - Lifecycle

    func onAppear() {
        loadRecordingsFromDisk()
    }

    // MARK: - Private

    private func loadRecordingsFromDisk() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        recordings = MetadataStore.shared.loadAll()
            .compactMap { (id, metadata) -> Recording? in
                let fileURL = docs.appendingPathComponent("\(id.uuidString).m4a")
                guard FileManager.default.fileExists(atPath: fileURL.path) else {
                    MetadataStore.shared.delete(forID: id)
                    return nil
                }
                return Recording(
                    id: id,
                    title: metadata.title,
                    date: metadata.date,
                    duration: metadata.duration,
                    isStarred: metadata.isStarred,
                    isShared: metadata.isShared,
                    fileURL: fileURL
                )
            }
            .sorted { $0.date > $1.date }
    }
}
