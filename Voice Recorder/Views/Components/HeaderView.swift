import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack {
            Text("Voice Recorder")
                .font(.largeTitle)
                .fontWeight(.bold)

            Spacer()

            HStack(spacing: 16) {
                Button { } label: { Image(systemName: "plus") }
                Button { } label: { Image(systemName: "calendar") }
                Button { } label: { Image(systemName: "gearshape") }
            }
            .tint(Color.primary)
            .font(.title3)
        }
        .padding(.horizontal)
    }
}
