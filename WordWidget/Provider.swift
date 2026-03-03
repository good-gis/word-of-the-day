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
        let entry = WordEntry(date: Date(), word: words.randomElement())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let words = SharedDataManager.shared.loadWords()
        let now = Date()
        let interval: TimeInterval = 4 * 60 * 60 // 4 hours

        let entries: [WordEntry] = (0..<3).map { i in
            WordEntry(
                date: now.addingTimeInterval(Double(i) * interval),
                word: words.randomElement()
            )
        }

        let nextRefresh = now.addingTimeInterval(3 * interval)
        let timeline = Timeline(entries: entries, policy: .after(nextRefresh))
        completion(timeline)
    }
}
