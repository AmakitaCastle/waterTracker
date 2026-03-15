import SwiftUI
import CoreData

struct AddDrinkView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var context
    let drinkTypes: [DrinkType]
    let onAdd: () -> Void

    @State private var selectedDrinkType: DrinkType?
    @State private var cups: Int = 1
    @State private var showAddAnimation: Bool = false

    // 深海蓝 + 奶油白主题颜色
    private let maskColor = Color(red: 26/255, green: 26/255, blue: 46/255) // 深海蓝 #1a1a2e
    private let creamWhite = Color(red: 250/255, green: 247/255, blue: 242/255) // 奶油白 #faf7f2
    private let deepSeaBlue = Color(hex: "1a1a2e") // 深海蓝
    private let creamBeige = Color(hex: "f0ece4") // 奶油米色
    private let paleBlueGray = Color(hex: "b8b8cc") // 极淡蓝灰
    private let mediumBlueGray = Color(hex: "4a4a6a") // 中度蓝灰

    var body: some View {
        ZStack {
            // 背景遮罩 - 深海蓝调模糊
            maskColor
                .opacity(0.22)
                .ignoresSafeArea()
                .blur(radius: 4)

            // Bottom Sheet 内容
            BottomSheetContent(
                drinkTypes: drinkTypes,
                selectedDrinkType: $selectedDrinkType,
                cups: $cups,
                showAddAnimation: $showAddAnimation,
                deepSeaBlue: deepSeaBlue,
                creamBeige: creamBeige,
                paleBlueGray: paleBlueGray,
                mediumBlueGray: mediumBlueGray,
                onCancel: {
                    dismiss()
                },
                onAdd: {
                    addDrink()
                }
            )
            .background(creamWhite.opacity(0.98))
            .background(.ultraThinMaterial)
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(Color.clear)
        .animation(.easeInOut(duration: 0.1), value: selectedDrinkType)
    }

    private func addDrink() {
        guard let drinkType = selectedDrinkType else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showAddAnimation = true
        }

        let store = DrinkStore(context: context)
        store.addEntry(drinkTypeId: drinkType.id, cups: cups, date: Date())

        try? context.save()

        // Check for reminder
        let total = store.getTodayTotal()
        let goal = store.getDailyGoal()
        if Double(total) / Double(goal) >= 0.5 {
            NotificationManager.shared.scheduleHalfGoalNotification()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onAdd()
            dismiss()
        }
    }
}

// MARK: - Bottom Sheet Content
struct BottomSheetContent: View {
    let drinkTypes: [DrinkType]
    @Binding var selectedDrinkType: DrinkType?
    @Binding var cups: Int
    @Binding var showAddAnimation: Bool
    let deepSeaBlue, creamBeige, paleBlueGray, mediumBlueGray: Color
    let onCancel: () -> Void
    let onAdd: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 拖动条
            DragHandle(deepSeaBlue: deepSeaBlue)

            // 标题栏
            TitleBar(
                deepSeaBlue: deepSeaBlue,
                creamBeige: creamBeige,
                mediumBlueGray: mediumBlueGray,
                onCancel: onCancel,
                onAdd: onAdd,
                canAdd: selectedDrinkType != nil
            )

            // 分隔线
            GradientDivider(deepSeaBlue: deepSeaBlue)

            // 饮品类型选择区
            DrinkTypeSection(
                drinkTypes: drinkTypes,
                selectedType: $selectedDrinkType,
                deepSeaBlue: deepSeaBlue,
                creamBeige: creamBeige,
                paleBlueGray: paleBlueGray,
                mediumBlueGray: mediumBlueGray
            )

            // 分隔线
            GradientDivider(deepSeaBlue: deepSeaBlue)

            // 杯数选择区
            CupCountSection(
                cups: $cups,
                selectedType: selectedDrinkType,
                deepSeaBlue: deepSeaBlue,
                creamBeige: creamBeige,
                paleBlueGray: paleBlueGray,
                showAddAnimation: $showAddAnimation
            )
        }
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .stroke(deepSeaBlue.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: deepSeaBlue.opacity(0.15), radius: 20, x: 0, y: -8)
    }
}

// MARK: - Drag Handle
struct DragHandle: View {
    let deepSeaBlue: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(deepSeaBlue.opacity(0.15))
            .frame(width: 36, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 12)
    }
}

// MARK: - Title Bar
struct TitleBar: View {
    let deepSeaBlue, creamBeige, mediumBlueGray: Color
    let onCancel: () -> Void
    let onAdd: () -> Void
    let canAdd: Bool

    var body: some View {
        HStack {
            // 取消按钮
            Button(action: onCancel) {
                Text("取消")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(mediumBlueGray)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(creamBeige)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(deepSeaBlue.opacity(0.2), lineWidth: 1)
                            )
                    )
                    .shadow(color: deepSeaBlue.opacity(0.1), radius: 2, x: 0, y: 1)
            }

            Spacer()

            // 标题
            Text("添加饮水")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(deepSeaBlue)

            Spacer()

            // 添加按钮
            Button(action: onAdd) {
                Text("添加")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(deepSeaBlue)
                    .cornerRadius(12)
                    .shadow(color: deepSeaBlue.opacity(0.22), radius: 4, x: 0, y: 4)
            }
            .disabled(!canAdd)
            .opacity(canAdd ? 1 : 0.5)
        }
        .padding(.horizontal, 0)
    }
}

// MARK: - Gradient Divider
struct GradientDivider: View {
    let deepSeaBlue: Color

    var body: some View {
        HStack {
            Color.clear.frame(width: 22)
            deepSeaBlue.opacity(0.08)
                .frame(height: 0.5)
            Color.clear.frame(width: 22)
        }
        .padding(.vertical, 14)
    }
}

// MARK: - Drink Type Section
struct DrinkTypeSection: View {
    let drinkTypes: [DrinkType]
    @Binding var selectedType: DrinkType?
    let deepSeaBlue, creamBeige, paleBlueGray, mediumBlueGray: Color

    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 小标签
            Text("饮品类型")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(paleBlueGray)
                .tracking(0.15)

            // 饮品网格
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(drinkTypes, id: \.id) { type in
                    DrinkCard(
                        drinkType: type,
                        isSelected: selectedType?.id == type.id,
                        deepSeaBlue: deepSeaBlue,
                        creamBeige: creamBeige,
                        paleBlueGray: paleBlueGray,
                        mediumBlueGray: mediumBlueGray
                    )
                    .onTapGesture {
                        withAnimation(.timingCurve(0.25, 0.1, 0.25, 1, duration: 0.25)) {
                            selectedType = type
                        }
                    }
                }
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Drink Card
struct DrinkCard: View {
    let drinkType: DrinkType
    let isSelected: Bool
    let deepSeaBlue, creamBeige, paleBlueGray, mediumBlueGray: Color

    var body: some View {
        VStack(spacing: 8) {
            // Emoji 底托方块
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? deepSeaBlue.opacity(0.12) : creamBeige)
                    .frame(width: 38, height: 38)

                Image(systemName: drinkType.icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : deepSeaBlue.opacity(0.8))
            }
            .animation(.easeInOut(duration: 0.2), value: isSelected)

            // 饮品名称
            Text(drinkType.name)
                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : mediumBlueGray)
                .animation(.easeInOut(duration: 0.2), value: isSelected)

            // 选中指示条（仅选中时显示）
            if isSelected {
                RoundedRectangle(cornerRadius: 2)
                    .fill(.white.opacity(0.8))
                    .frame(width: 16, height: 3)
                    .transition(.scale(scale: 0.8, anchor: .center).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? deepSeaBlue : Color.white.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? deepSeaBlue : deepSeaBlue.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: deepSeaBlue.opacity(isSelected ? 0.2 : 0.05), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
        .scaleEffect(isSelected ? 1.04 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Cup Count Section
struct CupCountSection: View {
    @Binding var cups: Int
    let selectedType: DrinkType?
    let deepSeaBlue, creamBeige, paleBlueGray: Color
    @Binding var showAddAnimation: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 小标签
            Text("多少杯？")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(paleBlueGray)
                .tracking(0.15)

            // 杯数卡片
            HStack(spacing: 8) {
                // 左侧信息区
                HStack(spacing: 10) {
                    // Emoji 底托
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(creamBeige)
                            .frame(width: 40, height: 40)

                        if let type = selectedType {
                            Image(systemName: type.icon)
                                .font(.system(size: 20))
                                .foregroundColor(deepSeaBlue.opacity(0.8))
                        }
                    }

                    if let type = selectedType {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(type.name)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(deepSeaBlue)
                            Text("\(cups) × 250 = \(cups * 250) ml")
                                .font(.system(size: 11))
                                .foregroundColor(paleBlueGray)
                        }
                    } else {
                        Text("请选择饮品")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(paleBlueGray)
                    }
                }

                Spacer()

                // 右侧步进器
                HStack(spacing: 8) {
                    // 减号按钮
                    Button(action: {
                        if cups > 1 { cups -= 1 }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(cups > 1 ? .white : paleBlueGray)
                            .frame(width: 36, height: 36)
                            .background(
                                Group {
                                    if cups > 1 {
                                        deepSeaBlue
                                    } else {
                                        creamBeige
                                    }
                                }
                            )
                            .cornerRadius(11)
                    }

                    // 数字显示
                    Text("\(cups)")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(deepSeaBlue)
                        .frame(width: 28)

                    // 加号按钮
                    Button(action: {
                        cups += 1
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(deepSeaBlue)
                            .cornerRadius(11)
                            .shadow(color: deepSeaBlue.opacity(0.22), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(18)
            .padding(.trailing, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(deepSeaBlue.opacity(0.15), lineWidth: 1)
                    )
            )
            .shadow(color: deepSeaBlue.opacity(0.05), radius: 4, x: 0, y: 2)
            .scaleEffect(showAddAnimation ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: showAddAnimation)
        }
    }
}
