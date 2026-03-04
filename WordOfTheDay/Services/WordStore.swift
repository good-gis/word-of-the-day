import SwiftUI
import WidgetKit

@Observable
final class WordStore {
    private(set) var words: [Word] = []
    private(set) var pinnedWordId: UUID?

    init() {
        words = SharedDataManager.shared.loadWords()
        pinnedWordId = SharedDataManager.shared.loadPinnedWordId()
    }

    func add(_ word: Word) {
        words.append(word)
        persist()
    }

    func update(_ word: Word) {
        guard let index = words.firstIndex(where: { $0.id == word.id }) else { return }
        words[index] = word
        persist()
    }

    func delete(_ word: Word) {
        words.removeAll { $0.id == word.id }
        if pinnedWordId == word.id {
            pinnedWordId = nil
            SharedDataManager.shared.savePinnedWordId(nil)
        }
        WidgetCenter.shared.reloadAllTimelines()
        persist()
    }

    func delete(at offsets: IndexSet) {
        let deletedIds = offsets.map { words[$0].id }
        words.remove(atOffsets: offsets)
        if let pinned = pinnedWordId, deletedIds.contains(pinned) {
            pinnedWordId = nil
            SharedDataManager.shared.savePinnedWordId(nil)
        }
        persist()
    }

    func pin(_ word: Word) {
        if pinnedWordId == word.id {
            pinnedWordId = nil
            SharedDataManager.shared.savePinnedWordId(nil)
        } else {
            pinnedWordId = word.id
            SharedDataManager.shared.savePinnedWordId(word.id)
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func persist() {
        SharedDataManager.shared.saveWords(words)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
