import SwiftUI

struct AudioCardView: View {
    let recording: Recording
    let isPlaying: Bool
    let playbackProgress: Double
    let playbackElapsed: TimeInterval
    let onTogglePlayback: () -> Void
    let onSeek: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(recording.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)

            Text(recording.title)
                .font(.headline)
                .fontWeight(.semibold)

            HStack(alignment: .top) {
                PlaybackControlsView(
                    isPlaying: isPlaying,
                    progress: playbackProgress,
                    elapsed: playbackElapsed,
                    duration: recording.duration,
                    onToggle: onTogglePlayback,
                    onSeek: onSeek
                )

                Spacer()

                HStack(spacing: 16) {
                    Button { } label: { CircleIcon(systemName: "doc.text") }
                    Button { } label: { CircleIcon(systemName: "pencil") }
                    Button { } label: { CircleIcon(systemName: "paperplane") }
                    Button { } label: { CircleIcon(systemName: "ellipsis") }
                }
            }
            .tint(Color.primary)
        }
    }
}
