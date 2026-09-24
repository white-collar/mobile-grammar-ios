import UserNotifications
import XCTest
@testable import MobileGrammar

final class ReminderTests: XCTestCase {
    private var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private func date(_ text: String) -> Date {
        ISO8601DateFormatter().date(from: text)!
    }

    func testDefaultTimeIsNextFullHour() {
        XCTAssertEqual(Reminder.defaultDate(now: date("2026-09-24T10:37:12Z"), calendar: calendar),
                       date("2026-09-24T11:00:00Z"))
        XCTAssertEqual(Reminder.defaultDate(now: date("2026-09-24T23:00:00Z"), calendar: calendar),
                       date("2026-09-25T00:00:00Z"))
    }

    func testNotificationAtChosenTime() throws {
        let request = Reminder.request(title: "Study", body: "Unit 1 - Present continuous (I am doing)",
                                       date: date("2026-10-01T18:30:00Z"), calendar: calendar)
        XCTAssertEqual(request.content.title, "Study")
        XCTAssertEqual(request.content.body, "Unit 1 - Present continuous (I am doing)")
        let trigger = try XCTUnwrap(request.trigger as? UNCalendarNotificationTrigger)
        XCTAssertFalse(trigger.repeats)
        XCTAssertEqual(trigger.dateComponents.month, 10)
        XCTAssertEqual(trigger.dateComponents.day, 1)
        XCTAssertEqual(trigger.dateComponents.hour, 18)
        XCTAssertEqual(trigger.dateComponents.minute, 30)
    }
}
