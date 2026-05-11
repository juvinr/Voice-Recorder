import SwiftUI

struct FilterTabsView: View {
    @Binding var selectedFilter: FilterType

    var body: some View {
        HStack(spacing: 10) {
            ForEach(FilterType.allCases, id: \.self) { type in
                FilterChip(title: type.title, isSelected: selectedFilter == type) {
                    selectedFilter = type
                }
            }
        }
        .padding(.horizontal)
    }
}
