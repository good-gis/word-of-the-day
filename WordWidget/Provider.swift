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
        let words = SharedDataManager.shared.loadWords()
        let entry = WordEntry(date: Date(), word: words.first)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let words = SharedDataManager.shared.loadWords()
        let now = Date()
        let interval: TimeInterval = 4 * 60 * 60 // 4 hours

        guard !words.isEmpty else {
            let entry = WordEntry(date: now, word: nil)
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
        let timeline = Timeline(entries: entries, policy: .after(lastEntryDate))
        completion(timeline)
    }
}
