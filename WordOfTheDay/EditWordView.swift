import SwiftUI

struct EditWordView: View {
    @Environment(\.dismiss) private var dismiss
    var store: WordStore
    var word: Word

    @State private var wordText: String
    @State private var descriptionText: String

    init(store: WordStore, word: Word) {
        self.store = store
        self.word = word
        _wordText = State(initialValue: word.word)
        _descriptionText = State(initialValue: word.description)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit Word")
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
                Button("Delete", role: .destructive) {
                    store.delete(word)
                    dismiss()
                }

                Spacer()

                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.cancelAction)

                Button("Save") {
                    var updated = word
                    updated.word = wordText.trimmingCharacters(in: .whitespaces)
                    updated.description = descriptionText.trimmingCharacters(in: .whitespaces)
                    store.update(updated)
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
