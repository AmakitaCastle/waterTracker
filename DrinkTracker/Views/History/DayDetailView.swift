import SwiftUI
import CoreData

struct DayDetailView: View {
    let date: Date
    let entries: [DrinkEntry]
    @Environment(\.managedObjectContext) private var context
    @State private var groupedEntries: [DrinkType: Int] = [:]

    var body: some View {
        List {
            ForEach(groupedEntries.keys.sorted(by: { $0.name < $1.name }), id: \.id) { drinkType in
                HStack {
                    Image(systemName: drinkType.icon)
                        .font(.system(size: 24))
                    Text(drinkType.name)
                    Spacer()
                    Text("\(groupedEntries[drinkType] ?? 0) 杯")
                        .foregroundColor(.secondary)
                }
            }

            Section {
                HStack {
                    Text("总计")
                    Spacer()
                    Text("\(totalCups) 杯")
                        .fontWeight(.semibold)
                }
            }
        }
        .navigationTitle(formatDate(date))
        .onAppear {
            groupEntriesByType()
        }
    }

    private func groupEntriesByType() {
        var grouped: [DrinkType: Int] = [:]
        for entry in entries {
            if let drinkType = fetchDrinkType(for: entry) {
                grouped[drinkType, default: 0] += Int(entry.cups)
            }
        }
        groupedEntries = grouped
    }

    private func fetchDrinkType(for entry: DrinkEntry) -> DrinkType? {
        let request: NSFetchRequest<DrinkType> = DrinkType.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", entry.drinkTypeId as CVarArg)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    private var totalCups: Int {
        entries.reduce(0) { $0 + Int($1.cups) }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
