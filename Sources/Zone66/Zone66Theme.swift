import SwiftUI

final class Zone66Theme: ObservableObject {
    static let shared = Zone66Theme()

    @Published var accent: Color = Color(red: 1.0, green: 0.18, blue: 0.27)
    let background = Color(red: 0.025, green: 0.027, blue: 0.035)
    let card = Color(red: 0.075, green: 0.078, blue: 0.095)

    private init() {}

    func apply(hex: String) {
        accent = Color(zone66Hex: hex)
    }
}
