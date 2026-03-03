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
