import Foundation

public struct Channel: Identifiable, Codable, Equatable {
    public let id: String
    public var name: String
    public var url: String
    public var category: String
    public var isCustom: Bool

    public init(id: String = UUID().uuidString, name: String, url: String, category: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.url = url
        self.category = category
        self.isCustom = isCustom
    }
}
