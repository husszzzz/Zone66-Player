import Foundation

public struct Channel: Identifiable, Codable, Equatable {
    public let id: String
    public var name: String
    public var url: String
    public var category: String
    public var isCustom: Bool
    public var icon: String?
    public var enabled: Bool
    public var featured: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case url
        case streamURL
        case category
        case isCustom
        case icon
        case enabled
        case featured
    }

    public init(id: String = UUID().uuidString, name: String, url: String, category: String, isCustom: Bool = false, icon: String? = nil, enabled: Bool = true, featured: Bool = false) {
        self.id = id
        self.name = name
        self.url = url
        self.category = category
        self.isCustom = isCustom
        self.icon = icon
        self.enabled = enabled
        self.featured = featured
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "قناة"
        
        // Support BOTH streamURL (from coomCraft dashboard) and url
        if let sUrl = try container.decodeIfPresent(String.self, forKey: .streamURL), !sUrl.isEmpty {
            self.url = sUrl
        } else if let u = try container.decodeIfPresent(String.self, forKey: .url), !u.isEmpty {
            self.url = u
        } else {
            self.url = ""
        }

        self.category = try container.decodeIfPresent(String.self, forKey: .category) ?? "عام"
        self.isCustom = try container.decodeIfPresent(Bool.self, forKey: .isCustom) ?? false
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.enabled = try container.decodeIfPresent(Bool.self, forKey: .enabled) ?? true
        self.featured = try container.decodeIfPresent(Bool.self, forKey: .featured) ?? false
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(url, forKey: .url)
        try container.encode(url, forKey: .streamURL)
        try container.encode(category, forKey: .category)
        try container.encode(isCustom, forKey: .isCustom)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(featured, forKey: .featured)
    }
}
