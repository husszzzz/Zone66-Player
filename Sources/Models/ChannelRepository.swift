import Foundation

class ChannelRepository {
    static let shared = ChannelRepository()
    private(set) var channels: [Channel] = []
    private(set) var categories: [String] = []
    private let favoritesKey = "Zone66_Favorite_IDs"

    private init() {
        loadChannels()
    }

    private func loadChannels() {
        guard let url = Bundle.main.url(forResource: "ChannelsData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Channel].self, from: data) else {
            return
        }
        self.channels = list
        var cats = Set<String>()
        list.forEach { cats.insert($0.category) }
        self.categories = ["الكل"] + Array(cats).sorted()
    }

    func getFavorites() -> [Channel] {
        let favIDs = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        return channels.filter { favIDs.contains($0.id) }
    }

    func isFavorite(channel: Channel) -> Bool {
        let favIDs = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        return favIDs.contains(channel.id)
    }

    func toggleFavorite(channel: Channel) {
        var favIDs = UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
        if let idx = favIDs.firstIndex(of: channel.id) {
            favIDs.remove(at: idx)
        } else {
            favIDs.append(channel.id)
        }
        UserDefaults.standard.set(favIDs, forKey: favoritesKey)
    }
}
