import SwiftUI

/// 今日页面顶部标题组件
struct TodayHeaderView: View {
    let dateString: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(dateString)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(.gray)
                .tracking(2)

            Text("今日饮水")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(DesignTokens.deepSeaBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

#Preview {
    TodayHeaderView(dateString: "3 月 12 日 星期四")
        .background(DesignTokens.creamWhite)
}
