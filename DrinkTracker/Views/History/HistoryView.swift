import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var context
    @State private var entriesByDate: [Date: [DrinkEntry]] = [:]

    var body: some View {
        NavigationView {
            List {
                ForEach(sortDates(entriesByDate.keys), id: \.self) { date in
                    NavigationLink(destination: DayDetailView(date: date, entries: entriesByDate[date] ?? [])) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(formatDate(date))
                                    .font(.system(size: 16, weight: .medium))
                                Text("\(totalCups(for: date)) 杯")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("历史")
            .onAppear {
                loadHistory()
            }
        }
    }

    private func loadHistory() {
        let store = DrinkStore(context: context)
        entriesByDate = store.getEntriesGroupedByDate()
    }

    private func sortDates(_ dates: Dictionary<Date, [DrinkEntry]>.Keys) -> [Date] {
        return dates.sorted(by: >)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: date)
    }

    private func totalCups(for date: Date) -> Int {
        guard let entries = entriesByDate[date] else { return 0 }
        return entries.reduce(0) { $0 + Int($1.cups) }
    }
}
