import XCTest
@testable import DrinkTracker

final class DrinkStoreTests: XCTestCase {
    var store: DrinkStore!
    var stack: CoreDataStack!

    override func setUp() {
        stack = CoreDataStack(inMemory: true)
        store = DrinkStore(context: stack.viewContext)
    }

    func test_addDrinkEntry() {
        let drinkType = store.addDrinkType(name: "Water", icon: "drop.fill", isPreset: true)
        try? stack.save()

        store.addEntry(drinkTypeId: drinkType.id, cups: 2, date: Date())
        try? stack.save()

        let entries = store.getEntries(for: Date())
        XCTAssertEqual(entries.count, 1)
        XCTAssertEqual(entries.first?.cups, 2)
    }

    func test_getTodayTotal() {
        let drinkType = store.addDrinkType(name: "Coffee", icon: "cup.and.saucer.fill", isPreset: true)
        try? stack.save()

        store.addEntry(drinkTypeId: drinkType.id, cups: 3, date: Date())
        try? stack.save()

        let total = store.getTodayTotal()
        XCTAssertEqual(total, 3)
    }
}
