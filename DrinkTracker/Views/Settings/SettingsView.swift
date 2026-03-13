import CoreData
import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: SettingsViewModel
    @State private var showingResetConfirmation = false
    @State private var showingResetSuccess = false

    init() {
        let store = DrinkStore(context: CoreDataStack.shared.viewContext)
        _viewModel = StateObject(wrappedValue: SettingsViewModel(drinkStore: store))
    }

    var body: some View {
        ZStack {
            // 暖米白背景
            DesignTokens.warmBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部大标题
                SettingsHeaderView()

                ScrollView {
                    VStack(spacing: 24) {
                        // 每日目标分组
                        SettingsSectionCard(title: "每日目标") {
                            VStack(spacing: 0) {
                                // 每日杯数步进器
                                SettingsStepperRow(
                                    icon: "drop.fill",
                                    iconColor: DesignTokens.iconBadgeBlue,
                                    iconForegroundColor: DesignTokens.primaryBlue,
                                    title: "每日杯数",
                                    value: viewModel.dailyGoal,
                                    range: 1...20,
                                    onChange: { newValue in
                                        viewModel.updateDailyGoal(newValue)
                                    }
                                )

                                Divider()
                                    .background(DesignTokens.dividerColor)
                                    .padding(.leading, 56)

                                // 饮水提醒开关
                                SettingsToggleRow(
                                    icon: "bell.fill",
                                    iconColor: DesignTokens.iconBadgeOrange,
                                    iconForegroundColor: DesignTokens.stateOrange,
                                    title: "饮水提醒",
                                    isOn: $viewModel.isReminderEnabled
                                )
                            }
                        }

                        // 数据分组
                        SettingsSectionCard(title: "数据") {
                            Button(action: {
                                showingResetConfirmation = true
                            }) {
                                SettingsRow(
                                    icon: "trash.fill",
                                    iconColor: DesignTokens.iconBadgeRed,
                                    iconForegroundColor: Color.red,
                                    title: "重置所有数据",
                                    isDestructive: true,
                                    showArrow: true
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        // 关于分组
                        SettingsSectionCard(title: "关于") {
                            SettingsRow(
                                icon: "info.circle.fill",
                                iconColor: DesignTokens.iconBadgeGray,
                                iconForegroundColor: DesignTokens.sectionLabelGray,
                                title: "应用版本",
                                trailing: {
                                    Text("1.0.0")
                                        .font(.system(size: 16))
                                        .foregroundColor(DesignTokens.sectionLabelGray)
                                }
                            )
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
            }
        }
        .alert("重置所有数据", isPresented: $showingResetConfirmation) {
            Button("取消", role: .cancel) {}
            Button("重置", role: .destructive) {
                resetData()
            }
        } message: {
            Text("确定要删除所有饮水记录吗？此操作无法撤销。")
        }
        .overlay(
            Group {
                if showingResetSuccess {
                    VStack {
                        Spacer()
                        Text("数据已重置")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.75))
                            )
                            .padding(.bottom, 100)
                    }
                    .transition(.opacity)
                }
            }
        )
        .onChange(of: showingResetSuccess) { newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showingResetSuccess = false
                    }
                }
            }
        }
    }

    private func resetData() {
        // Delete all entries
        let entryRequest: NSFetchRequest<DrinkEntry> = DrinkEntry.fetchRequest()
        let entries = (try? context.fetch(entryRequest)) ?? []
        entries.forEach { context.delete($0) }

        // Delete custom drink types (keep presets)
        let drinkTypeRequest: NSFetchRequest<DrinkType> = DrinkType.fetchRequest()
        drinkTypeRequest.predicate = NSPredicate(format: "isPreset == NO")
        let drinkTypes = (try? context.fetch(drinkTypeRequest)) ?? []
        drinkTypes.forEach { context.delete($0) }

        try? context.save()

        // Show success message
        withAnimation {
            showingResetSuccess = true
        }
    }
}

// MARK: - Settings Header View

struct SettingsHeaderView: View {
    var body: some View {
        HStack {
            Text("设置")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(DesignTokens.darkBlue)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}

// MARK: - Settings Section Card

struct SettingsSectionCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 分区标签
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignTokens.sectionLabelGray)
                .padding(.leading, 4)

            // 白色圆角卡片
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(DesignTokens.dividerColor.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

// MARK: - Settings Row

struct SettingsRow<Trailing: View>: View {
    let icon: String
    let iconColor: Color
    let iconForegroundColor: Color
    let title: String
    let isDestructive: Bool
    let showArrow: Bool
    @ViewBuilder let trailing: Trailing

    init(
        icon: String,
        iconColor: Color,
        iconForegroundColor: Color,
        title: String,
        isDestructive: Bool = false,
        showArrow: Bool = false,
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.iconForegroundColor = iconForegroundColor
        self.title = title
        self.isDestructive = isDestructive
        self.showArrow = showArrow
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: 12) {
            // 图标徽章
            RoundedRectangle(cornerRadius: 8)
                .fill(iconColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconForegroundColor)
                )

            // 标题
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isDestructive ? Color.red : DesignTokens.darkBlue)

            Spacer()

            // 尾部内容
            trailing

            // 箭头
            if showArrow {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(DesignTokens.sectionLabelGray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let iconColor: Color
    let iconForegroundColor: Color
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            // 图标徽章
            RoundedRectangle(cornerRadius: 8)
                .fill(iconColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconForegroundColor)
                )

            // 标题
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignTokens.darkBlue)

            Spacer()

            // Toggle 开关
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: DesignTokens.primaryBlue))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Settings Stepper Row

struct SettingsStepperRow: View {
    let icon: String
    let iconColor: Color
    let iconForegroundColor: Color
    let title: String
    @State var value: Int
    let range: ClosedRange<Int>
    let onChange: (Int) -> Void

    init(
        icon: String,
        iconColor: Color,
        iconForegroundColor: Color,
        title: String,
        value: Int,
        range: ClosedRange<Int>,
        onChange: @escaping (Int) -> Void
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.iconForegroundColor = iconForegroundColor
        self.title = title
        self._value = State(initialValue: value)
        self.range = range
        self.onChange = onChange
    }

    var body: some View {
        HStack(spacing: 12) {
            // 图标徽章
            RoundedRectangle(cornerRadius: 8)
                .fill(iconColor)
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconForegroundColor)
                )

            // 标题
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(DesignTokens.darkBlue)

            Spacer()

            // 自定义步进器
            HStack(spacing: 0) {
                // 减号按钮
                Button(action: {
                    if value > range.lowerBound {
                        value -= 1
                        onChange(value)
                    }
                }) {
                    Text("−")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DesignTokens.primaryBlue)
                        .frame(width: 36, height: 32)
                }

                // 分隔线
                Rectangle()
                    .fill(DesignTokens.dividerColor)
                    .frame(width: 1, height: 20)

                // 数值显示
                Text("\(value)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(DesignTokens.primaryBlue)
                    .frame(width: 44, height: 32)

                // 分隔线
                Rectangle()
                    .fill(DesignTokens.dividerColor)
                    .frame(width: 1, height: 20)

                // 加号按钮
                Button(action: {
                    if value < range.upperBound {
                        value += 1
                        onChange(value)
                    }
                }) {
                    Text("+")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(DesignTokens.primaryBlue)
                        .frame(width: 36, height: 32)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignTokens.stepperBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(DesignTokens.dividerColor, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
