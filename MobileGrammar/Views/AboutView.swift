import SwiftUI

struct AboutView: View {
    @Environment(Library.self) private var library

    var body: some View {
        HTMLView(html: page, language: AppLanguage.isUkrainian ? "uk" : "en")
            .navigationTitle("About program")
            .navigationBarTitleDisplayMode(.inline)
    }

    private var page: String {
        let note = String(localized: "This is the iPhone version of the Mobile Grammar app. It works offline. Your groups are stored only on this device. The app doesn't collect any statistics.")
        return "<p class=\"note\">\(note.htmlEscaped)</p>" + ((try? library.aboutHTML()) ?? "")
    }
}
