import Foundation
import Observation

/// A list of lessons made by the user.
struct LessonGroup: Identifiable, Hashable, Codable {
    var id: UUID
    var name: String
    var lessonIDs: [Int]
}

enum GroupValidationError: Error, Equatable {
    case emptyName
    case nameTooLong
    case noLessons
}

/// User's groups, saved as JSON in Application Support (on this device only).
@Observable
final class GroupStore {
    static let maxNameLength = 50

    private(set) var groups: [LessonGroup] = []
    private let fileURL: URL

    init(fileURL: URL = GroupStore.defaultFileURL) {
        self.fileURL = fileURL
        if let data = try? Data(contentsOf: fileURL),
           let saved = try? JSONDecoder().decode([LessonGroup].self, from: data) {
            groups = saved
        }
    }

    static var defaultFileURL: URL {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("groups.json")
    }

    func group(_ id: UUID) -> LessonGroup? {
        groups.first { $0.id == id }
    }

    /// Checks the rules of the Android app: a name of 1...50 characters and at least one lesson.
    /// - Returns: the name without surrounding spaces
    static func validate(name: String, lessonIDs: Set<Int>) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { throw GroupValidationError.emptyName }
        if trimmed.count > maxNameLength { throw GroupValidationError.nameTooLong }
        if lessonIDs.isEmpty { throw GroupValidationError.noLessons }
        return trimmed
    }

    /// Adds a group (id nil) or updates the one with this id.
    @discardableResult
    func save(id: UUID?, name: String, lessonIDs: Set<Int>) throws -> LessonGroup {
        let group = LessonGroup(id: id ?? UUID(),
                                name: try GroupStore.validate(name: name, lessonIDs: lessonIDs),
                                lessonIDs: lessonIDs.sorted())
        var updated = groups
        if let index = updated.firstIndex(where: { $0.id == group.id }) {
            updated[index] = group
        } else {
            updated.append(group)
        }
        try write(updated)
        return group
    }

    func remove(_ id: UUID) throws {
        try write(groups.filter { $0.id != id })
    }

    func removeAll() throws {
        try write([])
    }

    private func write(_ newGroups: [LessonGroup]) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(newGroups).write(to: fileURL, options: .atomic)
        groups = newGroups
    }
}
