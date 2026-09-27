import Foundation
import SwiftUI

struct Zone66Channel: Identifiable, Codable, Equatable, Sendable {
    let id: String
    var name: String
    var category: String
    var url: String
    var iconURL: String
    var isFeatured: Bool
    var enabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case url
        case streamURL
        case icon
        case iconURL
        case featured
        case isFeatured
        case enabled
    }

    init(
        id: String = UUID().uuidString,
        name: String,
        category: String = "عام",
        url: String,
        iconURL: String = "",
        isFeatured: Bool = false,
        enabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.category = category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "عام" : category
        self.url = url
        self.iconURL = iconURL
        self.isFeatured = isFeatured
        self.enabled = enabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        self.name = (try? container.decode(String.self, forKey: .name)) ?? "قناة"

        let rawCategory = (try? container.decode(String.self, forKey: .category)) ?? "عام"
        self.category = rawCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "عام" : rawCategory

        // يدعم رابط البث سواء كان streamURL أو url
        if let stream = try? container.decode(String.self, forKey: .streamURL), !stream.isEmpty {
            self.url = stream
        } else if let standardUrl = try? container.decode(String.self, forKey: .url) {
            self.url = standardUrl
        } else {
            self.url = ""
        }

        // يدعم icon أو iconURL
        if let ic = try? container.decode(String.self, forKey: .icon), !ic.isEmpty {
            self.iconURL = ic
        } else if let icUrl = try? container.decode(String.self, forKey: .iconURL) {
            self.iconURL = icUrl
        } else {
            self.iconURL = ""
        }

        // يدعم featured أو isFeatured
        if let feat = try? container.decode(Bool.self, forKey: .featured) {
            self.isFeatured = feat
        } else if let isFeat = try? container.decode(Bool.self, forKey: .isFeatured) {
            self.isFeatured = isFeat
        } else {
            self.isFeatured = false
        }

        self.enabled = (try? container.decode(Bool.self, forKey: .enabled)) ?? true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(url, forKey: .url)
        try container.encode(url, forKey: .streamURL)
        try container.encode(iconURL, forKey: .iconURL)
        try container.encode(iconURL, forKey: .icon)
        try container.encode(isFeatured, forKey: .isFeatured)
        try container.encode(isFeatured, forKey: .featured)
        try container.encode(enabled, forKey: .enabled)
    }
}

struct Zone66RemoteSettings: Codable, Sendable {
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
