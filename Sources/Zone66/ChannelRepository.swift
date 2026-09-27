import Foundation
import Combine

final class ChannelRepository: ObservableObject {
    static let shared = ChannelRepository()

    @Published var channels: [Zone66Channel] = []
    @Published var matches: [ZHMatch] = []
    @Published var favorites: Set<String> = []
    @Published var recentChannelIDs: [String] = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?

    private let favoritesKey = "zh_team_favorites"
    private let recentsKey = "zh_team_recents"
    private let channelsURL = URL(string: "https://raw.githubusercontent.com/husszzzz/Zone66-Player/main/Data/channels.json")!
    private let matchesURL = URL(string: "https://raw.githubusercontent.com/husszzzz/Zone66-Player/main/Data/matches.json")!

    var enabledChannels: [Zone66Channel] {
        channels.filter { ch in ch.isEnabled }
    }

    var favoriteChannels: [Zone66Channel] {
        channels.filter { ch in favorites.contains(ch.id) }
    }

    var recentChannels: [Zone66Channel] {
        var list: [Zone66Channel] = []
        for id in recentChannelIDs {
            if let ch = channels.first(where: { $0.id == id && $0.isEnabled }) {
                list.append(ch)
            }
        }
        return list
    }

    var categories: [String] {
        let set = Set(enabledChannels.map { ch in ch.category })
        return ["الكل"] + Array(set).sorted()
    }

    private init() {
        loadFavorites()
        loadRecents()
        loadLocalData()
        refresh()
    }

    func recordWatched(_ channelID: String) {
        var updated = recentChannelIDs.filter { $0 != channelID }
        updated.insert(channelID, at: 0)
        if updated.count > 10 {
            updated = Array(updated.prefix(10))
        }
        recentChannelIDs = updated
        UserDefaults.standard.set(updated, forKey: recentsKey)
    }

    func toggleFavorite(_ id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }

    func isFavorite(_ id: String) -> Bool {
        favorites.contains(id)
    }

    private func loadFavorites() {
        if let array = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            favorites = Set(array)
        }
    }

    private func loadRecents() {
        if let array = UserDefaults.standard.stringArray(forKey: recentsKey) {
            recentChannelIDs = array
        }
    }

    func refresh() {
        guard !isSyncing else { return }
        isSyncing = true

        let group = DispatchGroup()

        group.enter()
        fetchRemoteChannels {
            group.leave()
        }

        group.enter()
        fetchRemoteMatches {
            group.leave()
        }

        group.notify(queue: .main) {
            self.isSyncing = false
            self.lastSyncDate = Date()
        }
    }

    private func fetchRemoteChannels(completion: @escaping () -> Void) {
        var request = URLRequest(url: channelsURL)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10

        URLSession.shared.dataTask(with: request) { data, _, _ in
            defer { completion() }
            guard let data = data,
                  let remote = try? JSONDecoder().decode([Zone66Channel].self, from: data),
                  !remote.isEmpty else { return }

            DispatchQueue.main.async {
                self.channels = remote
            }
        }.resume()
    }

    private func fetchRemoteMatches(completion: @escaping () -> Void) {
        var request = URLRequest(url: matchesURL)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 8

        URLSession.shared.dataTask(with: request) { data, _, _ in
            defer { completion() }
            if let data = data,
               let remote = try? JSONDecoder().decode([ZHMatch].self, from: data),
               !remote.isEmpty {
                DispatchQueue.main.async {
                    self.matches = remote
                }
            }
        }.resume()
    }

    private func loadLocalData() {
        guard let url = Bundle.main.url(forResource: "ChannelsData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Zone66Channel].self, from: data) else {
            return
        }
        self.channels = list
    }
}
