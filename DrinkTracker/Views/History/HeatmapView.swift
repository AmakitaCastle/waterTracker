import SwiftUI
import Combine

/// 热力图主容器 - 月度日历视图（深藏蓝主题）
struct HeatmapGridView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @Binding var selectedCell: HeatmapDay?

    // 日历网格配置
    private let cellSize: CGFloat = 36
    private let cellSpacing: CGFloat = 6
    private let cellRadius: CGFloat = 8

    // 滑动切换相关状态
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false

    // 动画配置
    private let swipeThreshold: CGFloat = 80
    private let animationDuration: Double = 0.3

    // 星期标签
    private let weekdayLabels = ["一", "二", "三", "四", "五", "六", "日"]

    var body: some View {
        VStack(spacing: 16) {
            // 头部导航
            headerView
                .padding(.horizontal, 20)

            // 日历主体（深藏蓝卡片）
            calendarCard
                .padding(.horizontal, 20)
        }
        .padding(.top, 16)
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            // 左侧：月份导航
            HStack(spacing: 12) {
                // 上个月按钮
                Button(action: {
                    performMonthSwitch(direction: -1)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(viewModel.hasPreviousMonth ? DesignTokens.calendarSecondaryText : DesignTokens.calendarSecondaryText.opacity(0.3))
                        .frame(width: 32, height: 32)
                }
                .disabled(!viewModel.hasPreviousMonth)

                // 月份标题
                Text(formatMonthTitle(viewModel.currentMonth))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(DesignTokens.calendarSecondaryText)

                // 下个月按钮
                Button(action: {
                    performMonthSwitch(direction: 1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(viewModel.hasNextMonth ? DesignTokens.calendarSecondaryText : DesignTokens.calendarSecondaryText.opacity(0.3))
                        .frame(width: 32, height: 32)
                }
                .disabled(!viewModel.hasNextMonth)
            }

            Spacer()

            // 右侧：定位今天按钮
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.scrollToToday()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.red)
                    Text("定位今天")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignTokens.calendarSecondaryText)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(DesignTokens.calendarSecondaryText)
                }
            }
        }
    }

    // MARK: - Calendar Card

    private var calendarCard: some View {
        ZStack {
            // 深藏蓝背景卡片
            RoundedRectangle(cornerRadius: 24)
                .fill(DesignTokens.calendarBackground)
                .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 6)

            VStack(spacing: 16) {
                // 星期标题行
                weekdayHeader

                // 日历网格（支持滑动）
                calendarGrid
                    .offset(x: dragOffset)
                    .opacity(calculateOpacity())
                    .scaleEffect(calculateScale())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                handleDragChanged(value)
                            }
                            .onEnded { value in
                                handleDragEnded(value)
                            }
                    )

                // 底部图例
                calendarLegend
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
    }

    // MARK: - Weekday Header

    private var weekdayHeader: some View {
        HStack(spacing: cellSpacing) {
            ForEach(weekdayLabels, id: \.self) { label in
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(DesignTokens.calendarSecondaryText)
                    .frame(width: cellSize, height: 20)
            }
        }
    }

    // MARK: - Calendar Grid

    private var calendarGrid: some View {
        let weeks = generateCalendarWeeks()

        return VStack(spacing: cellSpacing) {
            ForEach(weeks.indices, id: \.self) { weekIndex in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<7, id: \.self) { dayIndex in
                        if let day = weeks[weekIndex][dayIndex] {
                            CalendarCell(
                                day: day,
                                isSelected: selectedCell?.id == day.id,
                                cellSize: cellSize,
                                cellRadius: cellRadius,
                                viewModel: viewModel
                            )
                            .onTapGesture {
                                if day.isCurrentMonth {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedCell = day
                                    }
                                    viewModel.selectDate(day.date)
                                }
                            }
                        } else {
                            // 空格子（占位）
                            RoundedRectangle(cornerRadius: cellRadius)
                                .fill(Color.clear)
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Calendar Legend

    private var calendarLegend: some View {
        HStack(spacing: 8) {
            // 三个色块
            HStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.calendarLevelZero)
                    .frame(width: 20, height: 12)

                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.calendarLevelLow)
                    .frame(width: 20, height: 12)

                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.calendarLevelMedium)
                    .frame(width: 20, height: 12)
            }

            // 少 → 多 文本
            Text("少 → 多")
                .font(.system(size: 11))
                .foregroundColor(DesignTokens.calendarSecondaryText)
        }
    }

    // MARK: - Calendar Data Generation

    private func generateCalendarWeeks() -> [[HeatmapDay?]] {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: viewModel.currentMonth))!

        // 获取第一天是周几（周一=1, 周日=7）
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        // 转换为周一=0, 周日=6
        let firstWeekdayOffset = (firstWeekday + 5) % 7

        // 获取月份天数
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)!.count

        // 获取上月的日期数
        guard let previousMonth = calendar.date(byAdding: .month, value: -1, to: monthStart),
              let daysInPreviousMonth = calendar.range(of: .day, in: .month, for: previousMonth)?.count else {
            return []
        }

        var weeks: [[HeatmapDay?]] = []
        var currentWeek: [HeatmapDay?] = []
        var weekIndex = 0

        // 填充上月的日期
        for i in 0..<firstWeekdayOffset {
            guard let date = calendar.date(byAdding: .day, value: -(firstWeekdayOffset - i), to: monthStart) else { continue }
            let dayNumber = daysInPreviousMonth - firstWeekdayOffset + i + 1
            currentWeek.append(HeatmapDay(
                id: UUID(),
                date: date,
                cups: 0,
                weekIndex: weekIndex,
                dayOfWeek: i,
                isCurrentMonth: false,
                dayNumber: dayNumber
            ))
        }

        // 填充当月的日期
        for day in 1...daysInMonth {
            guard let date = calendar.date(bySetting: .day, value: day, of: monthStart) else { continue }
            let cups = getCupsForDate(date)
            let weekday = calendar.component(.weekday, from: date)
            let dayOfWeek = (weekday + 5) % 7

            currentWeek.append(HeatmapDay(
                id: UUID(),
                date: date,
                cups: cups,
                weekIndex: weekIndex,
                dayOfWeek: dayOfWeek,
                isCurrentMonth: true,
                dayNumber: day
            ))

            // 如果是一周的结束
            if currentWeek.count == 7 {
                weeks.append(currentWeek)
                currentWeek = []
                weekIndex += 1
            }
        }

        // 填充下月的日期
        var nextMonthDay = 1
        var nextMonthDayOfWeek = currentWeek.count
        while currentWeek.count < 7 && currentWeek.count > 0 {
            guard let date = calendar.date(byAdding: .day, value: daysInMonth + nextMonthDay - 1, to: monthStart) else { break }
            currentWeek.append(HeatmapDay(
                id: UUID(),
                date: date,
                cups: 0,
                weekIndex: weekIndex,
                dayOfWeek: nextMonthDayOfWeek,
                isCurrentMonth: false,
                dayNumber: nextMonthDay
            ))
            nextMonthDay += 1
            nextMonthDayOfWeek += 1
        }

        if !currentWeek.isEmpty {
            weeks.append(currentWeek)
        }

        return weeks
    }

    private func getCupsForDate(_ date: Date) -> Int {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)

        if let day = viewModel.heatmapDays.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) }) {
            return day.cups
        }
        return 0
    }

    // MARK: - Swipe Handling

    private func handleDragChanged(_ value: DragGesture.Value) {
        guard !isDragging else { return }

        let translation = value.translation.width

        // 限制拖动范围
        if translation > 0 && !viewModel.hasPreviousMonth {
            dragOffset = min(translation, swipeThreshold * 0.5)
        } else if translation < 0 && !viewModel.hasNextMonth {
            dragOffset = max(translation, -swipeThreshold * 0.5)
        } else {
            dragOffset = translation * 0.6 // 阻尼效果
        }
    }

    private func handleDragEnded(_ value: DragGesture.Value) {
        let translation = value.translation.width
        let velocity = value.predictedEndLocation.x - value.location.x

        // 根据位移或速度判断是否切换月份
        let shouldSwitchNext = translation < -swipeThreshold || velocity < -150
        let shouldSwitchPrev = translation > swipeThreshold || velocity > 150

        if shouldSwitchNext && viewModel.hasNextMonth {
            performMonthSwitch(direction: 1)
        } else if shouldSwitchPrev && viewModel.hasPreviousMonth {
            performMonthSwitch(direction: -1)
        } else {
            // 回弹动画
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                dragOffset = 0
            }
        }
    }

    private func performMonthSwitch(direction: Int) {
        isDragging = true

        // 滑动出去动画
        let exitOffset: CGFloat = direction > 0 ? -150 : 150

        withAnimation(.easeInOut(duration: animationDuration * 0.4)) {
            dragOffset = exitOffset
        }

        // 延迟后切换月份并滑入
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * 0.35) {
            if direction > 0 {
                viewModel.goToNextMonth()
            } else {
                viewModel.goToPreviousMonth()
            }

            // 从相反方向滑入
            dragOffset = -exitOffset

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
                withAnimation(.easeOut(duration: animationDuration * 0.5)) {
                    dragOffset = 0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * 0.5) {
                    isDragging = false
                }
            }
        }
    }

    // MARK: - Animation Calculations

    private func calculateOpacity() -> Double {
        let absOffset = abs(dragOffset)
        if absOffset > 100 {
            return max(0.5, 1.0 - Double(absOffset) / 300)
        }
        return 1.0
    }

    private func calculateScale() -> CGFloat {
        let absOffset = abs(dragOffset)
        let scaleReduction = min(Double(absOffset) / 400, 0.05)
        return CGFloat(1.0 - scaleReduction)
    }

    // MARK: - Helper

    private func formatMonthTitle(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: date)
    }
}

// MARK: - Calendar Cell

struct CalendarCell: View {
    let day: HeatmapDay
    let isSelected: Bool
    let cellSize: CGFloat
    let cellRadius: CGFloat
    @ObservedObject var viewModel: HistoryViewModel

    private let today = Date()

    var isToday: Bool {
        Calendar.current.isDate(day.date, inSameDayAs: today)
    }

    var body: some View {
        ZStack {
            // 背景
            RoundedRectangle(cornerRadius: cellRadius)
                .fill(backgroundColor)

            // 数字
            if let dayNum = day.dayNumber {
                Text("\(dayNum)")
                    .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                    .foregroundColor(textColor)
            }
        }
        .frame(width: cellSize, height: cellSize)
        .overlay(
            RoundedRectangle(cornerRadius: cellRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .opacity(day.isCurrentMonth ? 1.0 : 0.4)
    }

    private var backgroundColor: Color {
        if isSelected {
            return DesignTokens.calendarLevelMedium
        }

        if !day.isCurrentMonth {
            return DesignTokens.calendarCellDefault.opacity(0.5)
        }

        // 根据杯数返回对应颜色
        switch day.cups {
        case 0:
            return DesignTokens.calendarCellDefault
        case 1...3:
            return DesignTokens.calendarLevelLow
        case 4...6:
            return DesignTokens.calendarLevelMedium
        default:
            return DesignTokens.calendarLevelHigh
        }
    }

    private var textColor: Color {
        // 所有文字都使用灰色，确保在深色背景上清晰可见
        if day.cups > 0 {
            // 有数据的日期使用浅灰色
            return Color.white.opacity(0.9)
        }
        // 无数据的日期使用深灰色
        return DesignTokens.calendarSecondaryText
    }

    private var borderColor: Color {
        if isSelected {
            return DesignTokens.calendarHighlightStroke
        }
        if isToday && day.isCurrentMonth {
            return DesignTokens.calendarHighlightStroke
        }
        return Color.clear
    }

    private var borderWidth: CGFloat {
        if isSelected {
            return 2
        }
        if isToday && day.isCurrentMonth {
            return 2
        }
        return 0
    }
}
