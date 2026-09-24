import SwiftUI

struct AllLessonsView: View {
    @Environment(Library.self) private var library

    var body: some View {
        LessonList(lessons: library.lessons)
            .navigationTitle("All lessons")
    }
}

/// Lessons with search by title.
struct LessonList: View {
    let lessons: [Lesson]
    @State private var query = ""

    var body: some View {
        let found = Library.search(lessons, for: query)
        List(found) { lesson in
            NavigationLink(lesson.title, value: lesson)
        }
        .searchable(text: $query, prompt: Text("Enter article name …"))
        .overlay {
            if found.isEmpty {
                ContentUnavailableView("Oops! No such lessons.", systemImage: "magnifyingglass")
            }
        }
    }
}

struct LessonView: View {
    @Environment(Library.self) private var library
    let lesson: Lesson
    @State private var reminding = false

    var body: some View {
        Group {
            if let html = try? library.html(of: lesson) {
                // explanations are in Ukrainian whatever the interface language
                HTMLView(html: html, language: "uk")
                    .accessibilityIdentifier("lesson")
            } else {
                ContentUnavailableView("The lesson couldn't be opened.", systemImage: "exclamationmark.triangle")
            }
        }
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    reminding = true
                } label: {
                    Label("Setup reminder", systemImage: "alarm")
                }
            }
        }
        .sheet(isPresented: $reminding) {
            ReminderSheet(title: String(localized: "There are the lesson to study the \"Mobile grammar\""),
                          message: lesson.title)
        }
    }
}
