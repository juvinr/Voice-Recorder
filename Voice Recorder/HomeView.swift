import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(alignment: .leading, spacing: 16) {
            HeaderView()
            SearchBarView(searchText: $viewModel.searchText)
            FilterTabsView(selectedFilter: $viewModel.selectedFilter)
            RecordingListView(
                recordings: viewModel.filteredRecordings,
                isPlaying: viewModel.isPlaying,
                playbackProgress: viewModel.playbackProgress,
                playbackElapsed: viewModel.playbackElapsed,
                onTogglePlayback: { viewModel.togglePlayback(for: $0) },
                onSeek: { viewModel.seek($0, to: $1) }
            )
            RecordingControlsView(
                isRecording: viewModel.isRecording,
                isPaused: viewModel.isPaused,
                elapsedTime: viewModel.recordingElapsed,
                waveformSamples: viewModel.waveformSamples,
                onStartRecording: viewModel.startRecording,
                onTogglePause: viewModel.togglePause,
                onStopRecording: viewModel.stopRecording
            )
        }
        .padding(.top)
        .onAppear { viewModel.onAppear() }
        .alert("Microphone Access Required", isPresented: $viewModel.showPermissionAlert) {
            Button("Cancel", role: .cancel) {}
            #if canImport(UIKit)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            #endif
        } message: {
            Text("Please enable microphone access in Settings to record audio.")
        }
    }
}

#Preview {
    HomeView()
}
