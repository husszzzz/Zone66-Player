import Foundation
import SwiftUI

final class ChannelRepository: ObservableObject {
    static let shared = ChannelRepository()

    @Published private(set) var channels: [Zone66Channel] = []
    @Published private(set) var remoteSettings = Zone66RemoteSettings()
    @Published private(set) var isLoading = false
    @Published private(set) var lastError: String?

    private let favoritesKey = "zone66_favorites"
    private let cachedCatalogKey = "zone66_cached_catalog"

    private var catalogURL: URL {
        URL(string: "https://raw.githubusercontent.com/husszzzz/Zone66-Player/main/Data/channels.json?t=\(Int(Date().timeIntervalSince1970))")!
    }

    private var settingsURL: URL {
        URL(string: "https://raw.githubusercontent.com/husszzzz/Zone66-Player/main/Data/settings.json?t=\(Int(Date().timeIntervalSince1970))")!
    }

    private init() {
        loadFavorites()
        loadCachedCatalog()
        loadBundledFallback()
        refresh()
    }

    var categories: [String] {
        let values = Set(
            channels
                .map { $0.category.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
        )
        return ["الكل"] + values.sorted()
    }

    var featured: [Zone66Channel] {
        channels.filter { $0.enabled && $0.isFeatured }
    }

    var enabledChannels: [Zone66Channel] {
        channels.filter { $0.enabled }
    }

    func refresh() {
        isLoading = true
        lastError = nil

        Task {
            do {
                var request = URLRequest(url: catalogURL)
                request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
                request.timeoutInterval = 10

                let (catalogData, _) = try await URLSession.shared.data(for: request)
                let decoded = try JSONDecoder().decode([Zone66Channel].self, from: catalogData)

                var fetchedSettings = Zone66RemoteSettings()
                if let (settingsData, _) = try? await URLSession.shared.data(from: settingsURL),
                   let remote = try? JSONDecoder().decode(Zone66RemoteSettings.self, from: settingsData) {
                    fetchedSettings = remote
                }

                let enabledOnly = decoded.filter { $0.enabled }

                await MainActor.run {
                    self.channels = enabledOnly
                    self.remoteSettings = fetchedSettings
                    Zone66Theme.shared.apply(hex: fetchedSettings.accentHex)
                    self.isLoading = false
                    self.saveCachedCatalog()
                }
            } catch {
                await MainActor.run {
                    self.lastError = "تعذر تحديث القنوات"
                    self.isLoading = false
                }
            }
        }
    }

    func toggleFavorite(_ id: String) {
        var set = favoriteIDs()
        if set.contains(id) {
            set.remove(id)
        } else {
            set.insert(id)
        }
        UserDefaults.standard.set(Array(set), forKey: favoritesKey)
        objectWillChange.send()
    }

    func isFavorite(_ id: String) -> Bool {
        favoriteIDs().contains(id)
    }

    var favoriteChannels: [Zone66Channel] {
        channels.filter { favoriteIDs().contains($0.id) }
    }

    private func favoriteIDs() -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [])
    }

    private func loadFavorites() {}

    private func loadCachedCatalog() {
        guard let data = UserDefaults.standard.data(forKey: cachedCatalogKey),
              let cached = try? JSONDecoder().decode([Zone66Channel].self, from: data),
              !cached.isEmpty else {
            return
        }
        self.channels = cached.filter { $0.enabled }
    }

    private func loadBundledFallback() {
        guard channels.isEmpty else { return }

        // جرّب أولاً channels.json ثم ChannelsData.json
        let candidates = ["channels", "ChannelsData"]
        for name in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: "json"),
               let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode([Zone66Channel].self, from: data),
               !decoded.isEmpty {
                self.channels = decoded.filter { $0.enabled }
                return
            }
        }
    }

    private func saveCachedCatalog() {
        guard let data = try? JSONEncoder().encode(channels) else { return }
        UserDefaults.standard.set(data, forKey: cachedCatalogKey)
    }
}
