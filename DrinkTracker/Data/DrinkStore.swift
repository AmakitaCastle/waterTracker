import CoreData
import Foundation

final class DrinkStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Drink Types

    func getDrinkTypes() -> [DrinkType] {
        let request: NSFetchRequest<DrinkType> = DrinkType.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "sortOrder", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    func addDrinkType(name: String, icon: String, isPreset: Bool = false) -> DrinkType {
        let drinkType = DrinkType(context: context)
        drinkType.id = UUID()
        drinkType.name = name
        drinkType.icon = icon
        drinkType.isPreset = isPreset
        drinkType.sortOrder = Int16(getDrinkTypes().count)
        return drinkType
    }

    // MARK: - Drink Entries

    func addEntry(drinkTypeId: UUID, cups: Int, date: Date = Date()) {
        let entry = DrinkEntry(context: context)
        entry.id = UUID()
        entry.date = date
        entry.drinkTypeId = drinkTypeId
        entry.cups = Int16(cups)
    }

    func getEntries(for date: Date) -> [DrinkEntry] {
        let request: NSFetchRequest<DrinkEntry> = DrinkEntry.fetchRequest()
        request.predicate = isTodayPredicate(date)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        return (try? context.fetch(request)) ?? []
    }

    func getTodayTotal() -> Int {
        let entries = getEntries(for: Date())
        return entries.reduce(0) { $0 + Int($1.cups) }
    }

    func getEntriesGroupedByDate() -> [Date: [DrinkEntry]] {
        let request: NSFetchRequest<DrinkEntry> = DrinkEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let entries = (try? context.fetch(request)) ?? []

        var grouped: [Date: [DrinkEntry]] = [:]
        for entry in entries {
            let day = Calendar.current.startOfDay(for: entry.date)
            grouped[day, default: []].append(entry)
        }
        return grouped
    }

    /// 获取某天的详细记录（包含饮料类型信息）
    func getDetailedEntries(for date: Date) -> [(entry: DrinkEntry, drinkType: DrinkType)] {
        let entries = getEntries(for: date)
        let drinkTypes = getDrinkTypes()

        var result: [(entry: DrinkEntry, drinkType: DrinkType)] = []
        for entry in entries {
            if let drinkType = drinkTypes.first(where: { $0.id == entry.drinkTypeId }) {
                result.append((entry, drinkType))
            }
        }
        return result
    }

    // MARK: - Settings

    func getDailyGoal() -> Int {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        request.fetchLimit = 1
        let settings = try? context.fetch(request).first
        return settings.map { Int($0.dailyGoal) } ?? 7
    }

    func setDailyGoal(_ goal: Int) {
        let request: NSFetchRequest<UserSettings> = UserSettings.fetchRequest()
        request.fetchLimit = 1
        let settings = (try? context.fetch(request).first) ?? UserSettings(context: context)
        settings.dailyGoal = Int16(goal)
    }

    // MARK: - History Data Methods

    /// 获取日期范围内的所有记录
    func getEntriesForDateRange(start: Date, end: Date) -> [DrinkEntry] {
        let request: NSFetchRequest<DrinkEntry> = DrinkEntry.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }

    /// 获取指定月份的所有日期（用于热力图）
    /// 返回按周分组的日期数组
    func getDaysForMonth(month: Date) -> [HeatmapDay] {
        let calendar = Calendar.current

        // 获取月份的起始和结束日期
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        guard let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return []
        }

        // 获取该月的所有记录
        let entries = getEntriesForDateRange(start: monthStart, end: monthEnd)

        // 将记录按日期分组
        var entriesByDate: [Date: Int] = [:]
        for entry in entries {
            let day = calendar.startOfDay(for: entry.date)
            entriesByDate[day, default: 0] += Int(entry.cups)
        }

        // 获取月份的第一天是周几
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let firstWeekdayOffset = (firstWeekday - 2 + 7) % 7 // 转换为周一=0, 周日=6

        // 获取月份的天数
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count

        var days: [HeatmapDay] = []

        // 添加当月的所有日期
        var weekIndex = 0
        for day in 1...daysInMonth {
            guard let date = calendar.date(bySetting: .day, value: day, of: monthStart) else {
                continue
            }
            let cups = entriesByDate[date] ?? 0
            let weekday = calendar.component(.weekday, from: date)
            let dayOfWeek = (weekday - 2 + 7) % 7

            days.append(HeatmapDay(
                id: UUID(),
                date: date,
                cups: cups,
                weekIndex: weekIndex,
                dayOfWeek: dayOfWeek
            ))

            // 更新周索引
            if dayOfWeek == 6 && day < daysInMonth {
                weekIndex += 1
            }
        }

        return days
    }

    /// 获取有数据的月份范围
    func getDataMonthRange() -> (first: Date, last: Date)? {
        let request: NSFetchRequest<DrinkEntry> = DrinkEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        request.fetchLimit = 1

        let calendar = Calendar.current

        // 获取最早的记录
        if let earliest = (try? context.fetch(request).first)?.date {
            let firstMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: earliest))!

            // 获取最晚的记录
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            if let latest = (try? context.fetch(request).first)?.date {
                let lastMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: latest))!
                return (firstMonth, lastMonth)
            }
        }

        return nil
    }

    /// 计算连续饮水天数
    func calculateConsecutiveDays() -> Int {
        let request: NSFetchRequest<DrinkEntry> = DrinkEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        let entries = (try? context.fetch(request)) ?? []

        guard !entries.isEmpty else { return 0 }

        let calendar = Calendar.current
        var consecutiveDays = 0
        var expectedDate = calendar.startOfDay(for: Date())

        // 按日期分组
        var cupsByDate: [Date: Int] = [:]
        for entry in entries {
            let day = calendar.startOfDay(for: entry.date)
            cupsByDate[day, default: 0] += Int(entry.cups)
        }

        // 检查今天是否有记录
        if cupsByDate[expectedDate] == nil || cupsByDate[expectedDate]! == 0 {
            expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
        }

        while let cups = cupsByDate[expectedDate], cups > 0 {
            consecutiveDays += 1
            expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
        }

        return consecutiveDays
    }

    /// 获取年度总杯数
    func getYearTotal() -> Int {
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: Date()))!
        let startOfNextYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!

        let entries = getEntriesForDateRange(start: startOfYear, end: startOfNextYear)
        return entries.reduce(0) { $0 + Int($1.cups) }
    }

    /// 获取近 N 个月的月度统计
    /// 返回：[(月份日期, 总杯数)]
    func getMonthlyTotals(lastN: Int) -> [(Date, Int)] {
        let calendar = Calendar.current
        let now = Date()
        var result: [(Date, Int)] = []

        for i in 0..<lastN {
            // 计算每个月的起始日期
            let monthDate = calendar.date(byAdding: .month, value: -i, to: now)!
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate))!
            let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!

            let entries = getEntriesForDateRange(start: startOfMonth, end: startOfNextMonth)
            let total = entries.reduce(0) { $0 + Int($1.cups) }

            result.append((startOfMonth, total))
        }

        // 反转顺序，从旧到新
        return result.reversed()
    }

    /// 获取日均饮水量（过去一年）
    func getDailyAverage() -> Double {
        let calendar = Calendar.current
        let now = Date()
        let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!

        let entries = getEntriesForDateRange(start: oneYearAgo, end: now)
        let totalCups = entries.reduce(0) { $0 + Int($1.cups) }

        // 计算过去一年有多少天有记录
        var datesWithEntries: Set<Date> = []
        for entry in entries {
            let day = calendar.startOfDay(for: entry.date)
            datesWithEntries.insert(day)
        }

        let daysWithRecords = datesWithEntries.count
        guard daysWithRecords > 0 else { return 0 }

        return Double(totalCups) / Double(daysWithRecords)
    }

    // MARK: - Utilities

    private func isTodayPredicate(_ date: Date) -> NSPredicate {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        return NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
    }
}
