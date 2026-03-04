import SwiftUI

struct ContentView: View {
    @State private var store = WordStore()
    @State private var showingAddWord = false
    @State private var editingWord: Word?

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
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(word.word)
                                        .font(.headline)
                                    Text(word.description)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 4)

                                Spacer()

                                Button {
                                    store.pin(word)
                                } label: {
                                    Image(systemName: store.pinnedWordId == word.id ? "pin.fill" : "pin")
                                        .foregroundStyle(store.pinnedWordId == word.id ? .primary : .secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { editingWord = word }
                        }
                        .onDelete { offsets in
                            store.delete(at: offsets)
                        }
                    }
                }
            }
            .navigationTitle("Word Of The Day")
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
            .sheet(item: $editingWord) { word in
                EditWordView(store: store, word: word)
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}
