# WordOfTheDay Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a minimal macOS SwiftUI app for learning vocabulary words with a WidgetKit widget that shows a random word every 4 hours.

**Architecture:** Shared `SharedDataManager` reads/writes `[Word]` via `UserDefaults(suiteName: "group.com.wordoftheday.shared")`. The app's `WordStore` (@Observable) wraps it and triggers widget timeline reloads on every mutation. The widget's `Provider` (TimelineProvider) reads from `SharedDataManager` at generation time — purely functional.

**Tech Stack:** Swift 5.9, SwiftUI, WidgetKit, UserDefaults (App Group), macOS 14+, Xcode 15+

---

## Pre-requisite: Initialize project directory

```bash
cd /Users/ivanglushkov/Projects/wordoftheday
git init
mkdir -p WordOfTheDay/Models WordOfTheDay/Services WordWidget Shared docs/plans
```

---

### Task 1: Data Model

**Files:**
- Create: `WordOfTheDay/Models/Word.swift`

**Step 1: Write the file**

```swift
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
```

**Step 2: Verify**

Open in Xcode later — no standalone compile step yet. Move on.

**Step 3: Commit**

```bash
git add WordOfTheDay/Models/Word.swift
git commit -m "feat: add Word data model"
```

---

### Task 2: SharedDataManager

**Files:**
- Create: `Shared/SharedDataManager.swift`

> This file will be added to **both** targets in Xcode (app + widget extension).

**Step 1: Write the file**

```swift
import Foundation

final class SharedDataManager {
    static let shared = SharedDataManager()

    private let suiteName = "group.com.wordoftheday.shared"
    private let wordsKey = "words"

    private var defaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }

    private init() {}

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
```

**Step 2: Commit**

```bash
git add Shared/SharedDataManager.swift
git commit -m "feat: add SharedDataManager for App Group UserDefaults"
```

---

### Task 3: WordStore

**Files:**
- Create: `WordOfTheDay/Services/WordStore.swift`

**Step 1: Write the file**

```swift
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
```

**Step 2: Commit**

```bash
git add WordOfTheDay/Services/WordStore.swift
git commit -m "feat: add WordStore with WidgetKit reload on mutation"
```

---

### Task 4: AddWordView

**Files:**
- Create: `WordOfTheDay/AddWordView.swift`

**Step 1: Write the file**

```swift
import SwiftUI

struct AddWordView: View {
    @Environment(\.dismiss) private var dismiss
    var store: WordStore

    @State private var wordText = ""
    @State private var descriptionText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("New Word")
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 8) {
                Text("Word").font(.caption).foregroundStyle(.secondary)
                TextField("e.g. Ephemeral", text: $wordText)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description / Translation").font(.caption).foregroundStyle(.secondary)
                TextField("e.g. Lasting for a very short time", text: $descriptionText)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Spacer()
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)
                Button("Save") {
                    let word = Word(word: wordText.trimmingCharacters(in: .whitespaces),
                                   description: descriptionText.trimmingCharacters(in: .whitespaces))
                    store.add(word)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(wordText.trimmingCharacters(in: .whitespaces).isEmpty ||
                          descriptionText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(24)
        .frame(minWidth: 360)
    }
}
```

**Step 2: Commit**

```bash
git add WordOfTheDay/AddWordView.swift
git commit -m "feat: add AddWordView sheet"
```

---

### Task 5: ContentView

**Files:**
- Create: `WordOfTheDay/ContentView.swift`

**Step 1: Write the file**

```swift
import SwiftUI

struct ContentView: View {
    @State private var store = WordStore()
    @State private var showingAddWord = false

    var body: some View {
        NavigationStack {
            Group {
                if store.words.isEmpty {
                    ContentUnavailableView(
                        "No Words Yet",
                        systemImage: "text.book.closed",
                        description: Text("Tap + to add your first word.")
                    )
                } else {
                    List {
                        ForEach(store.words) { word in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(word.word)
                                    .font(.headline)
                                Text(word.description)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Word of the Day")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddWord = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddWord) {
                AddWordView(store: store)
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}
```

**Step 2: Commit**

```bash
git add WordOfTheDay/ContentView.swift
git commit -m "feat: add ContentView with word list and delete"
```

---

### Task 6: App Entry Point

**Files:**
- Create: `WordOfTheDay/WordOfTheDayApp.swift`

**Step 1: Write the file**

```swift
import SwiftUI

@main
struct WordOfTheDayApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
```

**Step 2: Commit**

```bash
git add WordOfTheDay/WordOfTheDayApp.swift
git commit -m "feat: add app entry point"
```

---

### Task 7: Widget Provider

**Files:**
- Create: `WordWidget/Provider.swift`

**Step 1: Write the file**

```swift
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
```

**Step 2: Commit**

```bash
git add WordWidget/Provider.swift
git commit -m "feat: add widget TimelineProvider"
```

---

### Task 8: Widget Views

**Files:**
- Create: `WordWidget/WordWidget.swift`

**Step 1: Write the file**

```swift
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
        .containerBackground(for: .widget) { Color(.windowBackground) }
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
        .containerBackground(for: .widget) { Color(.windowBackground) }
    }
}

struct PlaceholderWidgetView: View {
    var body: some View {
        Text("Add words in the app")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(for: .widget) { Color(.windowBackground) }
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
```

**Step 2: Commit**

```bash
git add WordWidget/WordWidget.swift
git commit -m "feat: add widget views for small and medium families"
```

---

### Task 9: Widget Bundle Entry Point

**Files:**
- Create: `WordWidget/WordWidgetBundle.swift`

**Step 1: Write the file**

```swift
import WidgetKit
import SwiftUI

@main
struct WordWidgetBundle: WidgetBundle {
    var body: some Widget {
        WordWidget()
    }
}
```

**Step 2: Commit**

```bash
git add WordWidget/WordWidgetBundle.swift
git commit -m "feat: add widget bundle entry point"
```

---

### Task 10: Xcode Project Setup

All Swift files are now written. Follow these steps in Xcode to assemble the project.

**Step 1: Create the Xcode project**

1. Open Xcode → File → New → Project
2. Choose **macOS → App**
3. Fill in:
   - Product Name: `WordOfTheDay`
   - Bundle Identifier: `com.wordoftheday.app`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Uncheck "Include Tests"
4. Save into `/Users/ivanglushkov/Projects/wordoftheday/`

**Step 2: Add Widget Extension target**

1. File → New → Target → **Widget Extension**
2. Product Name: `WordWidget`
3. Bundle Identifier: `com.wordoftheday.app.widget`
4. Uncheck "Include Configuration App Intent"
5. Click Finish → **Activate** the scheme when prompted

**Step 3: Add App Group capability to both targets**

1. Select the `WordOfTheDay` target → Signing & Capabilities → + Capability → **App Groups**
   - Add: `group.com.wordoftheday.shared`
2. Select the `WordWidget` target → same steps, same identifier

**Step 4: Replace auto-generated files with our source files**

The project will have auto-generated stubs. Replace/add them:

- In the `WordOfTheDay` group:
  - Replace `ContentView.swift` with our version
  - Replace `WordOfTheDayApp.swift` with our version
  - Create group `Models` → add `Word.swift`
  - Create group `Services` → add `WordStore.swift`
  - Delete `AddWordView.swift` stub if present, add ours
  - Delete auto-generated `Item.swift` if present

- In the `WordWidget` group:
  - Replace `WordWidgetBundle.swift` with our version
  - Replace or create `WordWidget.swift` with our version
  - Replace or create `Provider.swift` with our version

**Step 5: Add Shared group (target membership for both)**

1. In the project navigator, create a new group outside both targets: `Shared`
2. Right-click → Add Files → select `Shared/SharedDataManager.swift`
3. In the file inspector (right panel), under **Target Membership**, check **both** `WordOfTheDay` and `WordWidget`

**Step 6: Set deployment target**

For both targets: General → Minimum Deployments → **macOS 14.0**

**Step 7: Build and verify**

1. Select `WordOfTheDay` scheme → Build (⌘B)
   - Expected: Build Succeeded
2. Run (⌘R) — app opens, list is empty, "+" adds words, swipe/Edit deletes
3. Switch scheme to `WordWidget` → Build
   - Expected: Build Succeeded
4. Test widget in Xcode: In simulator or on device, long-press desktop → Edit Widgets → find "Word of the Day"

**Step 8: Final commit**

```bash
cd /Users/ivanglushkov/Projects/wordoftheday
git add .
git commit -m "feat: complete WordOfTheDay app and widget"
```

---

## Summary of Files Created

| File | Target(s) |
|------|-----------|
| `Shared/SharedDataManager.swift` | WordOfTheDay + WordWidget |
| `WordOfTheDay/Models/Word.swift` | WordOfTheDay |
| `WordOfTheDay/Services/WordStore.swift` | WordOfTheDay |
| `WordOfTheDay/WordOfTheDayApp.swift` | WordOfTheDay |
| `WordOfTheDay/ContentView.swift` | WordOfTheDay |
| `WordOfTheDay/AddWordView.swift` | WordOfTheDay |
| `WordWidget/Provider.swift` | WordWidget |
| `WordWidget/WordWidget.swift` | WordWidget |
| `WordWidget/WordWidgetBundle.swift` | WordWidget |
