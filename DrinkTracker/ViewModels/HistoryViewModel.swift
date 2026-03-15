import CoreData
import Combine
import Foundation
import SwiftUI

/// 热力图格子数据
struct HeatmapDay: Identifiable {
    let id: UUID
    let date: Date
    let cups: Int
    let weekIndex: Int
    let dayOfWeek: Int
    var isCurrentMonth: Bool = true  // 是否属于当前月份
    var dayNumber: Int? = nil        // 日期数字（1-31）
}

/// 选中日期的饮水记录（用于详情展示）
struct SelectedDrinkRecord: Identifiable {
    let id: UUID
    let drinkTypeName: String
    let drinkTypeIcon: String
    let cups: Int
    let time: Date
}

/// 月度统计
struct MonthStats {
    let month: Date
    let totalCups: Int
    let progress: Double // 相对于最大值的比例 (0-1)
}

/// 历史页面 ViewModel
@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var heatmapDays: [HeatmapDay] = []
    @Published var monthStats: [MonthStats] = []
    @Published var consecutiveDays: Int = 0
    @Published var yearTotal: Int = 0
    @Published var dailyAverage: Double = 0
    @Published var selectedDate: Date?
    @Published var selectedDateCups: Int = 0
    @Published var selectedDateRecords: [SelectedDrinkRecord] = []
    @Published var isLoading: Bool = false
    @Published var currentMonth: Date = Date() // 当前显示的月份
    @Published var hasPreviousMonth: Bool = false // 是否有上个月数据
    @Published var hasNextMonth: Bool = false // 是否有下个月数据

    private let drinkStore: DrinkStore
    private let calendar: Calendar

    init(drinkStore: DrinkStore) {
        self.drinkStore = drinkStore
        self.calendar = Calendar.current
    }

    /// 加载所有历史数据
    func loadAllData() {
        isLoading = true

        // 加载热力图数据
        loadHeatmapData(for: currentMonth)

        // 加载月度统计
        loadMonthlyStats()

        // 加载统计数据
        loadStatistics()

        isLoading = false
    }

    /// 加载指定月份的热力图数据
    func loadHeatmapData(for month: Date) {
        currentMonth = month
        let daysInMonth = drinkStore.getDaysForMonth(month: month)
        self.heatmapDays = daysInMonth

        // 检查是否有上个月和下个月的数据
        checkMonthNavigation()
    }

    /// 切换到上个月
    func goToPreviousMonth() {
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) else { return }
        loadHeatmapData(for: previousMonth)
    }

    /// 切换到下个月
    func goToNextMonth() {
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) else { return }
        loadHeatmapData(for: nextMonth)
    }

    /// 检查月份导航状态
    private func checkMonthNavigation() {
        // 允许向前切换到任意历史月份（不限制在有数据的月份范围内）
        // 只要当前月份不是公元元年，就可以继续向前
        hasPreviousMonth = true

        // 检查是否有下个月（不能是未来月份）
        let now = Date()
        let currentMonthEnd = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
        hasNextMonth = currentMonthEnd <= now
    }

    /// 定位到今天
    func scrollToToday() {
        let today = Date()
        if calendar.isDate(today, equalTo: currentMonth, toGranularity: .month) {
            // 今天就在当前显示的月份中
        } else {
            // 切换到今天所在的月份
            loadHeatmapData(for: today)
        }
    }

    /// 加载月度统计（近 6 个月）
    private func loadMonthlyStats() {
        let totals = drinkStore.getMonthlyTotals(lastN: 6)

        // 找到最大值作为基准
        let maxCups = totals.map { $0.1 }.max() ?? 1

        self.monthStats = totals.map { date, cups in
            MonthStats(
                month: date,
                totalCups: cups,
                progress: maxCups > 0 ? Double(cups) / Double(maxCups) : 0
            )
        }
    }

    /// 加载统计数据
    private func loadStatistics() {
        self.consecutiveDays = drinkStore.calculateConsecutiveDays()
        self.yearTotal = drinkStore.getYearTotal()
        self.dailyAverage = drinkStore.getDailyAverage()
    }

    /// 选择日期
    func selectDate(_ date: Date) {
        self.selectedDate = date

        // 获取该日期的所有记录（包含饮料类型信息）
        let detailedEntries = drinkStore.getDetailedEntries(for: date)
        self.selectedDateCups = detailedEntries.reduce(0) { $0 + Int($1.entry.cups) }

        // 组装详细记录列表
        let records = detailedEntries.map { item in
            SelectedDrinkRecord(
                id: item.entry.id,
                drinkTypeName: item.drinkType.name,
                drinkTypeIcon: item.drinkType.icon,
                cups: Int(item.entry.cups),
                time: item.entry.date
            )
        }

        // 按时间倒序排列
        self.selectedDateRecords = records.sorted { $0.time > $1.time }
    }

    /// 清除选择
    func clearSelection() {
        self.selectedDate = nil
        self.selectedDateCups = 0
        self.selectedDateRecords = []
    }

    /// 定位到今天
    func scrollToToday() -> Int? {
        let today = calendar.startOfDay(for: Date())

        for (index, day) in heatmapDays.enumerated() {
            if calendar.isDate(day.date, inSameDayAs: today) {
                return index
            }
        }

        return nil
    }

    /// 获取日期对应的 emoji 和状态
    func getEmojiAndStatus(for cups: Int) -> (emoji: String, status: String) {
        switch cups {
        case 0:
            return ("drop.fill", "未记录")
        case 1, 2:
            return ("drop.triangle", "少量")
        case 3, 4:
            return ("tint", "良好")
        default:
            return ("sparkles.square.fill.on.square", "达标")
        }
    }

    /// 格式化日期显示
    func formatDateDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M 月 d 日 EEEE"
        return formatter.string(from: date)
    }

    /// 格式化月份
    func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M 月"
        return formatter.string(from: date)
    }

    /// 获取热力图颜色
    func getHeatmapColor(for cups: Int) -> Color {
        switch cups {
        case 0:
            return DesignTokens.heatmapZero
        case 1, 2:
            return DesignTokens.heatmapLow
        case 3, 4:
            return DesignTokens.heatmapMedium
        case 5, 6:
            return DesignTokens.heatmapHigh
        default:
            return DesignTokens.heatmapVeryHigh
        }
    }

    /// 获取星期标签
    func getWeekdayLabel(_ dayOfWeek: Int) -> String {
        let labels = ["", "日", "", "二", "", "四", "", "六"]
        return labels[dayOfWeek]
    }

    /// 获取 abbreviated 星期标签（用于左侧标签）
    func getShortWeekdayLabel(_ index: Int) -> String {
        let labels = ["一", "三", "五"]
        if index >= 0 && index < labels.count {
            return labels[index]
        }
        return ""
    }

    /// 获取月份标签
    func getMonthLabel(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "MMM"
        let abbrev = formatter.string(from: date)
        // 转换为大写
        return abbrev.uppercased()
    }
}
