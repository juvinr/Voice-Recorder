import SwiftUI

struct RecordingListView: View {
    let recordings: [Recording]
    let isPlaying: (Recording) -> Bool
    let playbackProgress: (Recording) -> Double
    let playbackElapsed: (Recording) -> TimeInterval
    let onTogglePlayback: (Recording) -> Void
    let onSeek: (Recording, Double) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(recordings) { recording in
                    AudioCardView(
                        recording: recording,
                        isPlaying: isPlaying(recording),
                        playbackProgress: playbackProgress(recording),
                        playbackElapsed: playbackElapsed(recording),
                        onTogglePlayback: { onTogglePlayback(recording) },
                        onSeek: { onSeek(recording, $0) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}
