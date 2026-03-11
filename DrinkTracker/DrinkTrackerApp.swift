//
//  DrinkTrackerApp.swift
//  DrinkTracker
//
//  Created by Castle Amakit on 2026/3/11.
//

import SwiftUI
import CoreData

@main
struct DrinkTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
