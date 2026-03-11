import CoreData
import Combine

final class CoreDataStack: ObservableObject {
    static let shared = CoreDataStack()

    @Published var persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private static func createPersistentContainer(inMemory: Bool) -> NSPersistentContainer {
        let managedObjectModel: NSManagedObjectModel = {
            let model = NSManagedObjectModel()

            // DrinkEntry entity
            let drinkEntryEntity = NSEntityDescription()
            drinkEntryEntity.name = "DrinkEntry"
            drinkEntryEntity.managedObjectClassName = "DrinkTracker.DrinkEntry"

            let entryIdAttribute = NSAttributeDescription()
            entryIdAttribute.name = "id"
            entryIdAttribute.attributeType = .UUIDAttributeType
            entryIdAttribute.isOptional = false

            let dateAttribute = NSAttributeDescription()
            dateAttribute.name = "date"
            dateAttribute.attributeType = .dateAttributeType
            dateAttribute.isOptional = false

            let drinkTypeIdAttribute = NSAttributeDescription()
            drinkTypeIdAttribute.name = "drinkTypeId"
            drinkTypeIdAttribute.attributeType = .UUIDAttributeType
            drinkTypeIdAttribute.isOptional = false

            let cupsAttribute = NSAttributeDescription()
            cupsAttribute.name = "cups"
            cupsAttribute.attributeType = .integer16AttributeType
            cupsAttribute.isOptional = false

            drinkEntryEntity.properties = [entryIdAttribute, dateAttribute, drinkTypeIdAttribute, cupsAttribute]

            // DrinkType entity
            let drinkTypeEntity = NSEntityDescription()
            drinkTypeEntity.name = "DrinkType"
            drinkTypeEntity.managedObjectClassName = "DrinkTracker.DrinkType"

            let typeIdAttribute = NSAttributeDescription()
            typeIdAttribute.name = "id"
            typeIdAttribute.attributeType = .UUIDAttributeType
            typeIdAttribute.isOptional = false

            let nameAttribute = NSAttributeDescription()
            nameAttribute.name = "name"
            nameAttribute.attributeType = .stringAttributeType
            nameAttribute.isOptional = false

            let iconAttribute = NSAttributeDescription()
            iconAttribute.name = "icon"
            iconAttribute.attributeType = .stringAttributeType
            iconAttribute.isOptional = false

            let systemNameAttribute = NSAttributeDescription()
            systemNameAttribute.name = "systemName"
            systemNameAttribute.attributeType = .stringAttributeType
            systemNameAttribute.isOptional = true

            let isPresetAttribute = NSAttributeDescription()
            isPresetAttribute.name = "isPreset"
            isPresetAttribute.attributeType = .booleanAttributeType
            isPresetAttribute.isOptional = false

            let sortOrderAttribute = NSAttributeDescription()
            sortOrderAttribute.name = "sortOrder"
            sortOrderAttribute.attributeType = .integer16AttributeType
            sortOrderAttribute.isOptional = false

            drinkTypeEntity.properties = [typeIdAttribute, nameAttribute, iconAttribute, systemNameAttribute, isPresetAttribute, sortOrderAttribute]

            // UserSettings entity
            let userSettingsEntity = NSEntityDescription()
            userSettingsEntity.name = "UserSettings"
            userSettingsEntity.managedObjectClassName = "DrinkTracker.UserSettings"

            let dailyGoalAttribute = NSAttributeDescription()
            dailyGoalAttribute.name = "dailyGoal"
            dailyGoalAttribute.attributeType = .integer16AttributeType
            dailyGoalAttribute.isOptional = false

            let reminderEnabledAttribute = NSAttributeDescription()
            reminderEnabledAttribute.name = "reminderEnabled"
            reminderEnabledAttribute.attributeType = .booleanAttributeType
            reminderEnabledAttribute.isOptional = false

            userSettingsEntity.properties = [dailyGoalAttribute, reminderEnabledAttribute]

            model.entities = [drinkEntryEntity, drinkTypeEntity, userSettingsEntity]

            return model
        }()

        let container = NSPersistentContainer(name: "DrinkTracker", managedObjectModel: managedObjectModel)

        if inMemory {
            container.persistentStoreDescriptions = [
                NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
            ]
        }

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData load failed: \(error.localizedDescription)")
            }
        }
        return container
    }

    init(inMemory: Bool = false) {
        self.persistentContainer = CoreDataStack.createPersistentContainer(inMemory: inMemory)
    }

    func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
}
