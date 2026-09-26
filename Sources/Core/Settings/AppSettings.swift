import SwiftUI

public final class AppSettings: ObservableObject {
    public static let shared = AppSettings()

    @AppStorage("watermark_enabled") public var watermarkEnabled: Bool = true
    @AppStorage("watermark_title") public var watermarkTitle: String = "Zh Team"
    @AppStorage("video_aspect_mode") public var videoAspectMode: String = "fit"
    @AppStorage("auto_play_enabled") public var autoPlay: Bool = true

    private init() {}
}
