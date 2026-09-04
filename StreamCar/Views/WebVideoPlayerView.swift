//
//  WebVideoPlayerView.swift
//  StreamCar - CarStream for Apple CarPlay
//

import SwiftUI
import WebKit
import AVKit

struct WebVideoPlayerView: UIViewRepresentable {
    let urlString: String
    @Binding var isPIPEnabled: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        configuration.allowsPictureInPictureMediaPlayback = true
        
        // Inject Custom Ad-Blocker & Fullscreen Video Hooks JavaScript
        let scriptSource = """
        // Auto-enable inline playback and remove popups
        var style = document.createElement('style');
        style.innerHTML = '.ytp-ad-overlay-container, .ytp-ad-text-overlay { display: none !important; }';
        document.head.appendChild(style);
        """
        let userScript = WKUserScript(source: scriptSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        configuration.userContentController.addUserScript(userScript)
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Desktop User-Agent for full desktop web video player support
        webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15"
        
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let currentURL = webView.url?.absoluteString, currentURL != urlString {
            if let url = URL(string: urlString) {
                webView.load(URLRequest(url: url))
            }
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebVideoPlayerView
        
        init(_ parent: WebVideoPlayerView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("[StreamCar WebView] Page finished loading: \(webView.url?.absoluteString ?? "")")
            
            // Extract Video Metadata for CarPlay Now Playing
            webView.evaluateJavaScript("document.title") { result, _ in
                if let title = result as? String {
                    DispatchQueue.main.async {
                        PlaybackEngine.shared.currentTitle = title
                        PlaybackEngine.shared.updateNowPlayingInfo()
                    }
                }
            }
        }
    }
}
