//
//  PhoneDashboardView.swift
//  StreamCar - CarStream for Apple CarPlay
//

import SwiftUI

struct PhoneDashboardView: View {
    @EnvironmentObject var playbackEngine: PlaybackEngine
    @EnvironmentObject var externalScreenManager: ExternalScreenManager
    
    @State private var selectedTab: Int = 0
    @State private var inputURL: String = "https://www.youtube.com"
    @State private var activeURL: String = "https://www.youtube.com"
    @State private var isPIPActive: Bool = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // TAB 1: Web Video Streamer
            VStack(spacing: 0) {
                // Header Bar & URL Bar
                HStack(spacing: 8) {
                    Image(systemName: "tv.badge.wifi.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    
                    TextField("Enter YouTube or Video Stream URL...", text: $inputURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    Button(action: {
                        activeURL = inputURL
                        playbackEngine.playStream(url: activeURL, title: "Custom Video Feed")
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                
                // Quick Bookmark Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        BookmarkChip(title: "YouTube", url: "https://www.youtube.com", icon: "play.rectangle.fill") { url in
                            inputURL = url
                            activeURL = url
                        }
                        BookmarkChip(title: "Twitch", url: "https://m.twitch.tv", icon: "gamecontroller.fill") { url in
                            inputURL = url
                            activeURL = url
                        }
                        BookmarkChip(title: "Lo-Fi Beats 24/7", url: "https://www.youtube.com/watch?v=jfKfPfyJRdk", icon: "music.note") { url in
                            inputURL = url
                            activeURL = url
                        }
                        BookmarkChip(title: "NASA Live", url: "https://www.youtube.com/watch?v=21X5lGlDOfg", icon: "globe") { url in
                            inputURL = url
                            activeURL = url
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(UIColor.tertiarySystemBackground))
                
                // Web Video Player
                WebVideoPlayerView(urlString: activeURL, isPIPEnabled: $isPIPActive)
            }
            .tabItem {
                Label("Streamer", systemImage: "play.tv.fill")
            }
            .tag(0)
            
            // TAB 2: CarPlay Control Center
            NavigationView {
                List {
                    Section(header: Text("CarPlay Status")) {
                        HStack {
                            Label("CarPlay Head Unit", systemImage: "car.fill")
                            Spacer()
                            Text("Connected")
                                .bold()
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Label("External Video Screen", systemImage: "display")
                            Spacer()
                            Text(externalScreenManager.isExternalScreenConnected ? "Active" : "Ready")
                                .foregroundColor(externalScreenManager.isExternalScreenConnected ? .green : .orange)
                        }
                        
                        HStack {
                            Label("Screen Resolution", systemImage: "aspectratio")
                            Spacer()
                            Text(externalScreenManager.externalScreenResolution)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Section(header: Text("Playback Controls")) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(playbackEngine.currentTitle)
                                    .font(.headline)
                                Text(playbackEngine.currentSubtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {
                                playbackEngine.togglePlayPause()
                            }) {
                                Image(systemName: playbackEngine.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Section(header: Text("CarPlay Video & Safety Overrides")) {
                        Toggle(isOn: .constant(true)) {
                            Label("Driving Video Override (Play Video While Driving)", systemImage: "play.tv.fill")
                        }
                        Toggle(isOn: .constant(true)) {
                            Label("Continuous External Display Rendering", systemImage: "display")
                        }
                        Toggle(isOn: .constant(true)) {
                            Label("Background Audio & Steering Wheel Controls", systemImage: "steeringwheel")
                        }
                    }
                }
                .navigationTitle("CarPlay Center")
            }
            .tabItem {
                Label("CarPlay", systemImage: "car.fill")
            }
            .tag(1)
            
            // TAB 3: Installation & Sideloading Guide
            NavigationView {
                List {
                    Section(header: Text("CarStream iOS Installation")) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("How to Install StreamCar on iOS")
                                .font(.headline)
                            Text("Unlike Android AAAD, iOS requires installing via AltStore, SideStore, TrollStore, or Xcode developer certificates due to Apple CarPlay security sandbox rules.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Section(header: Text("Installation Methods")) {
                        GuideRow(
                            step: "1",
                            title: "AltStore / SideStore (No Jailbreak)",
                            description: "Download the compiled StreamCar.ipa file and sideload using AltStore or SideStore with your Apple ID."
                        )
                        GuideRow(
                            step: "2",
                            title: "TrollStore (iOS 14.0 - 16.6.1)",
                            description: "Install directly without revokes via TrollStore for permanent unsandboxed CarPlay entitlements."
                        )
                        GuideRow(
                            step: "3",
                            title: "Xcode & Mac Developer Mode",
                            description: "Open the StreamCar.xcodeproj project in Xcode, attach your Apple ID developer team, and install directly to iPhone."
                        )
                    }
                    
                    Section(header: Text("CarPlay Entitlements")) {
                        Text("This project includes the 'com.apple.developer.carplay-maps' and 'com.apple.developer.carplay-audio' keys pre-configured in StreamCar.entitlements.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .navigationTitle("Sideload Guide")
            }
            .tabItem {
                Label("Installation", systemImage: "wrench.and.screwdriver.fill")
            }
            .tag(2)
        }
    }
}

struct BookmarkChip: View {
    let title: String
    let url: String
    let icon: String
    let onSelect: (String) -> Void
    
    var body: some View {
        Button(action: { onSelect(url) }) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .bold()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.15))
            .foregroundColor(.blue)
            .cornerRadius(16)
        }
    }
}

struct GuideRow: View {
    let step: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(step)
                .font(.headline)
                .bold()
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.red)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
