//
//  CarPlayTemplateManager.swift
//  StreamCar - CarStream for Apple CarPlay
//

import Foundation
import CarPlay
import UIKit

class CarPlayTemplateManager: NSObject {
    private weak var interfaceController: CPInterfaceController?
    private var playbackEngine = PlaybackEngine.shared
    
    init(interfaceController: CPInterfaceController) {
        self.interfaceController = interfaceController
        super.init()
    }
    
    func setupRootTemplate() {
        let rootTabBar = CPTabBarTemplate(templates: [
            createWebVideoListTemplate(),
            createBookmarksTemplate(),
            createNowPlayingGridTemplate()
        ])
        
        interfaceController?.setRootTemplate(rootTabBar, animated: true, completion: nil)
    }
    
    // MARK: - Video & Stream Menu Template
    private func createWebVideoListTemplate() -> CPListTemplate {
        var items: [CPListItem] = []
        
        // Featured Video Streams / YouTube Bookmarks
        let featuredStreams = [
            ("YouTube Home & Search", "Browse YouTube videos & live streams", "play.tv.fill"),
            ("Lo-Fi Chill Beats Radio", "Live 24/7 Music Stream", "music.note.tv"),
            ("NASA TV Live Stream", "Official Space Exploration Channel", "globe"),
            ("Tech & News Highlights", "Top Daily Video Clips", "newspaper.fill")
        ]
        
        for (title, detail, iconName) in featuredStreams {
            let item = CPListItem(text: title, detailText: detail)
            if let image = UIImage(systemName: iconName) {
                item.setImage(image)
            }
            item.handler = { [weak self] item, completion in
                self?.handleVideoSelection(title: title)
                completion()
            }
            items.append(item)
        }
        
        let section = CPListSection(items: items, header: "StreamCar Stream Center", sectionIndexTitle: "Streams")
        let template = CPListTemplate(title: "Video Streams", sections: [section])
        if let tabIcon = UIImage(systemName: "tv.fill") {
            template.tabTitle = "Streams"
            template.tabImage = tabIcon
        }
        return template
    }
    
    // MARK: - Bookmarks Template
    private func createBookmarksTemplate() -> CPListTemplate {
        var items: [CPListItem] = []
        
        let bookmarks = [
            ("My Saved YouTube Playlists", "12 Playlists saved on phone", "folder.fill"),
            ("Custom RTSP/HLS Stream", "rtmp://live.streamcar.app/feed", "antenna.radiowaves.left.and.right"),
            ("CarStream Web Player", "Launch Web Video Engine", "safari.fill")
        ]
        
        for (title, detail, iconName) in bookmarks {
            let item = CPListItem(text: title, detailText: detail)
            if let image = UIImage(systemName: iconName) {
                item.setImage(image)
            }
            item.handler = { [weak self] item, completion in
                self?.handleVideoSelection(title: title)
                completion()
            }
            items.append(item)
        }
        
        let section = CPListSection(items: items)
        let template = CPListTemplate(title: "Bookmarks", sections: [section])
        if let tabIcon = UIImage(systemName: "star.fill") {
            template.tabTitle = "Bookmarks"
            template.tabImage = tabIcon
        }
        return template
    }
    
    // MARK: - Playback Controls Grid Template
    private func createNowPlayingGridTemplate() -> CPGridTemplate {
        let playPauseButton = CPGridButton(
            titleVariants: ["Play / Pause"],
            image: UIImage(systemName: "playpause.fill")!
        ) { [weak self] _ in
            self?.playbackEngine.togglePlayPause()
        }
        
        let nextButton = CPGridButton(
            titleVariants: ["Next Stream"],
            image: UIImage(systemName: "forward.fill")!
        ) { [weak self] _ in
            self?.playbackEngine.nextTrack()
        }
        
        let pipButton = CPGridButton(
            titleVariants: ["PIP Mode"],
            image: UIImage(systemName: "pip.enter")!
        ) { _ in
            NotificationCenter.default.post(name: .togglePIP, object: nil)
        }
        
        let externalDisplayButton = CPGridButton(
            titleVariants: ["Ext Display"],
            image: UIImage(systemName: "airplayvideo")!
        ) { _ in
            ExternalScreenManager.shared.toggleExternalScreenMode()
        }
        
        let grid = CPGridTemplate(title: "Controls", gridButtons: [playPauseButton, nextButton, pipButton, externalDisplayButton])
        if let tabIcon = UIImage(systemName: "slider.horizontal.3") {
            grid.tabTitle = "Controls"
            grid.tabImage = tabIcon
        }
        return grid
    }
    
    private func handleVideoSelection(title: String) {
        print("[StreamCar CarPlay] Selected: \(title)")
        // Trigger video streaming on Phone UI / Secondary Screen Engine
        NotificationCenter.default.post(name: .didSelectStream, object: title)
    }
}

extension Notification.Name {
    static let didSelectStream = Notification.Name("StreamCarDidSelectStream")
    static let togglePIP = Notification.Name("StreamCarTogglePIP")
}
