import Foundation

struct Channel: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let url: String
}
