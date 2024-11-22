//
//  ContentView.swift
//  01157005PokeMusicPlayer
//
//  Created by user11 on 2024/11/11.
//

import SwiftUI
import AVFoundation
import MediaPlayer

struct ContentView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    var songTitle: String
    
    init(viewModel: MusicPlayerViewModel, songTitle: String) {
        self.viewModel = viewModel
        self.songTitle = songTitle
    }
    
    var body: some View {
        VStack {
            Image(viewModel.currentSongTitle + "pic")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            // 顯示歌名
            Text(viewModel.currentSongTitle)
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding()
            
            // 顯示當前時間和總時長
            HStack {
                Text(viewModel.currentTime)
                    .font(.body)
                    .padding(.leading)
                
                Spacer()
                
                Text(viewModel.duration)
                    .font(.body)
                    .padding(.trailing)
            }
            
            // 播放進度條
            Slider(value: $viewModel.sliderValue, in: 0...CMTimeGetSeconds(viewModel.player.currentItem?.asset.duration ?? CMTime())) { _ in
                viewModel.seekToTime(viewModel.sliderValue)
            }
            .padding(.horizontal)
            
            // 顯示歌詞
            ScrollView {
                Text(viewModel.lyrics)
                    .font(.body)
                    .padding()
            }
            
            Spacer()
            
            HStack {
                // 上一首
                Button(action: {
                    viewModel.playPreviousSong()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.largeTitle)
                }
                .padding(.horizontal)
                
                // 播放/暫停
                Button(action: {
                    viewModel.playPause()
                }) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.largeTitle)
                }
                .padding(.horizontal)
                
                // 下一首
                Button(action: {
                    viewModel.playNextSong()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.largeTitle)
                }
                .padding(.horizontal)
            }
            
            // 隨機播放
            Button(action: {
                viewModel.shufflePlay()
            }) {
                Image(systemName: "shuffle")
                    .font(.largeTitle)
            }
            
            // 音量控制
            HStack {
                Text("Volume")
                Slider(value: $viewModel.volume, in: 0...1, onEditingChanged: { _ in
                    viewModel.setVolume(to: viewModel.volume)
                })
                .padding(.horizontal)
            }
        }
        .onAppear {
            // 這裡我們使用傳遞進來的歌曲標題來初始化播放器
            viewModel.playSong(with: songTitle)
            
        }
        .padding()
    }
}

struct SongLyrics: Codable {
    var title: String
    var lyrics: String
}
class MusicPlayerViewModel: ObservableObject {
    public var player: AVPlayer!
    private var playerItems: [AVPlayerItem] = []
    private var currentIndex = 0
    
    @Published var isPlaying = false
    @Published var currentSongTitle = "No Song"
    @Published var volume: Float = 0.5
    @Published var lyrics: String = ""
    @Published var sliderValue: Double = 0.0  // 播放進度
    @Published var currentTime: String = "00:00"  // 當前播放時間
    @Published var duration: String = "00:00"  // 歌曲總時長
    private var songLyrics: [String: String] = [:]  // 用來存儲歌詞的字典
    @Published var songTitles: [String] = [
        "《冒険の道を踏み出して》",
        "宝可梦・成都の冒険",
        "永遠の冒険 ",
        "神奧の伝説",
        "洗翠の風",
        "合眾の地平線",
        "冒険の光"
    ]
    
    init() {
        loadLyrics()
        setupPlayer()
        configureAudioSession()
        setupRemoteCommandCenter()
    }
    
    // 設置播放器
    func setupPlayer() {
        let songURLs = [
            Bundle.main.url(forResource: "《冒険の道を踏み出して》", withExtension: "mp3")!,
            Bundle.main.url(forResource: "宝可梦・成都の冒険", withExtension: "mp3")!,
            Bundle.main.url(forResource: "永遠の冒険 ", withExtension: "mp3")!,
            Bundle.main.url(forResource: "神奧の伝説", withExtension: "mp3")!,
            Bundle.main.url(forResource: "洗翠の風", withExtension: "mp3")!,
            Bundle.main.url(forResource: "合眾の地平線", withExtension: "mp3")!,
            Bundle.main.url(forResource: "冒険の光", withExtension: "mp3")!
        ]
        
        playerItems = songURLs.map { AVPlayerItem(url: $0) }
        player = AVPlayer(playerItem: playerItems[currentIndex])
        player.volume = volume
        updateNowPlayingInfo()
        startTimer()
    }
    
    // 設置計時器來更新播放時間
    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateCurrentTime()
        }
    }
    
    // 更新當前播放時間
    func updateCurrentTime() {
        guard let currentItem = player.currentItem else { return }
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        sliderValue = currentTimeSeconds
        
        let currentTimeFormatted = formatTime(seconds: currentTimeSeconds)
        currentTime = currentTimeFormatted
        
        let durationSeconds = CMTimeGetSeconds(currentItem.asset.duration)
        if durationSeconds > 0 {
            let durationFormatted = formatTime(seconds: durationSeconds)
            duration = durationFormatted
        }
    }
    
    // 格式化時間
    func formatTime(seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 用於調整播放進度
    func seekToTime(_ time: Double) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 1)
        player.seek(to: targetTime)
    }
    
    // 加載歌詞
    func loadLyrics() {
        // 從資源中加載 JSON 文件
        if let url = Bundle.main.url(forResource: "lyrics", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            // 使用 JSONDecoder 解析 JSON 數據
            let decoder = JSONDecoder()
            if let lyricsData = try? decoder.decode([String: SongLyrics].self, from: data) {
                // 將 JSON 數據存入字典
                for (key, song) in lyricsData {
                    songLyrics[key] = song.lyrics
                }
            } else {
                print("Failed to decode lyrics JSON.")
            }
        } else {
            print("Failed to load lyrics JSON file.")
        }
    }
    
    // 播放指定歌曲
    func playSong(with title: String) {
        if let index = songTitles.firstIndex(of: title) {
            currentIndex = index
            player.replaceCurrentItem(with: playerItems[currentIndex])
            player.play()
            currentSongTitle = title
            isPlaying = true
        }
    }
    
    // 播放/暫停
    func playPause() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
    
    // 播放下一首歌曲
    func playNextSong() {
        currentIndex = (currentIndex + 1) % playerItems.count
        player.replaceCurrentItem(with: playerItems[currentIndex])
        player.play()
        player.seek(to: CMTime.zero)
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    // 播放上一首歌曲
    func playPreviousSong() {
        currentIndex = (currentIndex - 1 + playerItems.count) % playerItems.count
        player.replaceCurrentItem(with: playerItems[currentIndex])
        player.play()
        player.seek(to: CMTime.zero)
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    // 設置音量
    func setVolume(to value: Float) {
        player.volume = value
        volume = value
    }
    
    // 隨機播放
    func shufflePlay() {
        var randomIndex: Int
        repeat {
            randomIndex = Int.random(in: 0..<playerItems.count)
        } while randomIndex == currentIndex
        currentIndex = randomIndex
        let songTitle = getSongTitle(at: currentIndex)
        player.replaceCurrentItem(with: playerItems[currentIndex])
        player.seek(to: CMTime.zero)
        player.play()
        isPlaying = true
        updateNowPlayingInfo()
    }
    
    // 獲取指定索引的歌曲名稱
    func getSongTitle(at index: Int) -> String {
        let songTitles = [
            "《冒険の道を踏み出して》",
            "宝可梦・成都の冒険",
            "永遠の冒険 ",
            "神奧の伝説",
            "洗翠の風",
            "合眾の地平線",
            "冒険の光"
        ]
        return songTitles[index]
    }
    
    // 配置音頻會話
    func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            print("hello")
        } catch {
            print("Failed to configure audio session: \(error)")
        }       
    }
    
    // 設置遠程控制命令
    func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.playPause()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.playPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] event in
            self?.playNextSong()
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] event in
            self?.playPreviousSong()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seekToTime(event.positionTime)
            return .success
        }
        
        // 更新 NowPlayingInfo
        updateNowPlayingInfo()
    }
    
    // 更新 NowPlaying 信息
    func updateNowPlayingInfo() {
        guard let currentItem = player.currentItem else { return }
        let songTitle = currentItem.asset as! AVURLAsset
        let fileName = songTitle.url.lastPathComponent
        
        var nowPlayingInfo: [String: Any] = [
            MPMediaItemPropertyTitle: currentSongTitle,
            MPMediaItemPropertyArtist: "Pokemon Soundtrack",
            MPMediaItemPropertyAlbumTitle: "Pokemon Adventure",
            MPMediaItemPropertyPlaybackDuration: CMTimeGetSeconds(currentItem.asset.duration),
            MPNowPlayingInfoPropertyElapsedPlaybackTime: CMTimeGetSeconds(player.currentTime())
        ]
        let fileNameWithoutExtension = fileName.replacingOccurrences(of: ".mp3", with: "")
        lyrics = songLyrics[fileNameWithoutExtension] ?? "No lyrics available"
        currentSongTitle = fileNameWithoutExtension
        if let artwork = UIImage(named: fileName+"pic") {
            let artworkImage = MPMediaItemArtwork(boundsSize: artwork.size) { size in
                return artwork
            }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = artworkImage
        }
        print(nowPlayingInfo)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
}
