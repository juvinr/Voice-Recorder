import SwiftUI

struct CircleIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .frame(width: 32, height: 32)
            .background(Color(.systemGray6))
            .clipShape(Circle())
    }
}
