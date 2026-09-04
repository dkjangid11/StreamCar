//
//  ExternalScreenManager.swift
//  StreamCar - CarStream for Apple CarPlay
//

import UIKit
import SwiftUI
import Combine

class ExternalScreenManager: ObservableObject {
    static let shared = ExternalScreenManager()
    
    @Published var isExternalScreenConnected: Bool = false
    @Published var externalScreenResolution: String = "No External Display"
    
    private var externalWindow: UIWindow?
    
    private init() {}
    
    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidConnect(_:)),
            name: UIScreen.didConnectNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenDidDisconnect(_:)),
            name: UIScreen.didDisconnectNotification,
            object: nil
        )
        
        // Check existing screens
        checkForExistingExternalScreen()
    }
    
    @objc private func screenDidConnect(_ notification: Notification) {
        guard let newScreen = notification.object as? UIScreen else { return }
        print("[StreamCar ExternalScreen] Connected to external display: \(newScreen.bounds)")
        setupExternalWindow(for: newScreen)
    }
    
    @objc private func screenDidDisconnect(_ notification: Notification) {
        print("[StreamCar ExternalScreen] Disconnected from external display.")
        externalWindow = nil
        isExternalScreenConnected = false
        externalScreenResolution = "No External Display"
    }
    
    private func checkForExistingExternalScreen() {
        if UIScreen.screens.count > 1 {
            let externalScreen = UIScreen.screens[1]
            setupExternalWindow(for: externalScreen)
        }
    }
    
    private func setupExternalWindow(for screen: UIScreen) {
        externalWindow = UIWindow(frame: screen.bounds)
        externalWindow?.screen = screen
        
        // Render Secondary Screen Video View on External CarPlay / AirPlay Display
        let externalViewController = UIHostingController(
            rootView: ExternalVideoDisplayView()
                .environmentObject(PlaybackEngine.shared)
        )
        
        externalWindow?.rootViewController = externalViewController
        externalWindow?.isHidden = false
        
        isExternalScreenConnected = true
        externalScreenResolution = "\(Int(screen.bounds.width)) x \(Int(screen.bounds.height))"
    }
    
    func toggleExternalScreenMode() {
        print("[StreamCar ExternalScreen] Manual screen toggle triggered.")
    }
}

struct ExternalVideoDisplayView: View {
    @EnvironmentObject var playbackEngine: PlaybackEngine
    @State private var isPIPActive: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Continuous Live Web Video Stream View (Unlocked for Driving & Parked Modes)
            WebVideoPlayerView(
                urlString: playbackEngine.videoURLString,
                isPIPEnabled: $isPIPActive
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}
