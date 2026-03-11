import Foundation
import CoreData

struct SeedData {
    static func seed(context: NSManagedObjectContext) {
        // Names of old English drink types to remove
        let englishNames = ["Tea", "Soda", "Milk", "Water", "Coffee", "Juice"]
        // Also remove any existing 汽水 entries
        let chineseNamesToRemove = ["汽水"]

        // Delete old/unwanted drink types
        for name in englishNames + chineseNamesToRemove {
            let request: NSFetchRequest<DrinkType> = DrinkType.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", name)
            if let existingType = try? context.fetch(request).first {
                context.delete(existingType)
            }
        }

        let presetDrinks = [
            (name: "水", icon: "drop.fill"),
            (name: "咖啡", icon: "cup.and.saucer.fill"),
            (name: "茶", icon: "cup.and.saucer.fill"),
            (name: "果汁", icon: "wineglass.fill"),
            (name: "牛奶", icon: "takeoutbag.and.cup.and.straw.fill")
        ]

        // Create or update preset drink types
        for (index, drink) in presetDrinks.enumerated() {
            let request: NSFetchRequest<DrinkType> = DrinkType.fetchRequest()
            request.predicate = NSPredicate(format: "name == %@", drink.name)
            if let existingType = try? context.fetch(request).first {
                // Update icon if needed
                if existingType.icon != drink.icon {
                    existingType.icon = drink.icon
                }
            } else {
                // Create new drink type
                let drinkType = DrinkType(context: context)
                drinkType.id = UUID()
                drinkType.name = drink.name
                drinkType.icon = drink.icon
                drinkType.isPreset = true
                drinkType.sortOrder = Int16(index)
            }
        }

        // Create default settings if not exists
        let settingsRequest: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        if (try? context.fetch(settingsRequest).first) == nil {
            let settings = UserSettings(context: context)
            settings.dailyGoal = 7
            settings.reminderEnabled = true
        }

        try? context.save()
    }
}
