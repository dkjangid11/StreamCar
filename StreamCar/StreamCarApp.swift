//
//  StreamCarApp.swift
//  StreamCar - CarStream for Apple CarPlay
//

import SwiftUI
import CarPlay

@main
struct StreamCarApp: App {
    @StateObject private var playbackEngine = PlaybackEngine.shared
    @StateObject private var externalScreenManager = ExternalScreenManager.shared

    var body: some Scene {
        // Main Phone Interface Scene
        WindowGroup {
            PhoneDashboardView()
                .environmentObject(playbackEngine)
                .environmentObject(externalScreenManager)
                .onAppear {
                    playbackEngine.setupAudioSession()
                    externalScreenManager.startObserving()
                }
        }
    }
}
