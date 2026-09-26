import Foundation
import SwiftUI

public final class ChannelRepository: ObservableObject {
    public static let shared = ChannelRepository()

    @Published public var channels: [Channel] = []
    @Published public var favorites: [String] = []

    private let customFileUrl: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("custom_channels.json")
    }()

    private init() {
        loadFavorites()
        loadAllChannels()
    }

    public var categories: [String] {
        let cats = Set(channels.map { $0.category.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty })
        return ["الكل"] + Array(cats).sorted()
    }

    public func loadAllChannels() {
        if FileManager.default.fileExists(atPath: customFileUrl.path),
           let data = try? Data(contentsOf: customFileUrl),
           let saved = try? JSONDecoder().decode([Channel].self, from: data) {
            channels = saved
        } else {
            channels = loadBundledDefaults()
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

    public func addChannel(name: String, url: String, category: String) {
        let newChannel = Channel(name: name, url: url, category: category, isCustom: true)
        channels.insert(newChannel, at: 0)
        saveToDisk()
    }

    public func updateChannel(id: String, name: String, url: String, category: String) {
        guard let idx = channels.firstIndex(where: { $0.id == id }) else { return }
        channels[idx].name = name
        channels[idx].url = url
        channels[idx].category = category
        saveToDisk()
    }

    public func deleteChannel(id: String) {
        channels.removeAll { $0.id == id }
        favorites.removeAll { $0 == id }
        UserDefaults.standard.set(favorites, forKey: "zh_fav_ids")
        saveToDisk()
    }

    public func deleteAllCustomChannels() {
        channels.removeAll { $0.isCustom }
        saveToDisk()
    }

    public func resetToBundledDefaults() {
        channels = loadBundledDefaults()
        try? FileManager.default.removeItem(at: customFileUrl)
    }

    private func saveToDisk() {
        if let data = try? JSONEncoder().encode(channels) {
            try? data.write(to: customFileUrl, options: .atomic)
        }
    }

    private func loadFavorites() {
        favorites = UserDefaults.standard.stringArray(forKey: "zh_fav_ids") ?? []
    }

    public func toggleFavorite(id: String) {
        if favorites.contains(id) {
            favorites.removeAll { $0 == id }
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
