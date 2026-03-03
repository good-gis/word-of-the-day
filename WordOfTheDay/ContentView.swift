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
