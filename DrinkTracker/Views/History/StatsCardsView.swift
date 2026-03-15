import SwiftUI

/// 数据统计卡组组件 - 白色磨砂玻璃风格
struct StatsCardsView: View {
    let consecutiveDays: Int
    let yearTotal: Int
    let dailyAverage: Double

    var body: some View {
        HStack(spacing: 8) {
            // 连续天数
            StatCardView(
                icon: "flame.fill",
                value: "\(consecutiveDays)",
                unit: "天",
                label: "连续天数"
            )

            // 年度总量
            StatCardView(
                icon: "drop.fill",
                value: "\(yearTotal)",
                unit: "杯",
                label: "年度总量"
            )

            // 日均饮水
            StatCardView(
                icon: "chart.bar.fill",
                value: String(format: "%.1f", dailyAverage),
                unit: "杯",
                label: "日均饮水"
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

/// 单张统计卡片 - 深海蓝风格
struct StatCardView: View {
    let icon: String
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            // SF Symbol 图标
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)

            // 核心数字
            HStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text(unit)
                    .font(.system(size: 9))
                    .foregroundColor(DesignTokens.lightSkyBlue)
            }

            // 指标名称
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(DesignTokens.lightSkyBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        // 深海蓝背景
        .background(DesignTokens.deepSeaBlue)
        .cornerRadius(18)
    }
}

#Preview {
    StatsCardsView(consecutiveDays: 7, yearTotal: 365, dailyAverage: 5.2)
        .background(DesignTokens.creamWhite)
}
