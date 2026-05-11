import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        ZStack(alignment: .trailing) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Search", text: $searchText)
                    .padding(.trailing, 90)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(20)

            Button {
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "brain.head.profile")
                    Text("Ask AI")
                        .fontWeight(.semibold)
                }
                .tint(Color.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            }
            .padding(.trailing, 6)
        }
        .padding(.horizontal)
    }
}
