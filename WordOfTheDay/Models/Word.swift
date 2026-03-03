import Foundation

struct Word: Identifiable, Codable {
    let id: UUID
    var word: String
    var description: String
    var dateAdded: Date

    init(id: UUID = UUID(), word: String, description: String, dateAdded: Date = Date()) {
        self.id = id
        self.word = word
        self.description = description
        self.dateAdded = dateAdded
    }
}
