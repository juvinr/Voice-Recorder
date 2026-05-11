import SwiftUI

struct PlaybackControlsView: View {
    let isPlaying: Bool
    let progress: Double
    let elapsed: TimeInterval
    let duration: TimeInterval
    let onToggle: () -> Void
    let onSeek: (Double) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: onToggle) {
                HStack(spacing: 6) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    Text(isPlaying ? elapsed.mmss : duration.mmss)
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }

            if isPlaying {
                HStack(spacing: 8) {
                    Text(elapsed.mmss)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                    Slider(
                        value: Binding(get: { progress }, set: { onSeek($0) }),
                        in: 0...1
                    )
                    .tint(.blue)
                    Text(duration.mmss)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(duration: 0.2), value: isPlaying)
    }
}
