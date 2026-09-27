import Foundation
import Combine

final class ChannelRepository: ObservableObject {
    static let shared = ChannelRepository()

    @Published var channels: [Zone66Channel] = []
    @Published var matches: [ZHMatch] = []
    @Published var favorites: Set<String> = []
    @Published var isSyncing: Bool = false
    @Published var lastSyncDate: Date?

    private let favoritesKey = "zh_team_favorites"
    private let channelsURL = URL(string: "https://raw.githubusercontent.com/husszzzz/Zone66-Player/main/Data/channels.json")!
    private let matchesURL = URL(string: "https://raw.githubusercontent.com/husszzzz/Zone66-Player/main/Data/matches.json")!

    var enabledChannels: [Zone66Channel] {
        channels.filter { ch in ch.isEnabled }
    }

    var favoriteChannels: [Zone66Channel] {
        channels.filter { ch in favorites.contains(ch.id) }
    }

    var categories: [String] {
        let set = Set(enabledChannels.map { ch in ch.category })
        return ["الكل"] + Array(set).sorted()
    }

    private init() {
        loadFavorites()
        loadLocalData()
        refresh()
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
            } else {
                DispatchQueue.main.async {
                    if self.matches.isEmpty {
                        self.matches = self.defaultMatches()
                    }
                }
            }
        }.resume()
    }

    private func defaultMatches() -> [ZHMatch] {
        return [
            ZHMatch(
                id: "m1",
                teamA: "ريال مدريد",
                teamB: "مانشستر سيتي",
                teamALogo: "👑",
                teamBLogo: "⚡",
                league: "دوري أبطال أوروبا",
                time: "10:00 م",
                score: "2 - 1",
                status: "مباشر",
                channelName: "beIN Sports 1 HD",
                streamURL: nil
            ),
            ZHMatch(
                id: "m2",
                teamA: "برشلونة",
                teamB: "بايرن ميونخ",
                teamALogo: "🔴🔵",
                teamBLogo: "🔴⚪",
                league: "دوري أبطال أوروبا",
                time: "10:00 م",
                score: "0 - 0",
                status: "مباشر",
                channelName: "beIN Sports 2 HD",
                streamURL: nil
            ),
            ZHMatch(
                id: "m3",
                teamA: "ليفربول",
                teamB: "أرسنال",
                teamALogo: "🔴",
                teamBLogo: "⚪🔴",
                league: "الدوري الإنجليزي الممتاز",
                time: "07:30 م",
                score: "vs",
                status: "قادمة",
                channelName: "beIN Sports 1 HD",
                streamURL: nil
            ),
            ZHMatch(
                id: "m4",
                teamA: "الهلال",
                teamB: "النصر",
                teamALogo: "🔵",
                teamBLogo: "🟡",
                league: "دوري روشن السعودي",
                time: "09:00 م",
                score: "vs",
                status: "قادمة",
                channelName: "SSC 1 HD",
                streamURL: nil
            )
        ]
    }

    func toggleFavorite(_ id: String) {
        if favorites.contains(id) {
            favorites.remove(id)
        } else {
            favorites.insert(id)
        }
        saveFavorites()
    }

    func isFavorite(_ id: String) -> Bool {
        favorites.contains(id)
    }

    private func loadFavorites() {
        if let array = UserDefaults.standard.stringArray(forKey: favoritesKey) {
            favorites = Set(array)
        }
    }

    private func saveFavorites() {
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
    }

    private func loadLocalData() {
        self.matches = defaultMatches()
        guard let url = Bundle.main.url(forResource: "ChannelsData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Zone66Channel].self, from: data) else {
            return
        }
        self.channels = list
    }
}
