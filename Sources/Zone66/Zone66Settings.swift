import SwiftUI

final class Zone66Settings: ObservableObject {
    static let shared = Zone66Settings()

    @Published var autoPlay: Bool {
        didSet { UserDefaults.standard.set(autoPlay, forKey: "zh_auto_play") }
    }
    @Published var fillVideo: Bool {
        didSet { UserDefaults.standard.set(fillVideo, forKey: "zh_fill_video") }
    }

    private init() {
        self.autoPlay = UserDefaults.standard.object(forKey: "zh_auto_play") as? Bool ?? true
        self.fillVideo = UserDefaults.standard.object(forKey: "zh_fill_video") as? Bool ?? false
    }
}
