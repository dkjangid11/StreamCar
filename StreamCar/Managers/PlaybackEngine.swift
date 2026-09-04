//
//  PlaybackEngine.swift
//  StreamCar - CarStream for Apple CarPlay
//

import Foundation
import AVFoundation
import MediaPlayer
import Combine

class PlaybackEngine: ObservableObject {
    static let shared = PlaybackEngine()
    
    @Published var isPlaying: Bool = false
    @Published var currentTitle: String = "StreamCar Radio"
    @Published var currentSubtitle: String = "YouTube Web Video Stream"
    @Published var videoURLString: String = "https://www.youtube.com"
    @Published var playbackProgress: Double = 0.0
    
    private var avPlayer: AVPlayer?
    
    private init() {}
    
    func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .moviePlayback, options: [.allowBluetoothHFP, .allowBluetoothA2DP, .mixWithOthers])
            try session.setActive(true)
            setupRemoteCommandCenter()
            print("[StreamCar Engine] AVAudioSession configured successfully.")
        } catch {
            print("[StreamCar Engine] Failed to set up AVAudioSession: \(error)")
        }
    }
    
    func playStream(url: String, title: String) {
        self.videoURLString = url
        self.currentTitle = title
        self.isPlaying = true
        
        if let videoURL = URL(string: url) {
            let playerItem = AVPlayerItem(url: videoURL)
            if avPlayer == nil {
                avPlayer = AVPlayer(playerItem: playerItem)
            } else {
                avPlayer?.replaceCurrentItem(with: playerItem)
            }
            avPlayer?.play()
        }
        
        updateNowPlayingInfo()
    }
    
    func togglePlayPause() {
        isPlaying.toggle()
        if isPlaying {
            avPlayer?.play()
        } else {
            avPlayer?.pause()
        }
        updateNowPlayingInfo()
    }
    
    func nextTrack() {
        print("[StreamCar Engine] Skip next stream requested.")
        // Trigger next stream in queue
        NotificationCenter.default.post(name: .didSelectStream, object: "Next Stream")
    }
    
    func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = currentTitle
        nowPlayingInfo[MPMediaItemPropertyArtist] = currentSubtitle
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.isPlaying = true
            self?.avPlayer?.play()
            self?.updateNowPlayingInfo()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.isPlaying = false
            self?.avPlayer?.pause()
            self?.updateNowPlayingInfo()
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            self?.nextTrack()
            return .success
        }
    }
}
