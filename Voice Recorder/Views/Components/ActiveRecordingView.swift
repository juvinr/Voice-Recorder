import SwiftUI

struct ActiveRecordingView: View {
    let isPaused: Bool
    let elapsedTime: TimeInterval
    let waveformSamples: [Float]
    let onTogglePause: () -> Void
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onTogglePause) {
                ZStack {
                    LiveWaveformView(
                        samples: waveformSamples,
                        barColor: .blue.opacity(0.6)
                    )
                    .frame(height: 60)

                    HStack(spacing: 14) {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.title3)
                        Text(elapsedTime.mmss)
                            .font(.title3)
                            .monospacedDigit()
                    }
                    .foregroundStyle(.black)
                }
                .frame(height: 60)
            }
            .background(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(Color.gray.opacity(0.15))
            )
            .clipShape(RoundedRectangle(cornerRadius: 30))

            Button(action: onDone) {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark")
                    Text("Done")
                }
                .font(.title3)
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color.green.opacity(0.18))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 10, y: 4)
        )
        .padding(.horizontal)
    }
}
