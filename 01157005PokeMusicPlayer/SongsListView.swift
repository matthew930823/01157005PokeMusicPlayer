import SwiftUI
import AVFoundation
import MediaPlayer

struct SongsListView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel  // 用來接收 viewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.songTitles, id: \.self) { title in
                NavigationLink(destination: ContentView(viewModel: viewModel, songTitle: title)) {
                    Text(title)  // 顯示歌曲名稱
                        .font(.title2)
                        .padding()
                }
            }
            .navigationBarTitle("Songs List")
        }
    }
}


#Preview {
    @Previewable @StateObject var viewModel = MusicPlayerViewModel()
    SongsListView(viewModel: viewModel)
}
