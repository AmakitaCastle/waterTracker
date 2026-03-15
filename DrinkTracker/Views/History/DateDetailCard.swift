import SwiftUI

/// 日期详情卡（点击热力图格子后触发）
struct DateDetailCard: View {
    @ObservedObject var viewModel: HistoryViewModel
    let cups: Int
    let records: [SelectedDrinkRecord]
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let selectedDate = viewModel.selectedDate {
                // 头部：日期和总杯数
                headerView(date: selectedDate)

                // 分隔线
                Divider()
                    .background(DesignTokens.glassBorder)
                    .padding(.horizontal, 16)

                // 饮料记录列表
                if records.isEmpty {
                    // 无记录状态
                    emptyStateView
                } else {
                    // 记录列表
                    recordsListView
                }
            }
        }
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(DesignTokens.glassBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(DesignTokens.glassBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity.combined(with: .move(edge: .top))
        ))
    }

    // MARK: - Header View

    private func headerView(date: Date) -> some View {
        let (emoji, status) = viewModel.getEmojiAndStatus(for: cups)

        return HStack(spacing: 20) {
            // 左栏：日期和杯数
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.formatDateDisplay(date))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignTokens.mediumBlue)

                Text("\(cups) 杯")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(DesignTokens.deepSeaBlue)
            }

            Spacer()

            // 右栏：图标和状态
            VStack(spacing: 4) {
                Image(systemName: emoji)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(DesignTokens.deepSeaBlue)

                Text(status)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(DesignTokens.mediumBlue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Records List View

    private var recordsListView: some View {
        VStack(spacing: 0) {
            ForEach(records) { record in
                recordRow(record: record)

                if record.id != records.last?.id {
                    Divider()
                        .background(DesignTokens.glassBorder)
                        .padding(.horizontal, 16)
                }
            }
        }
        .padding(.top, 8)
    }

    private func recordRow(record: SelectedDrinkRecord) -> some View {
        HStack(spacing: 12) {
            // 图标
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignTokens.lightSkyBlue.opacity(0.3))
                    .frame(width: 36, height: 36)

                Image(systemName: record.drinkTypeIcon)
                    .font(.system(size: 18))
                    .foregroundColor(DesignTokens.mediumBlue)
            }

            // 名称和时间
            VStack(alignment: .leading, spacing: 2) {
                Text(record.drinkTypeName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignTokens.deepSeaBlue)

                Text(formatTime(record.time))
                    .font(.system(size: 11))
                    .foregroundColor(DesignTokens.calendarSecondaryText)
            }

            Spacer()

            // 杯数
            HStack(spacing: 4) {
                Text("\(record.cups)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignTokens.deepSeaBlue)

                Text("杯")
                    .font(.system(size: 12))
                    .foregroundColor(DesignTokens.mediumBlue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        HStack {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "drop.slash")
                    .font(.system(size: 32))
                    .foregroundColor(DesignTokens.calendarSecondaryText)

                Text("未记录饮水")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DesignTokens.calendarSecondaryText)
            }
            .padding(.vertical, 24)

            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: - Helper

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    DateDetailCard(
        viewModel: HistoryViewModel(drinkStore: DrinkStore(context: CoreDataStack.shared.viewContext)),
        cups: 3,
        records: [
            SelectedDrinkRecord(
                id: UUID(),
                drinkTypeName: "水",
                drinkTypeIcon: "drop.fill",
                cups: 2,
                time: Date()
            ),
            SelectedDrinkRecord(
                id: UUID(),
                drinkTypeName: "茶",
                drinkTypeIcon: "leaf.fill",
                cups: 1,
                time: Date().addingTimeInterval(-3600)
            )
        ],
        onDismiss: {}
    )
}
