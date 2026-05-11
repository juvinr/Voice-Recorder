import SwiftUI

struct RecordingControlsView: View {
    let isRecording: Bool
    let isPaused: Bool
    let elapsedTime: TimeInterval
    let waveformSamples: [Float]
    let onStartRecording: () -> Void
    let onTogglePause: () -> Void
    let onStopRecording: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            if isRecording {
                Button(action: onStopRecording) {
                    Image(systemName: "chevron.up")
                        .font(.title3)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 30, height: 30)
                                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
                        )
                }
                .tint(.primary)

                ActiveRecordingView(
                    isPaused: isPaused,
                    elapsedTime: elapsedTime,
                    waveformSamples: waveformSamples,
                    onTogglePause: onTogglePause,
                    onDone: onStopRecording
                )
            } else {
                Button(action: onStartRecording) {
                    HStack {
                        Spacer()
                        Image(systemName: "record.circle")
                            .font(.system(size: 30))
                        Spacer()
                    }
                    .frame(height: 60)
                }
                .tint(.primary)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.gray.opacity(0.15))
                )
                .padding(.horizontal)
            }
        }
        .padding()
    }
}
