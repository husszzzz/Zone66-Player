import SwiftUI

final class Zone66Settings: ObservableObject {
    static let shared = Zone66Settings()

    @AppStorage("zone66_auto_play") var autoPlay: Bool = true
    @AppStorage("zone66_fill_video") var fillVideo: Bool = false

    private init() {}
}
