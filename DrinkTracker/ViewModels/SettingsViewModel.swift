import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var dailyGoal: Int = 7
    @Published var isReminderEnabled: Bool = false

    private let drinkStore: DrinkStore
    private let reminderKey = "isReminderEnabled"

    init(drinkStore: DrinkStore) {
        self.drinkStore = drinkStore
        self.dailyGoal = drinkStore.getDailyGoal()
        self.isReminderEnabled = UserDefaults.standard.bool(forKey: reminderKey)
    }

    func updateDailyGoal(_ goal: Int) {
        dailyGoal = goal
        drinkStore.setDailyGoal(goal)
        try? CoreDataStack.shared.save()
    }

    func updateReminderStatus(_ enabled: Bool) {
        isReminderEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: reminderKey)
    }
}
