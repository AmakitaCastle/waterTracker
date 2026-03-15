import SwiftUI

struct RootView: View {
    @State private var selectedTab: Int = 0

    private let tabs: [CustomTabBar.TabItem] = [
        CustomTabBar.TabItem(id: 0, title: "今日", icon: "drop.fill"),
        CustomTabBar.TabItem(id: 1, title: "历史", icon: "calendar"),
        CustomTabBar.TabItem(id: 2, title: "设置", icon: "gearshape.fill")
    ]

    var body: some View {
        ZStack {
            // 背景色
            DesignTokens.creamWhite
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 主内容区
                TabContentView(selectedTab: selectedTab)

                Spacer()

                // 自定义底部导航栏
                CustomTabBar(selectedTab: $selectedTab, tabs: tabs)
            }
        }
    }
}

/// 内容视图
struct TabContentView: View {
    let selectedTab: Int

    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                TodayView()
                    .transition(.opacity)
            case 1:
                HistoryView()
                    .transition(.opacity)
            case 2:
                SettingsView()
                    .transition(.opacity)
            default:
                TodayView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: selectedTab)
    }
}

#Preview {
    RootView()
}
