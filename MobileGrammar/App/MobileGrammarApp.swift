import SwiftUI

@main
struct MobileGrammarApp: App {
    @State private var library: Library
    @State private var groups: GroupStore

    init() {
        do {
            _library = State(initialValue: try Library())
        } catch {
            fatalError("Lessons are missing from the app bundle: \(error)")
        }
        if ProcessInfo.processInfo.arguments.contains("-uitesting") {
            // UI tests start without saved groups
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("groups-uitesting.json")
            try? FileManager.default.removeItem(at: url)
            _groups = State(initialValue: GroupStore(fileURL: url))
        } else {
            _groups = State(initialValue: GroupStore())
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(library)
                .environment(groups)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                AllLessonsView().appDestinations()
            }
            .tabItem { Label("Lessons", systemImage: "book") }

            NavigationStack {
                CategoriesView().appDestinations()
            }
            .tabItem { Label("Categories", systemImage: "square.grid.2x2") }

            NavigationStack {
                GroupsView().appDestinations()
            }
            .tabItem { Label("Your groups", systemImage: "folder") }

            NavigationStack {
                AboutView()
            }
            .tabItem { Label("About", systemImage: "info.circle") }
        }
    }
}

extension View {
    /// Screens that can be opened from lists in any tab.
    func appDestinations() -> some View {
        navigationDestination(for: Lesson.self) { LessonView(lesson: $0) }
            .navigationDestination(for: LessonCategory.self) { CategoryView(category: $0) }
            .navigationDestination(for: LessonGroup.self) { GroupView(groupID: $0.id) }
    }
}
