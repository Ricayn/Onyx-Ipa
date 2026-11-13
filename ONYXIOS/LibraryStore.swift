import Foundation
import SwiftUI

@MainActor
final class LibraryStore: ObservableObject {
    @Published var favorites: Set<String> = []
    @Published var history: [WatchRecord] = []
    @Published var customStreams: [UserStream] = []

    private let defaults = UserDefaults.standard
    private let favoritesKey = "onyx.favorites.v1"
    private let historyKey = "onyx.history.v1"
    private let streamsKey = "onyx.streams.v1"

    init() {
        favorites = Set(defaults.stringArray(forKey: favoritesKey) ?? [])
        history = Self.decode([WatchRecord].self, from: defaults.data(forKey: historyKey)) ?? []
        customStreams = Self.decode([UserStream].self, from: defaults.data(forKey: streamsKey)) ?? []
    }

    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }

    func toggleFavorite(_ id: String) {
        if favorites.contains(id) { favorites.remove(id) }
        else { favorites.insert(id) }
        defaults.set(Array(favorites), forKey: favoritesKey)
    }

    func addHistory(title: String, url: URL) {
        history.removeAll { $0.url == url }
        history.insert(WatchRecord(title: title, url: url), at: 0)
        history = Array(history.prefix(100))
        save(history, key: historyKey)
    }

    func addStream(name: String, category: MediaCategory, urls: [URL]) {
        customStreams.insert(UserStream(name: name, category: category, urls: urls), at: 0)
        save(customStreams, key: streamsKey)
    }

    func deleteStream(_ stream: UserStream) {
        customStreams.removeAll { $0.id == stream.id }
        save(customStreams, key: streamsKey)
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) { defaults.set(data, forKey: key) }
    }

    private static func decode<T: Decodable>(_ type: T.Type, from data: Data?) -> T? {
        guard let data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
