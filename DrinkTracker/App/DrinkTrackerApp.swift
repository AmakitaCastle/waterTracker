import SwiftUI

@main
struct DrinkTrackerApp: App {
    @StateObject private var coreDataStack = CoreDataStack.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, coreDataStack.viewContext)
                .onAppear {
                    SeedData.seed(context: coreDataStack.viewContext)
                }
        }
    }
}
