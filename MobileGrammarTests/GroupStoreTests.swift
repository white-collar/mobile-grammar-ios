import XCTest
@testable import MobileGrammar

final class GroupStoreTests: XCTestCase {
    private var url: URL!

    override func setUp() {
        url = FileManager.default.temporaryDirectory.appendingPathComponent("groups-\(UUID().uuidString).json")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: url)
    }

    func testValidationRulesOfTheApp() throws {
        XCTAssertThrowsError(try GroupStore.validate(name: "   ", lessonIDs: [1])) {
            XCTAssertEqual($0 as? GroupValidationError, .emptyName)
        }
        XCTAssertThrowsError(try GroupStore.validate(name: String(repeating: "x", count: 51), lessonIDs: [1])) {
            XCTAssertEqual($0 as? GroupValidationError, .nameTooLong)
        }
        XCTAssertThrowsError(try GroupStore.validate(name: "Tenses", lessonIDs: [])) {
            XCTAssertEqual($0 as? GroupValidationError, .noLessons)
        }
        XCTAssertEqual(try GroupStore.validate(name: "  Tenses ", lessonIDs: [1]), "Tenses")
        XCTAssertNoThrow(try GroupStore.validate(name: String(repeating: "x", count: 50), lessonIDs: [1]))
    }

    func testSaveUpdateRemoveAreKeptOnDisk() throws {
        let store = GroupStore(fileURL: url)
        XCTAssertTrue(store.groups.isEmpty)

        let tenses = try store.save(id: nil, name: "Tenses", lessonIDs: [12, 11])
        XCTAssertEqual(tenses.lessonIDs, [11, 12])
        XCTAssertEqual(GroupStore(fileURL: url).groups, [tenses])

        try store.save(id: tenses.id, name: "Past tenses", lessonIDs: [11, 12, 13])
        XCTAssertEqual(store.groups.count, 1)
        XCTAssertEqual(store.group(tenses.id)?.name, "Past tenses")
        XCTAssertEqual(GroupStore(fileURL: url).group(tenses.id)?.lessonIDs, [11, 12, 13])

        let modals = try store.save(id: nil, name: "Modals", lessonIDs: [26])
        try store.remove(tenses.id)
        XCTAssertEqual(GroupStore(fileURL: url).groups, [modals])

        try store.removeAll()
        XCTAssertTrue(GroupStore(fileURL: url).groups.isEmpty)
    }

    func testInvalidGroupIsNotSaved() {
        let store = GroupStore(fileURL: url)
        XCTAssertThrowsError(try store.save(id: nil, name: "", lessonIDs: [1]))
        XCTAssertTrue(store.groups.isEmpty)
        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func testBrokenFileGivesNoGroups() throws {
        try Data("not json".utf8).write(to: url)
        XCTAssertTrue(GroupStore(fileURL: url).groups.isEmpty)
    }
}
