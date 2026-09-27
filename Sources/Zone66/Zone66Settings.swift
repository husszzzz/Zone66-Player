import SwiftUI

final class Zone66Settings: ObservableObject {
    static let shared = Zone66Settings()

    @Published var autoPlay: Bool {
        didSet { UserDefaults.standard.set(autoPlay, forKey: "zh_auto_play") }
    }
    @Published var fillVideo: Bool {
        didSet { UserDefaults.standard.set(fillVideo, forKey: "zh_fill_video") }
    }
    @Published var hardwareAcceleration: Bool {
        didSet { UserDefaults.standard.set(hardwareAcceleration, forKey: "zh_hw_accel") }
    }
    @Published var lowLatencyMode: Bool {
        didSet { UserDefaults.standard.set(lowLatencyMode, forKey: "zh_low_latency") }
    }
    @Published var autoReconnect: Bool {
        didSet { UserDefaults.standard.set(autoReconnect, forKey: "zh_auto_reconnect") }
    }

    private init() {
        self.autoPlay = UserDefaults.standard.object(forKey: "zh_auto_play") as? Bool ?? true
        self.fillVideo = UserDefaults.standard.object(forKey: "zh_fill_video") as? Bool ?? false
        self.hardwareAcceleration = UserDefaults.standard.object(forKey: "zh_hw_accel") as? Bool ?? true
        self.lowLatencyMode = UserDefaults.standard.object(forKey: "zh_low_latency") as? Bool ?? true
        self.autoReconnect = UserDefaults.standard.object(forKey: "zh_auto_reconnect") as? Bool ?? true
    }
}
