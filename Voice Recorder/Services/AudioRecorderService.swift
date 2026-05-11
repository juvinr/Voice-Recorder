import AVFoundation
import Observation

@Observable
final class AudioRecorderService: NSObject {

    // MARK: - Observable state
    private(set) var isRecording: Bool = false
    private(set) var isPaused: Bool = false
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var waveformSamples: [Float] = []
    private(set) var currentFileURL: URL? = nil
    var permissionDenied: Bool = false

    // MARK: - Private
    private var recorder: AVAudioRecorder?
    private var meteringTimer: Timer?
    private var currentID: UUID = UUID()
    private var currentTitle: String = ""
    private var startDate: Date?
    private var accumulatedTime: TimeInterval = 0
    private let waveformBufferSize = 50

    private static let docs =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private var recordingSettings: [String: Any] {
        [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    // MARK: - Public API

    func requestPermissionAndStart(title: String) async {
        let granted: Bool
        #if canImport(UIKit)
        granted = await AVAudioApplication.requestRecordPermission()
        #else
        granted = await AVCaptureDevice.requestAccess(for: .audio)
        #endif

        guard granted else {
            permissionDenied = true
            return
        }

        #if canImport(UIKit)
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playAndRecord,
                mode: .default,
                options: .defaultToSpeaker
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            return
        }
        #endif

        let id = UUID()
        let fileURL = Self.docs.appendingPathComponent("\(id.uuidString).m4a")

        do {
            recorder = try AVAudioRecorder(url: fileURL, settings: recordingSettings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            recorder?.record()

            currentID = id
            currentTitle = title
            currentFileURL = fileURL
            accumulatedTime = 0
            elapsedTime = 0
            waveformSamples = []
            startDate = Date()
            isRecording = true
            isPaused = false

            startMeteringTimer()
            registerForInterruptions()
        } catch {
            // silently fail — isRecording stays false
        }
    }

    func pause() {
        guard isRecording, !isPaused else { return }
        recorder?.pause()
        accumulatedTime += Date().timeIntervalSince(startDate ?? Date())
        startDate = nil
        isPaused = true
        stopMeteringTimer()
    }

    func resume() {
        guard isRecording, isPaused else { return }
        recorder?.record()
        startDate = Date()
        isPaused = false
        startMeteringTimer()
    }

    func stop() -> Recording? {
        guard isRecording else { return nil }

        if !isPaused {
            accumulatedTime += Date().timeIntervalSince(startDate ?? Date())
        }

        let finalDuration = accumulatedTime
        let finalID = currentID
        let finalTitle = currentTitle
        let finalURL = currentFileURL
        let finalDate = Date()

        stopMeteringTimer()
        recorder?.stop()
        recorder = nil

        #if canImport(UIKit)
        try? AVAudioSession.sharedInstance().setActive(
            false, options: .notifyOthersOnDeactivation
        )
        #endif

        isRecording = false
        isPaused = false
        elapsedTime = 0
        waveformSamples = []
        currentFileURL = nil
        startDate = nil
        accumulatedTime = 0
        currentID = UUID()
        currentTitle = ""

        unregisterForInterruptions()

        guard let finalURL else { return nil }

        let recording = Recording(
            id: finalID,
            title: finalTitle,
            date: finalDate,
            duration: finalDuration,
            isStarred: false,
            isShared: false,
            fileURL: finalURL
        )

        MetadataStore.shared.save(
            RecordingMetadata(
                title: finalTitle,
                date: finalDate,
                duration: finalDuration,
                isStarred: false,
                isShared: false
            ),
            forID: finalID
        )

        return recording
    }

    // MARK: - Private helpers

    private func startMeteringTimer() {
        meteringTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { [weak self] _ in
            self?.updateMeters()
        }
    }

    private func stopMeteringTimer() {
        meteringTimer?.invalidate()
        meteringTimer = nil
    }

    private func updateMeters() {
        guard let recorder, recorder.isRecording else { return }
        recorder.updateMeters()

        // averagePower returns dB in -160...0; clamp -50...0 → 0...1
        let db = recorder.averagePower(forChannel: 0)
        let normalized = Float(max(0, (db + 50) / 50))

        waveformSamples.append(normalized)
        if waveformSamples.count > waveformBufferSize {
            waveformSamples.removeFirst()
        }

        if let startDate {
            elapsedTime = accumulatedTime + Date().timeIntervalSince(startDate)
        }
    }

    // MARK: - Interruption handling (iOS only)

    private func registerForInterruptions() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance()
        )
        #endif
    }

    private func unregisterForInterruptions() {
        #if canImport(UIKit)
        NotificationCenter.default.removeObserver(
            self,
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
        #endif
    }

    #if canImport(UIKit)
    @objc private func handleInterruption(notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        switch type {
        case .began:
            pause()
        case .ended:
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) { resume() }
            }
        @unknown default:
            break
        }
    }
    #endif
}

// MARK: - AVAudioRecorderDelegate
extension AudioRecorderService: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        guard !flag else { return }
        // Abnormal finish (interruption, no explicit stop()) — clean up state
        stopMeteringTimer()
        if let url = currentFileURL {
            try? FileManager.default.removeItem(at: url)
        }
        isRecording = false
        isPaused = false
        elapsedTime = 0
        waveformSamples = []
        currentFileURL = nil
        startDate = nil
        accumulatedTime = 0
    }

    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        stopMeteringTimer()
        isRecording = false
        isPaused = false
    }
}
