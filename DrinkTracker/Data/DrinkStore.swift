import CoreData
import CoreData
import Foundation

final class DrinkStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Drink Types

    func getDrinkTypes() -> [DrinkType] {
        let request: NSFetchRequest<DrinkType> = DrinkType.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    func addDrinkType(name: String, icon: String, isPreset: Bool = false) -> DrinkType {
        let drinkType = DrinkType(context: context)
        drinkType.id = UUID()
        drinkType.name = name
        drinkType.icon = icon
        drinkType.isPreset = isPreset
        drinkType.sortOrder = Int16(getDrinkTypes().count)
        return drinkType
    }

    // MARK: - Drink Entries

    func addEntry(drinkTypeId: UUID, cups: Int, date: Date = Date()) {
        let entry = DrinkEntry(context: context)
        entry.id = UUID()
        entry.date = date
        entry.drinkTypeId = drinkTypeId
        entry.cups = Int16(cups)
    }

    func getEntries(for date: Date) -> [DrinkEntry] {
        let request: NSFetchRequest<DrinkEntry> = DrinkEntry.fetchRequest()
        request.predicate = isTodayPredicate(date)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func getTodayTotal() -> Int {
        let entries = getEntries(for: Date())
        return entries.reduce(0) { $0 + Int($1.cups) }
    }

    func getEntriesGroupedByDate() -> [Date: [DrinkEntry]] {
        let request: NSFetchRequest<DrinkEntry> = DrinkEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let entries = (try? context.fetch(request)) ?? []

        var grouped: [Date: [DrinkEntry]] = [:]
        for entry in entries {
            let day = Calendar.current.startOfDay(for: entry.date)
            grouped[day, default: []].append(entry)
        }
        return grouped
    }

    // MARK: - Settings

    func getDailyGoal() -> Int {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        request.fetchLimit = 1
        let settings = try? context.fetch(request).first
        return settings.map { Int($0.dailyGoal) } ?? 7
    }

    func setDailyGoal(_ goal: Int) {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        request.fetchLimit = 1
        let settings = (try? context.fetch(request).first) ?? UserSettings(context: context)
        settings.dailyGoal = Int16(goal)
    }

    // MARK: - Utilities

    private func isTodayPredicate(_ date: Date) -> NSPredicate {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
    }
}
