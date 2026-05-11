import SwiftUI

struct LiveWaveformView: View {
    let samples: [Float]
    let barColor: Color

    private let barCount = 50
    private let spacing: CGFloat = 2

    var body: some View {
        let padded: [Float] = {
            if samples.count < barCount {
                return Array(repeating: Float(0.05), count: barCount - samples.count) + samples
            }
            return Array(samples.suffix(barCount))
        }()

        GeometryReader { geo in
            let barWidth = (geo.size.width - spacing * CGFloat(barCount - 1)) / CGFloat(barCount)
            HStack(alignment: .center, spacing: spacing) {
                ForEach(0..<barCount, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(barColor)
                        .frame(
                            width: barWidth,
                            height: max(3, geo.size.height * CGFloat(padded[i]))
                        )
                        .animation(.linear(duration: 0.05), value: padded[i])
                }
            }
        }
    }
}

#Preview {
    LiveWaveformView(
        samples: (0..<50).map { _ in Float.random(in: 0.1...0.9) },
        barColor: .blue.opacity(0.7)
    )
    .frame(height: 60)
    .padding()
}
