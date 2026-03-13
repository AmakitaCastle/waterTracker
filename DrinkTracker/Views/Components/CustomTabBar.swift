import SwiftUI

/// 自定义底部导航栏
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]

    struct TabItem {
        let id: Int
        let title: String
        let icon: String
    }

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.id) { tab in
                TabBarButton(
                    title: tab.title,
                    icon: tab.icon,
                    isSelected: selectedTab == tab.id,
                    action: { selectedTab = tab.id }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(DesignTokens.glassBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(DesignTokens.glassBorder, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

/// 单个 Tab 按钮
struct TabBarButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    // 激活状态背景块
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(DesignTokens.lightBlueBg)
                            .frame(width: 44, height: 36)
                    }

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .bold : .regular))
                        .foregroundColor(.black)
                }

                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    CustomTabBar(
        selectedTab: .constant(1),
        tabs: [
            CustomTabBar.TabItem(id: 0, title: "今日", icon: "drop.fill"),
            CustomTabBar.TabItem(id: 1, title: "历史", icon: "calendar"),
            CustomTabBar.TabItem(id: 2, title: "设置", icon: "gearshape.fill")
        ]
    )
    .background(DesignTokens.creamWhite)
}
