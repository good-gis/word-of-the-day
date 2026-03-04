import WidgetKit
import SwiftUI

struct WordWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let word = entry.word {
            switch family {
            case .systemSmall:
                SmallWidgetView(word: word)
            case .systemMedium:
                MediumWidgetView(word: word)
            default:
                SmallWidgetView(word: word)
            }
        } else {
            PlaceholderWidgetView()
        }
    }
}

private struct WidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        colorScheme == .dark ? Color(nsColor: .windowBackgroundColor) : Color.white
    }
}

struct SmallWidgetView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(word.word)
                .font(.title)
                .fontWeight(.light)
                .foregroundStyle(.primary)
                .lineLimit(3)
                .minimumScaleFactor(0.5)

            Text(word.description)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(5)
        }
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) { WidgetBackground() }
    }
}

struct MediumWidgetView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(word.word)
                .font(.title)
                .fontWeight(.light)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.5)

            Text(word.description)
                .font(.callout)
                .foregroundStyle(.secondary)
                .lineLimit(4)

            Spacer()

            Text(word.dateAdded.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) { WidgetBackground() }
    }
}

struct PlaceholderWidgetView: View {
    var body: some View {
        Text("Add words in the app")
            .font(.callout)
            .foregroundStyle(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(for: .widget) { WidgetBackground() }
    }
}

struct WordWidget: Widget {
    let kind: String = "WordWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WordWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Word Of The Day")
        .description("Shows a random word from your list.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    WordWidget()
} timeline: {
    WordEntry(date: .now, word: Word(word: "Ephemeral", description: "Lasting for a very short time"))
}

#Preview(as: .systemMedium) {
    WordWidget()
} timeline: {
    WordEntry(date: .now, word: Word(word: "Ephemeral", description: "Lasting for a very short time"))
}
