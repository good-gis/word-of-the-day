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

struct SmallWidgetView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(word.word)
                .font(.title2)
                .fontWeight(.light)
                .foregroundStyle(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text(word.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct MediumWidgetView: View {
    let word: Word

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(word.word)
                .font(.title2)
                .fontWeight(.light)
                .foregroundStyle(.primary)

            Text(word.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()

            Text(word.dateAdded.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct PlaceholderWidgetView: View {
    var body: some View {
        Text("Add words in the app")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(for: .widget) { Color(.systemBackground) }
    }
}

struct WordWidget: Widget {
    let kind: String = "WordWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WordWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Word of the Day")
        .description("Shows a random word from your list.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
