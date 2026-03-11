import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var dailyGoal: Int = 7

    private let drinkStore: DrinkStore

    init(drinkStore: DrinkStore) {
        self.drinkStore = drinkStore
        self.dailyGoal = drinkStore.getDailyGoal()
    }

    func updateDailyGoal(_ goal: Int) {
        dailyGoal = goal
        drinkStore.setDailyGoal(goal)
        try? CoreDataStack.shared.save()
    }
}
