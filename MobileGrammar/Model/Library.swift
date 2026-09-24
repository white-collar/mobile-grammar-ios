import Foundation
import Observation

/// A lesson of the list; its text is in Content/lessons/<id>.html.
struct Lesson: Identifiable, Hashable, Decodable {
    let id: Int
    let title: String
}

/// Text given in the app's languages in the content files.
struct LocalizedName: Hashable, Decodable {
    let en: String
    let uk: String

    var text: String { AppLanguage.isUkrainian ? uk : en }
}

/// One group of a category, e.g. "B1" of "By level".
struct CategoryGroup: Identifiable, Hashable, Decodable {
    let id: String
    let name: LocalizedName
    let lessons: [Int]
}

/// A way to sort all lessons into groups, e.g. by level or by topic.
struct LessonCategory: Identifiable, Hashable, Decodable {
    let id: String
    let name: LocalizedName
    let groups: [CategoryGroup]
}

enum AppLanguage {
    /// Interface language chosen by iOS for the app (Settings → Mobile Grammar → Language).
    static var isUkrainian: Bool { Bundle.main.preferredLocalizations.first == "uk" }
}

enum LibraryError: Error {
    case missingFile(String)
}

/// Lessons, categories and About pages bundled with the app (copied from the web app by tools/sync_content.sh).
@Observable
final class Library {
    let lessons: [Lesson]
    let categories: [LessonCategory]
    private let lessonsByID: [Int: Lesson]
    private let bundle: Bundle

    init(bundle: Bundle = .main) throws {
        self.bundle = bundle
        lessons = try Library.decode([Lesson].self, "lessons", bundle: bundle)
        categories = try Library.decode([LessonCategory].self, "categories", bundle: bundle)
        lessonsByID = Dictionary(uniqueKeysWithValues: lessons.map { ($0.id, $0) })
    }

    func lesson(_ id: Int) -> Lesson? {
        lessonsByID[id]
    }

    /// Lessons with these ids, in the given order; unknown ids are skipped.
    func lessons(_ ids: [Int]) -> [Lesson] {
        ids.compactMap { lessonsByID[$0] }
    }

    /// HTML of the lesson's text (Ukrainian explanations, English examples).
    func html(of lesson: Lesson) throws -> String {
        try text(of: "\(lesson.id)", extension: "html", in: "Content/lessons")
    }

    /// HTML of the About page in the interface language.
    func aboutHTML() throws -> String {
        try text(of: AppLanguage.isUkrainian ? "uk" : "en", extension: "html", in: "Content/about")
    }

    /// Lessons whose title contains every word of the query, ignoring case.
    static func search(_ lessons: [Lesson], for query: String) -> [Lesson] {
        let words = query.lowercased().split(whereSeparator: \.isWhitespace)
        guard !words.isEmpty else { return lessons }
        return lessons.filter { lesson in
            let title = lesson.title.lowercased()
            return words.allSatisfy { title.contains($0) }
        }
    }

    private func text(of name: String, extension ext: String, in folder: String) throws -> String {
        guard let url = bundle.url(forResource: name, withExtension: ext, subdirectory: folder) else {
            throw LibraryError.missingFile("\(folder)/\(name).\(ext)")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    private static func decode<T: Decodable>(_ type: T.Type, _ name: String, bundle: Bundle) throws -> T {
        guard let url = bundle.url(forResource: name, withExtension: "json", subdirectory: "Content") else {
            throw LibraryError.missingFile("\(name).json")
        }
        return try JSONDecoder().decode(type, from: Data(contentsOf: url))
    }
}
