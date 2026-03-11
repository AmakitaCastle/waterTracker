import Foundation
import CoreData

extension DrinkType {

    @nonobjc class func fetchRequest() -> NSFetchRequest<DrinkType> {
        return NSFetchRequest<DrinkType>(entityName: "DrinkType")
    }

    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var icon: String
    @NSManaged var isPreset: Bool
    @NSManaged var sortOrder: Int16
}
