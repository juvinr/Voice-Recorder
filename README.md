# Voice Recorder

A clean, modern iOS voice recorder app built with SwiftUI and AVFoundation. Record audio, watch a live waveform respond in real time, and play back any saved recording — all from a minimal, focused interface.

## Screenshots

> <img width="292" height="633" alt="Voice Recorder" src="https://github.com/user-attachments/assets/73807056-3c66-4b59-9ccd-dadef2b00941" />


## Features

- **One-tap recording** — tap the record button and start capturing immediately
- **Live waveform** — 50 animated bars visualise microphone amplitude in real time as you record
- **Pause & resume** — pause mid-recording and pick up where you left off; elapsed time accumulates correctly across multiple pauses
- **Playback** — tap play on any saved recording; a scrubber slider lets you seek to any position
- **Search** — filter your recordings by title with instant case-insensitive search
- **Filter tabs** — quickly switch between All, Shared, and Starred recordings
- **Persistent storage** — recordings and their metadata survive app restarts; orphaned metadata is cleaned up automatically on launch
- **Audio session management** — handles phone call interruptions gracefully (auto-pause; auto-resume when appropriate)
- **Cross-platform** — targets iOS, iPadOS, and macOS (Catalyst); `AVAudioSession` calls are conditionally compiled for iOS only

## Architecture

The app follows **MVVM** using Swift's modern `@Observable` macro (iOS 17+).

```
Views
  └── HomeViewModel  (@Observable)
        ├── AudioRecorderService  (AVAudioRecorder, metering, waveform buffer)
        └── AudioPlayerService   (AVAudioPlayer, progress tracking)
              MetadataStore      (JSON sidecar persistence)
```

| Layer | Responsibility |
|---|---|
| **Models** | `Recording`, `RecordingMetadata`, `FilterType` — pure data |
| **Services** | `AudioRecorderService`, `AudioPlayerService`, `MetadataStore` — all I/O and AVFoundation |
| **ViewModel** | `HomeViewModel` — orchestrates services, exposes state, no UIKit/AVFoundation imports |
| **Views** | Layout and rendering only; receive data and closures, never touch services directly |

### Persistence

Audio files are saved to the app's Documents directory as `.m4a` (AAC, 44.1 kHz, mono). Each recording gets a sidecar `<UUID>.json` file that stores title, date, duration, and flags. On launch, `MetadataStore` scans for all JSON files and reconciles them against the audio files on disk.

### Live Waveform

`AudioRecorderService` polls `AVAudioRecorder.averagePower(forChannel:)` every **30 ms** and normalises the dB value (−50…0 dB → 0…1). The rolling buffer of the last 50 samples is forwarded through `HomeViewModel` to `LiveWaveformView`, where each bar animates independently with a `.linear(duration: 0.05)` animation for a smooth, real-time response.

## Tech Stack

- **SwiftUI** — declarative UI, animations, transitions
- **AVFoundation** — `AVAudioRecorder`, `AVAudioPlayer`, `AVAudioSession`
- **Swift Observation** (`@Observable`) — reactive state without `ObservableObject`
- **Foundation** — `FileManager`, `JSONEncoder`/`JSONDecoder`, `Timer`
- Xcode 26.2 · Swift 5 · iOS 26.2+ · macOS 26.2+

## Project Structure

```
Voice Recorder/
├── Extensions/
│   └── TimeInterval+Format.swift     # MM:SS formatting
├── Models/
│   ├── Recording.swift               # Core data model
│   ├── RecordingMetadata.swift       # Codable sidecar struct
│   └── FilterType.swift              # all / shared / starred
├── Services/
│   ├── AudioRecorderService.swift    # AVAudioRecorder + metering
│   ├── AudioPlayerService.swift      # AVAudioPlayer + progress
│   └── MetadataStore.swift           # JSON file persistence
├── ViewModels/
│   └── HomeViewModel.swift           # State orchestrator
├── Views/
│   ├── HomeView.swift                # Root layout
│   └── Components/
│       ├── HeaderView.swift
│       ├── SearchBarView.swift
│       ├── FilterTabsView.swift
│       ├── FilterChip.swift
│       ├── RecordingListView.swift
│       ├── AudioCardView.swift
│       ├── PlaybackControlsView.swift
│       ├── RecordingControlsView.swift
│       ├── ActiveRecordingView.swift
│       ├── LiveWaveformView.swift
│       └── CircleIcon.swift
└── Voice_RecorderApp.swift
```

## Getting Started

1. Clone the repository
2. Open `Voice Recorder.xcodeproj` in Xcode 26 or later
3. Select your target device or simulator
4. Build and run (`⌘R`)

> **Microphone permission** — the app will prompt for microphone access on first launch. Recording requires permission to be granted.

## License

MIT
