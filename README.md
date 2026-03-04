# 📖 Word Of The Day

A minimal macOS app to build and display your personal vocabulary — one word at a time.

Add words with definitions, pin your favorite, and let the widget keep it front and center on your desktop. No accounts, no cloud, no tracking. Everything stays on your Mac.

---

## ✨ Features

- **Word list** — add, edit, and delete words with descriptions
- **Pin a word** — pin any word to always show it in the widget
- **Rotating widget** — when nothing is pinned, the widget cycles through random words every 4 hours
- **Small & Medium widget sizes** — fits wherever you want it on your desktop
- **Dark mode support** — looks great in any appearance
- **Privacy first** — all data stored locally via App Groups, nothing leaves your machine

---

## 🖥 Requirements

- macOS 26 or later

---

## 📦 Installation

### Option 1 — Download DMG

1. Go to [Releases](../../releases)
2. Download the latest `.dmg`
3. Open it and drag **Word Of The Day** to your Applications folder

### Option 2 — Build from Source

```bash
git clone https://github.com/your-username/wordoftheday.git
cd wordoftheday
open WordOfTheDay.xcodeproj
```

Select the `WordOfTheDay` scheme and hit **Run** (⌘R).

> You'll need to update the App Group identifier (`group.com.wordoftheday.shared`) to match your own development team in both the app and widget targets.

---

## 🧩 Adding the Widget

1. Right-click your desktop and choose **Edit Widgets**
2. Search for **Word Of The Day**
3. Choose **Small** or **Medium** size and add it

---

## 🗂 Project Structure

```
wordoftheday/
├── WordOfTheDay/          # Main app target
│   ├── Models/            # Word data model
│   ├── Services/          # WordStore — persistence logic
│   ├── ContentView.swift  # Word list with add / edit / pin
│   ├── AddWordView.swift
│   └── EditWordView.swift
├── WordWidget/            # Widget extension
│   ├── Provider.swift     # Timeline & word resolution
│   └── WordWidget.swift   # Small & Medium widget views
└── Shared/
    └── SharedDataManager.swift  # App Group bridge
```

---

## 🛠 Built With

- [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- App Groups for shared UserDefaults between app and widget

---

## 📄 License

MIT
