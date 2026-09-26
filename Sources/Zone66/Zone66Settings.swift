import SwiftUI

final class Zone66Settings: ObservableObject {
    static let shared = Zone66Settings()

    @AppStorage("zone66_auto_play") var autoPlay: Bool = true
    @AppStorage("zone66_fill_video") var fillVideo: Bool = false
    @AppStorage("zone66_watermark") var watermarkEnabled: Bool = true
    @AppStorage("zone66_watermark_text") var watermarkText: String = "Zone66 TV"

    private init() {}
}
