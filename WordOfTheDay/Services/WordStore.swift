import SwiftUI
import WidgetKit

@Observable
final class WordStore {
    private(set) var words: [Word] = []

    init() {
        words = SharedDataManager.shared.loadWords()
    }

    func add(_ word: Word) {
        words.append(word)
        persist()
    }

    func delete(at offsets: IndexSet) {
        words.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        SharedDataManager.shared.saveWords(words)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
