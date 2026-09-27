import SwiftUI

final class Zone66Theme: ObservableObject {
    static let shared = Zone66Theme()

    // Neon lime green matching ZH TEAM branding
    @Published var accent: Color = Color(red: 0.61, green: 1.0, blue: 0.0) // #9CFF00
    let background = Color(red: 0.04, green: 0.04, blue: 0.05)
    let card = Color(red: 0.09, green: 0.10, blue: 0.11)
    let secondaryCard = Color(red: 0.14, green: 0.15, blue: 0.17)

    private init() {}

    func apply(hex: String) {
        accent = Color(red: 0.61, green: 1.0, blue: 0.0)
    }
}
