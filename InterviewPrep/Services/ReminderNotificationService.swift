import Foundation
import UserNotifications

enum ReminderNotificationService {
    private static let requestIdentifiers = (1...7).map { "daily-reminder-\($0)" }
    private static let reminderMessages = [
        "Quiet reps win interviews. Open InterviewOS and clear one focused lesson.",
        "Ten sharp minutes today beats cramming later. Run a quick prep round.",
        "Keep the streak honest. One exercise is enough to stay interview-ready.",
        "Practice the answer before you need the answer. Do a short session now.",
        "A small session today makes the hard questions feel familiar tomorrow.",
        "Stay fluent, not rusty. Review one topic and keep momentum alive.",
        "Your next offer is built in small sessions. Open InterviewOS for a quick round."
    ]

    private static let foregroundDelegate = ReminderForegroundNotificationDelegate()

    static func configure() {
        UNUserNotificationCenter.current().delegate = foregroundDelegate
    }

    static func enableDailyReminders(hour: Int, minute: Int) async throws -> Bool {
        let settings = await currentNotificationSettings()

        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            break
        case .notDetermined:
            let granted = try await requestAuthorization()
            guard granted else {
                return false
            }
        case .denied:
            return false
        @unknown default:
            return false
        }

        try await scheduleWeeklyReminders(hour: hour, minute: minute)
        return true
    }

    static func disableDailyReminders() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: requestIdentifiers)
        center.removeDeliveredNotifications(withIdentifiers: requestIdentifiers)
    }

    private static func scheduleWeeklyReminders(hour: Int, minute: Int) async throws {
        disableDailyReminders()

        for weekday in 1...7 {
            var components = DateComponents()
            components.calendar = Calendar.current
            components.timeZone = .current
            components.weekday = weekday
            components.hour = hour
            components.minute = minute

            let content = UNMutableNotificationContent()
            content.title = "InterviewOS"
            content.body = reminderMessages[weekday - 1]
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(
                identifier: requestIdentifiers[weekday - 1],
                content: content,
                trigger: trigger
            )

            try await addNotificationRequest(request)
        }
    }

    private static func currentNotificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    private static func requestAuthorization() async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    private static func addNotificationRequest(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

private final class ReminderForegroundNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}
