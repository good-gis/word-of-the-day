# WordOfTheDay — Design Document

**Date:** 2026-03-03
**Platform:** macOS 14+, Swift 5.9, Xcode (GUI)
**Frameworks:** SwiftUI, WidgetKit, UserDefaults (App Group)

---

## Overview

A minimal macOS app for learning vocabulary words. Users add word + description pairs; a WidgetKit widget displays a random word on the desktop, refreshing every 4 hours.

---

## Architecture

### Data Flow

```
App (WordStore) ──write──► UserDefaults(suiteName: "group.com.wordoftheday.shared")
                                          │
Widget (Provider) ──read──────────────────┘
```

- `SharedDataManager` is the single read/write point for `[Word]`, shared across both targets.
- `WordStore` is `@Observable`, wraps `SharedDataManager`, and calls `WidgetCenter.shared.reloadAllTimelines()` on every mutation.
- `Provider` (TimelineProvider) reads from `SharedDataManager` at timeline generation time — no state, purely functional.

### App Group

Identifier: `group.com.wordoftheday.shared`
Both the app target and widget extension must have this capability enabled.

---

## Data Model

```swift
struct Word: Identifiable, Codable {
    let id: UUID
    var word: String
    var description: String
    var dateAdded: Date
}
```

Stored as JSON in `UserDefaults(suiteName:)` under key `"words"`.

---

## File Structure

```
Shared/
  SharedDataManager.swift    — encode/decode [Word] via App Group UserDefaults

WordOfTheDay/
  WordOfTheDayApp.swift      — @main, WindowGroup
  ContentView.swift          — NavigationSplitView, word list, delete
  AddWordView.swift          — Sheet: word + description TextFields + Save
  Models/Word.swift          — Identifiable, Codable struct
  Services/WordStore.swift   — @Observable, add/delete, triggers widget reload

WordWidget/
  WordWidgetBundle.swift     — @main widget bundle entry point
  WordWidget.swift           — Widget config, EntryView for small + medium
  Provider.swift             — TimelineProvider, 3 entries × 4h apart
```

---

## Components

### ContentView
- `NavigationSplitView` (or `List` with toolbar on macOS)
- Toolbar "+" button opens `AddWordView` as a sheet
- `.onDelete` on `ForEach` for swipe/Edit-mode deletion
- Empty state: "No words yet. Tap + to add one."

### AddWordView
- Two `TextField` inputs: "Word" and "Description / Translation"
- Save button (disabled when either field is empty)
- Dismisses sheet on save, triggers `WordStore.add(_:)`

### WordStore
- `@Observable` class
- `add(_ word: Word)` and `delete(at offsets:)`
- Each mutation writes via `SharedDataManager` then calls `WidgetCenter.shared.reloadAllTimelines()`

### Widget — small
- Word in `.title2` / `.light` weight
- Description in `.caption` / `.secondary` color

### Widget — medium
- Word + description + date added
- Same typography, date in `.caption2` / `.secondary`

### Widget — empty state
- Text: "Add words in the app"

---

## Design

- No hardcoded colors — only `Color.primary`, `Color.secondary`, `Color(.windowBackground)` / `Color(.systemBackground)`
- Font weights: `.light` or `.ultraLight` for display, system defaults elsewhere
- Standard macOS controls, rounded text fields
- Light/dark via SwiftUI automatic adaptation

---

## Xcode Setup Steps

1. New Project → macOS → App → Product Name: "WordOfTheDay"
2. Add Widget Extension target → Name: "WordWidget" (uncheck "Include Configuration App Intent")
3. Add App Group capability to **both** targets: `group.com.wordoftheday.shared`
4. Create `Shared/` group in project navigator; add `SharedDataManager.swift` to **both** targets
5. Add remaining files to their respective targets
6. Build & Run

---

## Constraints

- macOS 14+ deployment target
- No external dependencies — standard Apple frameworks only
- English UI language
- Interface: English
