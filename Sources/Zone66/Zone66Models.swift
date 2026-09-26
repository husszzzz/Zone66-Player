import Foundation
import SwiftUI

struct Zone66Channel: Identifiable, Codable, Equatable {
    let id: String
    var name: String
    var category: String
    var url: String
    var iconURL: String
    var isFeatured: Bool
    var enabled: Bool

    init(
        id: String = UUID().uuidString,
        name: String,
        category: String,
        url: String,
        iconURL: String = "",
        isFeatured: Bool = false,
        enabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.url = url
        self.iconURL = iconURL
        self.isFeatured = isFeatured
        self.enabled = enabled
    }
}

struct Zone66RemoteSettings: Codable {
    var appName: String = "Zone66 TV"
    var heroTitle: String = "تجربة مشاهدة احترافية"
    var heroSubtitle: String = "قنواتك المفضلة في مكان واحد"
    var heroButtonTitle: String = "مشاهدة القنوات"
    var supportTitle: String = "قناة التحديثات"
    var supportURL: String = ""
    var accentHex: String = "#FF3045"
}

extension Color {
    init(zone66Hex: String) {
        let hex = zone66Hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)

        let r = Double((value >> 16) & 0xFF) / 255.0
        let g = Double((value >> 8) & 0xFF) / 255.0
        let b = Double(value & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
