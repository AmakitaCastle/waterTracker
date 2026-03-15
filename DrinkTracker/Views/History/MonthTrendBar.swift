import SwiftUI
import CoreData

/// 近 6 个月趋势条组件
struct MonthTrendBar: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.monthStats, id: \.month.timeIntervalSinceReferenceDate) { stat in
                MonthTrendRow(
                    month: viewModel.formatMonth(stat.month),
                    cups: stat.totalCups,
                    progress: stat.progress
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(DesignTokens.glassBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(DesignTokens.glassBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

/// 单行月份趋势
struct MonthTrendRow: View {
    let month: String
    let cups: Int
    let progress: Double

    var body: some View {
        HStack(spacing: 10) {
            // 月份标签
            Text(month)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(DesignTokens.mediumBlue)
                .frame(width: 28, alignment: .leading)

            // 进度条
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.paleBlue)
                        .frame(height: 8)

                    // 填充
                    RoundedRectangle(cornerRadius: 4)
                        .fill(DesignTokens.trendBarGradient)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .shadow(color: DesignTokens.mediumBlue.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
            .frame(height: 8)

            // 当月杯数
            Text("\(cups)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(DesignTokens.deepSeaBlue)
                .frame(width: 32, alignment: .trailing)
        }
    }
}
