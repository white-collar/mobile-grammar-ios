import Foundation
import UserNotifications

/// "Setup reminder": a local notification to study a lesson or group at a chosen time.
enum Reminder {
    /// The next full hour, the time offered by default.
    static func defaultDate(now: Date = .now, calendar: Calendar = .current) -> Date {
        let hour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        return calendar.date(byAdding: .hour, value: 1, to: hour) ?? now
    }

    static func request(title: String, body: String, date: Date, calendar: Calendar = .current) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    }

    /// Asks for permission if needed and schedules the notification.
    /// - Returns: false if the user doesn't allow notifications
    static func schedule(title: String, body: String, date: Date) async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        guard try await center.requestAuthorization(options: [.alert, .sound]) else { return false }
        try await center.add(request(title: title, body: body, date: date))
        return true
    }
}
