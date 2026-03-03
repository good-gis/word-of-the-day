import Foundation

final class SharedDataManager {
    static let shared = SharedDataManager()

    private let wordsKey = "words"
    private let defaults: UserDefaults?

    private init() {
        defaults = UserDefaults(suiteName: "group.com.wordoftheday.shared")
    }

    func loadWords() -> [Word] {
        guard
            let defaults = defaults,
            let data = defaults.data(forKey: wordsKey),
            let words = try? JSONDecoder().decode([Word].self, from: data)
        else { return [] }
        return words
    }

    func saveWords(_ words: [Word]) {
        guard
            let defaults = defaults,
            let data = try? JSONEncoder().encode(words)
        else { return }
        defaults.set(data, forKey: wordsKey)
    }
}
