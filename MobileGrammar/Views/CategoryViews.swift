import SwiftUI

struct CategoriesView: View {
    @Environment(Library.self) private var library

    var body: some View {
        List(library.categories) { category in
            NavigationLink(value: category) {
                Label(category.name.text, systemImage: category.id == "level" ? "chart.bar" : "square.stack.3d.up")
            }
        }
        .navigationTitle("Categories")
    }
}

/// All lessons of a category in sections, with search and a menu to jump to a section.
struct CategoryView: View {
    @Environment(Library.self) private var library
    let category: LessonCategory
    @State private var query = ""

    var body: some View {
        let sections = category.groups
            .map { group in (group: group, lessons: Library.search(library.lessons(group.lessons), for: query)) }
            .filter { !$0.lessons.isEmpty }
        ScrollViewReader { proxy in
            List {
                ForEach(sections, id: \.group.id) { section in
                    Section {
                        ForEach(section.lessons) { lesson in
                            NavigationLink(lesson.title, value: lesson)
                                .id(rowID(section.group, lesson))
                        }
                    } header: {
                        HStack {
                            Text(section.group.name.text)
                            Spacer()
                            Text(verbatim: "\(section.lessons.count)")
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .overlay {
                if sections.isEmpty {
                    ContentUnavailableView("Oops! No such lessons.", systemImage: "magnifyingglass")
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        ForEach(sections, id: \.group.id) { section in
                            Button("\(section.group.name.text) (\(section.lessons.count))" as String) {
                                withAnimation {
                                    proxy.scrollTo(rowID(section.group, section.lessons[0]), anchor: .top)
                                }
                            }
                        }
                    } label: {
                        Label("Go to", systemImage: "list.bullet")
                    }
                }
            }
        }
        .navigationTitle(category.name.text)
        .searchable(text: $query, prompt: Text("Enter article name …"))
    }

    private func rowID(_ group: CategoryGroup, _ lesson: Lesson) -> String {
        "\(group.id)-\(lesson.id)"
    }
}
