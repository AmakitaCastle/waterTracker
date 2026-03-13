import SwiftUI

/// 设计令牌 - 深海蓝主题
struct DesignTokens {
    // MARK: - 基础主题色

    /// 奶油白背景 #faf7f2
    static let creamWhite = Color(hex: "faf7f2")

    // MARK: - 深海蓝主题色

    /// 主深海蓝 #1a1a2e
    static let deepSeaBlue = Color(hex: "1a1a2e")

    /// 深蓝文字 #1e3a8a
    static let darkBlue = Color(hex: "1e3a8a")

    /// 中蓝 #2563eb
    static let mediumBlue = Color(hex: "2563eb")

    /// 天蓝 #60a5fa
    static let skyBlue = Color(hex: "60a5fa")

    /// 浅天蓝 #bfdbfe
    static let lightSkyBlue = Color(hex: "bfdbfe")

    /// 极浅蓝 #e8e4de
    static let paleBlue = Color(hex: "e8e4de")

    /// 高亮蓝 #93c5fd (今日高亮)
    static let highlightBlue = Color(hex: "93c5fd")

    /// 浅蓝背景 #dbeafe (导航激活状态)
    static let lightBlueBg = Color(hex: "dbeafe")

    // MARK: - 设置页专用颜色

    /// 暖米白背景 #F5F3EE (设置页背景)
    static let warmBackground = Color(hex: "F5F3EE")

    /// 步进器背景 #F0EDE6 (浅暖灰底)
    static let stepperBackground = Color(hex: "F0EDE6")

    /// 浅蓝色图标徽章 #E3F2FD (饮水相关)
    static let iconBadgeBlue = Color(hex: "E3F2FD")

    /// 浅橙色图标徽章 #FFF3E0 (提醒功能)
    static let iconBadgeOrange = Color(hex: "FFF3E0")

    /// 浅红色图标徽章 #FFEBEE (危险操作)
    static let iconBadgeRed = Color(hex: "FFEBEE")

    /// 浅灰色图标徽章 #F5F5F5 (中性信息)
    static let iconBadgeGray = Color(hex: "F5F5F5")

    /// 主题蓝 #3D85C6 (与主色调一致)
    static let primaryBlue = Color(hex: "3D85C6")

    /// 浅灰文字 #9E9E9E (分区标签)
    static let sectionLabelGray = Color(hex: "9E9E9E")

    /// 分隔线颜色 #E0E0E0
    static let dividerColor = Color(hex: "E0E0E0")

    // MARK: - 状态颜色

    /// 低进度橙色 #fb923c (保持不变)
    static let stateOrange = Color(hex: "fb923c")

    /// 中进度天蓝 #60a5fa
    static let stateTeal = Color(hex: "60a5fa")

    /// 高进度深蓝 #2563eb
    static let stateEmerald = Color(hex: "2563eb")

    // MARK: - 热力图五阶颜色

    /// 0 杯 - 极浅蓝灰 #e8e4de
    static let heatmapZero = Color(hex: "e8e4de")

    /// 1-2 杯 - 浅天蓝 #bfdbfe
    static let heatmapLow = Color(hex: "bfdbfe")

    /// 3-4 杯 - 天蓝 #60a5fa
    static let heatmapMedium = Color(hex: "60a5fa")

    /// 5-6 杯 - 中蓝 #2563eb
    static let heatmapHigh = Color(hex: "2563eb")

    /// 7-8+ 杯 - 深海蓝 #1e3a8a
    static let heatmapVeryHigh = Color(hex: "1e3a8a")

    // MARK: - 玻璃拟态效果

    /// 玻璃底色 rgba(255,255,255,0.72)
    static let glassBackground = Color(red: 1, green: 1, blue: 1, opacity: 0.72)

    /// 玻璃边框 rgba(30,58,138,0.12)
    static let glassBorder = Color(red: 30/255, green: 58/255, blue: 138/255, opacity: 0.12)

    // MARK: - 渐变色

    /// 主卡片渐变 (白 → 浅蓝)
    static let cardGradient = LinearGradient(
        colors: [Color.white, Color(hex: "dbeafe").opacity(0.8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// 水位渐变 (蓝色系)
    static let waterGradient = LinearGradient(
        colors: [Color(hex: "93c5fd"), Color(hex: "60a5fa")],
        startPoint: .bottom,
        endPoint: .top
    )

    /// 趋势条渐变 (蓝色 → 深蓝)
    static let trendBarGradient = LinearGradient(
        colors: [Color(hex: "3b82f6"), Color(hex: "1e3a8a")],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - 阴影

    /// 外阴影 - 柔和投影 Y:4px blur:24px
    static let outerShadow = Color.black.opacity(0.08)

    /// 内阴影 - 极细白色内阴影
    static let innerShadow = Color.white.opacity(0.4)

    // MARK: - 向后兼容的别名（旧薄荷绿主题）

    /// 向后兼容：映射到天蓝 #60a5fa
    static let mintGreen = DesignTokens.skyBlue

    /// 向后兼容：映射到深海蓝 #1a1a2e
    static let darkTeal = DesignTokens.deepSeaBlue

    /// 向后兼容：映射到中蓝 #2563eb
    static let mediumTeal = DesignTokens.mediumBlue

    /// 向后兼容：映射到浅天蓝 #bfdbfe
    static let lightMint = DesignTokens.lightSkyBlue

    /// 向后兼容：映射到极浅蓝灰 #e8e4de
    static let paleGreen = DesignTokens.paleBlue

    /// 向后兼容：映射到浅蓝背景 #dbeafe
    static let mintBg = DesignTokens.lightBlueBg

    // MARK: - 热力图日历新主题色（深藏蓝）

    /// 深藏蓝背景 #212D3D（热力图卡片背景）
    static let calendarBackground = Color(hex: "212D3D")

    /// 日历格子默认背景 #2D3A4B（无数据状态）
    static let calendarCellDefault = Color(hex: "2D3A4B")

    /// 日历次要文本 #8A96A3
    static let calendarSecondaryText = Color(hex: "8A96A3")

    /// 日历高亮描边 #5BA3F5
    static let calendarHighlightStroke = Color(hex: "5BA3F5")

    /// 日历白色文本
    static let calendarWhiteText = Color.white

    // MARK: - 日历热力图三阶颜色（新设计）

    /// 无数据 - 深灰色 #2D3A4B
    static let calendarLevelZero = Color(hex: "2D3A4B")

    /// 少量数据 - 中蓝色 #3B6FA0
    static let calendarLevelLow = Color(hex: "3B6FA0")

    /// 中等数据 - 亮蓝色 #5BA3F5
    static let calendarLevelMedium = Color(hex: "5BA3F5")

    /// 大量数据 - 深蓝亮色 #2563EB
    static let calendarLevelHigh = Color(hex: "2563EB")
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
