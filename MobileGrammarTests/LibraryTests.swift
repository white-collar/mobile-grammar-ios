import XCTest
@testable import MobileGrammar

final class LibraryTests: XCTestCase {
    private var library: Library!

    override func setUpWithError() throws {
        library = try Library()
    }

    func testAllLessonsAreBundled() throws {
        XCTAssertEqual(library.lessons.count, 130)
        XCTAssertEqual(library.lessons.first?.title, "Unit 1 - Present continuous (I am doing)")
        XCTAssertEqual(library.lesson(106)?.title, "Unit 106 - Word order (2) - adverbs with the verb")
        for lesson in library.lessons {
            XCTAssertFalse(try library.html(of: lesson).isEmpty, "lesson \(lesson.id)")
        }
    }

    func testLessonsAreInUkrainian() throws {
        XCTAssertTrue(try library.html(of: library.lessons[0]).contains("Ми використовуємо"))
        for lesson in library.lessons {
            let html = try library.html(of: lesson)
            XCTAssertNil(html.range(of: "[ыэёъЫЭЁЪ]", options: .regularExpression), "lesson \(lesson.id)")
        }
    }

    func testEveryCategoryHasEveryLessonOnce() {
        XCTAssertEqual(library.categories.map(\.id), ["level", "topic"])
        let ids = library.lessons.map(\.id).sorted()
        for category in library.categories {
            XCTAssertEqual(category.groups.flatMap(\.lessons).sorted(), ids, category.id)
        }
        XCTAssertEqual(library.categories[0].groups.map(\.name.en), [
            "A1 · Beginner", "A2 · Elementary", "B1 · Intermediate", "B2 · Upper-intermediate", "Higher · C1–C2",
        ])
    }

    func testLessonsByIDKeepOrderAndSkipUnknown() {
        XCTAssertEqual(library.lessons([12, 11, 999]).map(\.id), [12, 11])
    }

    func testSearch() {
        XCTAssertEqual(Library.search(library.lessons, for: "will").count, 4)
        XCTAssertEqual(Library.search(library.lessons, for: "PRESENT simple").first?.id, 2)
        XCTAssertTrue(Library.search(library.lessons, for: "zzz").isEmpty)
        XCTAssertEqual(Library.search(library.lessons, for: "  ").count, 130)
    }

    func testAboutPage() throws {
        XCTAssertTrue(try library.aboutHTML().contains("English 2.0"))
    }
}
