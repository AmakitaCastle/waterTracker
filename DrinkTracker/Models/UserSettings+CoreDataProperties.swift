import Foundation
import CoreData

extension UserSettings {

    @nonobjc class func fetchRequest() -> NSFetchRequest<UserSettings> {
        return NSFetchRequest<UserSettings>(entityName: "UserSettings")
    }

    @NSManaged var dailyGoal: Int16
    @NSManaged var reminderEnabled: Bool
}
