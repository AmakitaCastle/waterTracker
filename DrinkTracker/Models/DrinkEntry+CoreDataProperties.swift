import Foundation
import CoreData

extension DrinkEntry {

    @nonobjc class func fetchRequest() -> NSFetchRequest<DrinkEntry> {
        return NSFetchRequest<DrinkEntry>(entityName: "DrinkEntry")
    }

    @NSManaged var id: UUID
    @NSManaged var date: Date
    @NSManaged var drinkTypeId: UUID
    @NSManaged var cups: Int16
}
