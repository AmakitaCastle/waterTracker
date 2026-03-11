import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error)")
            }
        }
    }

    func scheduleHalfGoalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Great progress! 🎉"
        content.body = "You've reached half of your daily drink goal. Keep it up!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "half_goal_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil // Immediate
        )

        UNUserNotificationCenter.current().add(request)
    }
}
