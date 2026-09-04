# StreamCar for iOS (CarStream for Apple CarPlay)

**StreamCar** is an open-source iOS application designed as the Apple CarPlay equivalent of Android Auto's CarStream (AAAD). It enables web video streaming (YouTube, custom web video streams, RTSP/HLS feeds) with background audio playback, CarPlay template head unit controls, PIP mode, and external vehicle display rendering.

---

## Technical Highlights

1. **Dual Scene Architecture**:
   - `UIWindowScene` for the main iPhone app view.
   - `CPTemplateApplicationSceneDelegate` for CarPlay head unit integration (`CPListTemplate`, `CPGridTemplate`, `CPNowPlayingTemplate`).

2. **Web Video Engine**:
   - `WKWebView` wrapper with custom JavaScript injection for media extraction, desktop user-agent switching, and inline playback.

3. **External Display Manager**:
   - Detects external screens via `UIScreen.didConnectNotification` and routes video output to CarPlay adapters, secondary vehicle screens, or AirPlay receivers.

4. **Background Audio & Steering Wheel Controls**:
   - Configures `AVAudioSession` with `.playback` category and handles `MPRemoteCommandCenter` play/pause/skip buttons from steering wheel hardware.

---

## How to Sideload & Install on iOS

Because Apple restricts video apps on CarPlay via standard App Store rules, StreamCar is distributed as source code / `.ipa` for sideloading:

### Option A: AltStore / SideStore (No Jailbreak Required)
1. Install **AltStore** or **SideStore** on your iPhone.
2. Build the app in Xcode or download the generated `StreamCar.ipa`.
3. Open AltStore -> **My Apps** -> **+** -> Select `StreamCar.ipa`.
4. Connect iPhone to vehicle via CarPlay (Wired or Wireless).

### Option B: TrollStore (iOS 14.0 - 16.6.1)
1. Open **TrollStore** on your jailbroken or TrollStore-enabled device.
2. Import `StreamCar.ipa` and press **Install**.
3. Launch StreamCar from CarPlay head unit menu.

### Option C: Xcode Developer Install
1. Open `StreamCar.xcodeproj` in Xcode on macOS.
2. Select your Apple ID as the Signing Team.
3. Connect iPhone via USB and click **Run (Cmd + R)**.

---

## License & Safety Notice
Designed for educational & parked vehicle entertainment use only. Obey local driving laws regarding video screens while operating a motor vehicle.
