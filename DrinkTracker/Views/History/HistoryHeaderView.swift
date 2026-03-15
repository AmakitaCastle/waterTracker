import SwiftUI

/// 历史页面顶部标题组件
struct HistoryHeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("饮水历史")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(DesignTokens.deepSeaBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

#Preview {
    HistoryHeaderView()
        .background(DesignTokens.creamWhite)
}
