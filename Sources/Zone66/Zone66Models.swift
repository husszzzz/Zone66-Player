import Foundation

struct Zone66Channel: Identifiable, Codable {
    let id: String
    let name: String
    let category: String
    let streamURL: String
    let iconURL: String?
    let isFeatured: Bool
    let isEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case title
        case category
        case streamURL
        case url
        case iconURL
        case icon
        case logo
        case isFeatured
        case featured
        case isEnabled
        case enabled
    }

    init(id: String, name: String, category: String, streamURL: String, iconURL: String? = nil, isFeatured: Bool = false, isEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.category = category
        self.streamURL = streamURL
        self.iconURL = iconURL
        self.isFeatured = isFeatured
        self.isEnabled = isEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedName = (try? container.decode(String.self, forKey: .name))
            ?? (try? container.decode(String.self, forKey: .title))
            ?? "قناة بدون اسم"
        name = decodedName

        id = (try? container.decode(String.self, forKey: .id)) ?? decodedName

        category = (try? container.decode(String.self, forKey: .category)) ?? "أخرى"

        let rawURL = (try? container.decode(String.self, forKey: .streamURL))
            ?? (try? container.decode(String.self, forKey: .url))
            ?? ""
        streamURL = rawURL

        iconURL = (try? container.decode(String.self, forKey: .iconURL))
            ?? (try? container.decode(String.self, forKey: .icon))
            ?? (try? container.decode(String.self, forKey: .logo))

        isFeatured = (try? container.decode(Bool.self, forKey: .isFeatured))
            ?? (try? container.decode(Bool.self, forKey: .featured))
            ?? false

        isEnabled = (try? container.decode(Bool.self, forKey: .isEnabled))
            ?? (try? container.decode(Bool.self, forKey: .enabled))
            ?? true
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(streamURL, forKey: .streamURL)
        try container.encode(iconURL, forKey: .iconURL)
        try container.encode(isFeatured, forKey: .isFeatured)
        try container.encode(isEnabled, forKey: .isEnabled)
    }
}

struct ZHMatch: Identifiable, Codable {
    let id: String
    let teamA: String
    let teamB: String
    let teamALogo: String
    let teamBLogo: String
    let league: String
    let time: String
    let score: String
    let status: String // مباشر, قادمة, انتهت
    let channelName: String
    let streamURL: String?

    var isLive: Bool {
        status == "مباشر" || status.contains("جارية")
    }
}
