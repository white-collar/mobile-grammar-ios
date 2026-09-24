import XCTest

final class MobileGrammarUITests: XCTestCase {
    private func launch(language: String = "en") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-uitesting", "-AppleLanguages", "(\(language))", "-AppleLocale", language == "uk" ? "uk_UA" : "en_US"]
        app.launch()
        return app
    }

    override func setUp() {
        continueAfterFailure = false
    }

    func testSearchAndOpenLesson() {
        let app = launch()
        XCTAssertTrue(app.navigationBars["All lessons"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["Unit 1 - Present continuous (I am doing)"].exists)

        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 5))
        search.tap()
        search.typeText("will")
        let units = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Unit '"))
        XCTAssertTrue(app.buttons["Unit 8 - Will or going to?"].waitForExistence(timeout: 5))
        XCTAssertEqual(units.count, 4)

        app.buttons["Unit 6 - Will (1)"].tap()
        XCTAssertTrue(app.navigationBars["Unit 6 - Will (1)"].waitForExistence(timeout: 5))
        let text = app.webViews.staticTexts.matching(NSPredicate(format: "label CONTAINS 'використовуємо'")).firstMatch
        XCTAssertTrue(text.waitForExistence(timeout: 15), "Ukrainian lesson text is shown")
        XCTAssertTrue(app.buttons["Setup reminder"].exists)
    }

    func testCreateAndOpenGroup() {
        let app = launch()
        app.tabBars.buttons["Your groups"].tap()
        XCTAssertTrue(app.buttons["Create new list of lessons"].waitForExistence(timeout: 5))
        app.buttons["Create new list of lessons"].tap()

        let name = app.textFields["groupName"]
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        name.typeText("Past tenses")
        // no lesson selected: the sheet stays open
        app.buttons["Save group"].tap()
        XCTAssertTrue(app.navigationBars["New group"].exists)

        let filter = app.textFields["lessonFilter"]
        filter.tap()
        filter.typeText("past simple")
        let lesson = app.buttons["Unit 11 - Past simple (I did)"]
        XCTAssertTrue(lesson.waitForExistence(timeout: 5))
        lesson.tap()
        XCTAssertTrue(app.staticTexts["Selected: 1"].exists)
        app.buttons["Save group"].tap()

        let group = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Past tenses'")).firstMatch
        XCTAssertTrue(group.waitForExistence(timeout: 5))
        group.tap()
        XCTAssertTrue(app.navigationBars["Past tenses"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Unit 11 - Past simple (I did)"].exists)
    }

    func testLessonsByLevel() {
        let app = launch()
        app.tabBars.buttons["Categories"].tap()
        app.buttons["By level"].tap()
        XCTAssertTrue(app.navigationBars["By level"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["A1 · Beginner"].exists)
        app.buttons["Go to"].tap()
        app.buttons["Higher · C1–C2 (6)"].tap()
        XCTAssertTrue(app.buttons["Unit 129 - Verb + Object + preposition (2)"].waitForExistence(timeout: 5))
    }

    func testUkrainianInterface() {
        let app = launch(language: "uk")
        XCTAssertTrue(app.navigationBars["Усі уроки"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.tabBars.buttons["Категорії"].exists)
        app.tabBars.buttons["Категорії"].tap()
        XCTAssertTrue(app.buttons["За рівнем"].waitForExistence(timeout: 5))
    }
}
