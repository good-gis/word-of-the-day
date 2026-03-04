import WidgetKit
import Foundation

struct WordEntry: TimelineEntry {
    let date: Date
    let word: Word?
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), word: Word(word: "Ephemeral", description: "Lasting a very short time"))
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        let entry = WordEntry(date: Date(), word: resolveWord())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let words = SharedDataManager.shared.loadWords()
        let now = Date()
        let interval: TimeInterval = 4 * 60 * 60

        guard !words.isEmpty else {
            let entry = WordEntry(date: now, word: nil)
            completion(Timeline(entries: [entry], policy: .never))
            return
        }

        if let pinnedId = SharedDataManager.shared.loadPinnedWordId(),
           let pinned = words.first(where: { $0.id == pinnedId }) {
            let entry = WordEntry(date: now, word: pinned)
            completion(Timeline(entries: [entry], policy: .never))
            return
        }

        let shuffled = words.shuffled()
        let count = min(3, shuffled.count)
        let entries: [WordEntry] = (0..<count).map { i in
            WordEntry(
                date: now.addingTimeInterval(Double(i) * interval),
                word: shuffled[i]
            )
        }

        let lastEntryDate = entries.last!.date
        completion(Timeline(entries: entries, policy: .after(lastEntryDate)))
    }

    private func resolveWord() -> Word? {
        let words = SharedDataManager.shared.loadWords()
        if let pinnedId = SharedDataManager.shared.loadPinnedWordId(),
           let pinned = words.first(where: { $0.id == pinnedId }) {
            return pinned
        }
        return words.first
    }
}
