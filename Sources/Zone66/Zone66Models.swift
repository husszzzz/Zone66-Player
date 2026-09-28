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
        case id, name, title, category, streamURL, url, iconURL, icon, logo, isFeatured, featured, isEnabled, enabled
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
        streamURL = (try? container.decode(String.self, forKey: .streamURL))
            ?? (try? container.decode(String.self, forKey: .url))
            ?? ""
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
    let team1: String
    let team2: String
    let team1Logo: String
    let team2Logo: String
    let time: String
    let date: String
    let details: String
    let status: String // "live", "upcoming", "finished"
    let score: String
    let channelId: String?
    let channelName: String?
    let streamURL: String?

    enum CodingKeys: String, CodingKey {
        case id
        case team1, teamA
        case team2, teamB
        case team1Logo, teamALogo
        case team2Logo, teamBLogo
        case time
        case date
        case details, league
        case status
        case score
        case channelId
        case channelName
        case streamURL, url
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        team1 = (try? container.decode(String.self, forKey: .team1))
            ?? (try? container.decode(String.self, forKey: .teamA))
            ?? "فريق 1"
        team2 = (try? container.decode(String.self, forKey: .team2))
            ?? (try? container.decode(String.self, forKey: .teamB))
            ?? "فريق 2"
        team1Logo = (try? container.decode(String.self, forKey: .team1Logo))
            ?? (try? container.decode(String.self, forKey: .teamALogo))
            ?? "⚽"
        team2Logo = (try? container.decode(String.self, forKey: .team2Logo))
            ?? (try? container.decode(String.self, forKey: .teamBLogo))
            ?? "⚡"
        time = (try? container.decode(String.self, forKey: .time)) ?? "00:00"
        date = (try? container.decode(String.self, forKey: .date)) ?? ""
        details = (try? container.decode(String.self, forKey: .details))
            ?? (try? container.decode(String.self, forKey: .league))
            ?? "مباراة اليوم"
        status = (try? container.decode(String.self, forKey: .status)) ?? "upcoming"
        score = (try? container.decode(String.self, forKey: .score)) ?? "vs"
        channelId = try? container.decode(String.self, forKey: .channelId)
        channelName = try? container.decode(String.self, forKey: .channelName)
        streamURL = (try? container.decode(String.self, forKey: .streamURL))
            ?? (try? container.decode(String.self, forKey: .url))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(team1, forKey: .team1)
        try container.encode(team2, forKey: .team2)
        try container.encode(team1Logo, forKey: .team1Logo)
        try container.encode(team2Logo, forKey: .team2Logo)
        try container.encode(time, forKey: .time)
        try container.encode(date, forKey: .date)
        try container.encode(details, forKey: .details)
        try container.encode(status, forKey: .status)
        try container.encode(score, forKey: .score)
        try container.encodeIfPresent(channelId, forKey: .channelId)
        try container.encodeIfPresent(channelName, forKey: .channelName)
        try container.encodeIfPresent(streamURL, forKey: .streamURL)
    }

    var isLive: Bool {
        let s = status.lowercased()
        return s == "live" || s == "مباشر" || s.contains("جارية")
    }

    var isUpcoming: Bool {
        let s = status.lowercased()
        return s == "upcoming" || s == "قادمة" || s == "قريبا"
    }

    var isFinished: Bool {
        let s = status.lowercased()
        return s == "finished" || s == "انتهت"
    }
}
