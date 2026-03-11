import SwiftUI
import Combine
import CoreData

struct DrinkRecord: Identifiable {
    let id: UUID
    let drinkTypeName: String
    let cups: Int
    let date: Date
    let icon: String
}

final class TodayViewModel: ObservableObject {
    @Published var todayTotal: Int = 0
    @Published var dailyGoal: Int = 7
    @Published var drinkTypes: [DrinkType] = []
    @Published var recentRecords: [DrinkRecord] = []

    private let drinkStore: DrinkStore
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(drinkStore: DrinkStore, context: NSManagedObjectContext) {
        self.drinkStore = drinkStore
        self.context = context
        loadTodayData()
        setupObservers()
    }

    private func setupObservers() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadTodayData()
            }
            .store(in: &cancellables)
    }

    func loadTodayData() {
        todayTotal = drinkStore.getTodayTotal()
        dailyGoal = drinkStore.getDailyGoal()
        drinkTypes = drinkStore.getDrinkTypes()
        loadRecentRecords()
    }

    private func loadRecentRecords() {
        let entries = drinkStore.getEntries(for: Date())
        var records: [DrinkRecord] = []

        for entry in entries {
            let request: NSFetchRequest<DrinkType> = DrinkType.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", entry.drinkTypeId as CVarArg)
            request.fetchLimit = 1
            if let drinkType = try? context.fetch(request).first {
                records.append(DrinkRecord(
                    id: entry.id,
                    drinkTypeName: drinkType.name,
                    cups: Int(entry.cups),
                    date: entry.date,
                    icon: drinkType.icon
                ))
            }
        }

        recentRecords = records
    }

    var progress: Double {
        guard dailyGoal > 0 else { return 0 }
        return Double(todayTotal) / Double(dailyGoal)
    }

    var hasReachedHalfGoal: Bool {
        progress >= 0.5
    }
}
