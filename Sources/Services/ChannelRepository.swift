import Foundation
import SwiftUI

public final class ChannelRepository: ObservableObject {
    public static let shared = ChannelRepository()

    @Published public var channels: [Channel] = []
    @Published public var favorites: [String] = []
    @Published public var isSyncing: Bool = false
    @Published public var lastSyncDate: Date?

    private let remoteSyncURL = "https://raw.githubusercontent.com/husszzzz/Zone66-Player/main/Data/channels.json"

    private let customFileUrl: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("custom_channels.json")
    }()

    private init() {
        loadFavorites()
        loadLocalChannels()
        syncWithRemoteServer()
    }

    public var categories: [String] {
        let cats = Set(channels.filter { $0.enabled }.map { $0.category.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
        return ["الكل"] + Array(cats).sorted()
    }

    public func loadLocalChannels() {
        if FileManager.default.fileExists(atPath: customFileUrl.path),
           let data = try? Data(contentsOf: customFileUrl),
           let saved = try? JSONDecoder().decode([Channel].self, from: data), !saved.isEmpty {
            self.channels = saved
        } else {
            self.channels = loadBundledDefaults()
        }
    }

    public func loadBundledDefaults() -> [Channel] {
        guard let url = Bundle.main.url(forResource: "ChannelsData", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let list = try? JSONDecoder().decode([Channel].self, from: data) else {
            return []
        }
        return list
    }

    // LIVE SYNC with coomCraft / Zone66-Player Data/channels.json
    public func syncWithRemoteServer() {
        guard let url = URL(string: "\(remoteSyncURL)?t=\(Int(Date().timeIntervalSince1970))") else { return }
        self.isSyncing = true

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        let session = URLSession(configuration: config)

        session.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSyncing = false
                guard let data = data, error == nil else { return }

                if let remoteChannels = try? JSONDecoder().decode([Channel].self, from: data), !remoteChannels.isEmpty {
                    // Merge remote channels from dashboard at the top
                    var current = self.channels.filter { local in
                        !remoteChannels.contains(where: { $0.id == local.id || ($0.name == local.name && !$0.name.isEmpty) })
                    }
                    var updatedList = remoteChannels + current
                    self.channels = updatedList
                    self.saveToDisk()
                    self.lastSyncDate = Date()
                }
            }
        }.resume()
    }

    public func addChannel(name: String, url: String, category: String) {
        let newChannel = Channel(id: UUID().uuidString, name: name, url: url, category: category, isCustom: true, enabled: true)
        channels.insert(newChannel, at: 0)
        saveToDisk()
    }

    public func updateChannel(id: String, name: String, url: String, category: String) {
        if let idx = channels.firstIndex(where: { $0.id == id }) {
            channels[idx].name = name
            channels[idx].url = url
            channels[idx].category = category
            saveToDisk()
        }
    }

    public func deleteChannel(id: String) {
        channels.removeAll(where: { $0.id == id })
        favorites.removeAll(where: { $0 == id })
        saveToDisk()
    }

    public func deleteAllCustomChannels() {
        channels.removeAll(where: { $0.isCustom })
        saveToDisk()
    }

    public func resetToBundledDefaults() {
        self.channels = loadBundledDefaults()
        try? FileManager.default.removeItem(at: customFileUrl)
        syncWithRemoteServer()
    }

    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(channels) {
            try? data.write(to: customFileUrl)
        }
    }

    // MARK: - Favorites
    private func loadFavorites() {
        if let arr = UserDefaults.standard.stringArray(forKey: "zh_fav_ids") {
            self.favorites = arr
        }
    }

    public func toggleFavorite(id: String) {
        if favorites.contains(id) {
            favorites.removeAll(where: { $0 == id })
        } else {
            favorites.append(id)
        }
        UserDefaults.standard.set(favorites, forKey: "zh_fav_ids")
    }

    public func isFavorite(id: String) -> Bool {
        favorites.contains(id)
    }

    public func favoriteChannels() -> [Channel] {
        channels.filter { favorites.contains($0.id) }
    }
}
