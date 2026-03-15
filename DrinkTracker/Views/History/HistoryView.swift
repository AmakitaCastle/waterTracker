import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: HistoryViewModel
    @State private var selectedCell: HeatmapDay?

    init() {
        let store = DrinkStore(context: CoreDataStack.shared.viewContext)
        _viewModel = StateObject(wrappedValue: HistoryViewModel(drinkStore: store))
    }

    var body: some View {
        ZStack {
            // 奶油白背景
            DesignTokens.creamWhite

            // 环境氛围光晕
            atmosphericGlows

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // 顶部标题区
                        HistoryHeaderView()

                        // 热力图卡片
                        HeatmapGridView(
                            viewModel: viewModel,
                            selectedCell: $selectedCell
                        )

                        // 日期详情卡（点击触发）
                        if let selectedDate = viewModel.selectedDate {
                            DateDetailCard(
                                viewModel: viewModel,
                                cups: viewModel.selectedDateCups,
                                records: viewModel.selectedDateRecords,
                                onDismiss: { viewModel.clearSelection() }
                            )
                            .id("dateDetail")
                        }

                        // 底部间距（为底部导航栏留空间）
                        Spacer(minLength: 20)
                    }
                }
                .onChange(of: viewModel.selectedDate) { _ in
                    if viewModel.selectedDate != nil {
                        withAnimation {
                            proxy.scrollTo("dateDetail", anchor: .top)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadAllData()
        }
    }

    // MARK: - Atmospheric Glows

    private var atmosphericGlows: some View {
        ZStack {
            // 左上角光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignTokens.lightMint.opacity(0.4), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .blur(radius: 80)
                .offset(x: -100, y: -100)

            // 右下角光晕
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DesignTokens.paleGreen.opacity(0.5), .clear],
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 250
                    )
                )
                .blur(radius: 80)
                .offset(x: 100, y: 100)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    HistoryView()
}
