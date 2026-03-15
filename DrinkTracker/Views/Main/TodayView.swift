import SwiftUI
import CoreData

struct TodayView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: TodayViewModel
    @State private var showingAddDrink = false
    @State private var addButtonScale: Double = 1.0
    @State private var digitalScale: Double = 1.0
    @State private var showDigitalPop = false

    init() {
        let store = DrinkStore(context: CoreDataStack.shared.viewContext)
        _viewModel = StateObject(wrappedValue: TodayViewModel(drinkStore: store, context: CoreDataStack.shared.viewContext))
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M 月 d 日"
        let month = formatter.string(from: Date())
        let weekFormatter = DateFormatter()
        weekFormatter.locale = Locale(identifier: "zh_CN")
        weekFormatter.dateFormat = "EEEE"
        let week = weekFormatter.string(from: Date())
        return "\(month) \(week)"
    }

    var stateColor: Color {
        if viewModel.progress < 0.3 { return DesignTokens.stateOrange }
        else if viewModel.progress < 0.6 { return DesignTokens.stateTeal }
        else { return DesignTokens.stateEmerald }
    }

    var stateText: String {
        if viewModel.progress < 0.3 { return "需要补水" }
        else if viewModel.progress < 0.6 { return "继续加油" }
        else if viewModel.progress < 1.0 { return "表现不错" }
        else { return "目标达成" }
    }

    var stateIcon: String {
        if viewModel.progress < 0.3 { return "drop.fill" }
        else if viewModel.progress < 0.6 { return "sparkles" }
        else if viewModel.progress < 1.0 { return "waveform" }
        else { return "party.popper.fill" }
    }

    var quote: String {
        switch viewModel.todayTotal {
        case 0: return "千里之行，始于足下。今天的第一杯水开始吧！"
        case 1, 2, 3: return "每一滴水都是对身体的关爱。继续前进！"
        case 4, 5, 6: return "你已经走过了一半的路程。保持这个节奏！"
        default: return "太棒了！你离目标越来越近。坚持下去！"
        }
    }

    var percentageText: String {
        "\(Int(min(viewModel.progress * 100, 100)))%"
    }

    var body: some View {
        ZStack {
            // 奶油白背景
            DesignTokens.creamWhite

            // 环境氛围光晕
            atmosphericGlows

            VStack(spacing: 0) {
                // 顶部标题区
                TodayHeaderView(dateString: dateString)

                ScrollView {
                    VStack(spacing: 16) {
                        // 主数据卡片
                        liquidProgressCard

                        // 励志语卡片
                        quoteCard

                        // 添加饮水按钮
                        addDrinkButton

                        // 饮水记录列表
                        recordsList

                        Spacer(minLength: 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddDrink) {
            AddDrinkView(drinkTypes: viewModel.drinkTypes.isEmpty ?
                         DrinkStore(context: context).getDrinkTypes() :
                         viewModel.drinkTypes) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    digitalScale = 1.35
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        digitalScale = 1.0
                    }
                }
                viewModel.loadTodayData()
            }
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

    // MARK: - Subviews

    private var liquidProgressCard: some View {
        ZStack(alignment: .bottom) {
            // 主卡片背景 - 145°对角渐变
            RoundedRectangle(cornerRadius: 24)
                .fill(DesignTokens.cardGradient)
                .frame(height: 280)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(DesignTokens.glassBorder, lineWidth: 1)
                )

            // 水位效果层
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // 水位渐变填充
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [DesignTokens.lightMint, DesignTokens.mediumTeal],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(height: geometry.size.height * min(viewModel.progress, 1.0))
                        .animation(.interpolatingSpring(duration: 0.9, bounce: 0.4), value: viewModel.progress)

                    // 顶部波浪效果
                    if viewModel.progress > 0 {
                        WaveView()
                            .stroke(DesignTokens.mediumTeal.opacity(0.3), lineWidth: 3)
                            .frame(height: 20)
                            .offset(y: -geometry.size.height * min(viewModel.progress, 1.0))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))

            // 内容层
            VStack(spacing: 16) {
                Spacer()

                // 数字显示
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(viewModel.todayTotal)")
                        .font(.system(size: 88, weight: .bold))
                        .foregroundColor(DesignTokens.darkTeal)
                        .scaleEffect(digitalScale)

                    Text("/ \(viewModel.dailyGoal) 杯")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(DesignTokens.mediumTeal)
                }
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        digitalScale = 1.3
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            digitalScale = 1.0
                        }
                    }
                }

                // 状态指示器
                HStack(spacing: 8) {
                    Circle()
                        .fill(stateColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: stateColor, radius: 4)

                    Text(stateText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(DesignTokens.darkTeal)

                    Image(systemName: stateIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(DesignTokens.mediumTeal)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(DesignTokens.glassBackground))
                .overlay(
                    Capsule()
                        .stroke(DesignTokens.glassBorder, lineWidth: 1)
                )

                Spacer()

                // 进度条
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(DesignTokens.paleGreen)
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(stateColor)
                                .frame(width: geo.size.width * min(viewModel.progress, 1), height: 6)
                                .shadow(color: stateColor.opacity(0.5), radius: 3)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Text("")
                        Spacer()
                        Text(percentageText)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(stateColor)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 20)
    }

    private var quoteCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "quote.bubble.fill")
                .font(.system(size: 24))
                .foregroundColor(DesignTokens.mintGreen)

            Text(quote)
                .font(.system(size: 14))
                .foregroundColor(DesignTokens.darkTeal)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignTokens.glassBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignTokens.glassBorder, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }

    private var addDrinkButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                addButtonScale = 0.97
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    addButtonScale = 1.0
                }
            }
            showingAddDrink = true
        }) {
            HStack {
                Image(systemName: "plus")
                    .rotationEffect(.degrees(addButtonScale == 0.97 ? 90 : 0))
                    .animation(.spring(response: 0.2), value: addButtonScale)
                Text("添加一杯饮水")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(DesignTokens.mintGreen)
            .cornerRadius(16)
        }
        .scaleEffect(addButtonScale)
        .padding(.horizontal, 20)
    }

    private var recordsList: some View {
        Group {
            if !viewModel.recentRecords.isEmpty {
                VStack(spacing: 10) {
                    ForEach(viewModel.recentRecords.indices, id: \.self) { index in
                        let record = viewModel.recentRecords[index]
                        recordItem(for: record, index: index)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private func recordItem(for record: DrinkRecord, index: Int) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(DesignTokens.paleGreen)
                    .frame(width: 40, height: 40)

                Image(systemName: record.icon)
                    .font(.system(size: 20))
                    .foregroundColor(DesignTokens.mintGreen)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(record.cups) 杯\(record.drinkTypeName)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(DesignTokens.darkTeal)

                Text("约 \(record.cups * 250)ml")
                    .font(.system(size: 12))
                    .foregroundColor(DesignTokens.mediumTeal)
            }

            Spacer()

            Text(formatTime(record.date))
                .font(.system(size: 14))
                .foregroundColor(DesignTokens.mediumTeal)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(DesignTokens.glassBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(DesignTokens.glassBorder, lineWidth: 1)
        )
        .transition(.asymmetric(
            insertion: .slide.combined(with: .opacity),
            removal: .opacity
        ))
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// MARK: - Wave View for Water Effect

struct WaveView: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: 0, y: height / 2))

        for x in stride(from: 0, through: width, by: 1) {
            let y = sin(x * 0.05) * 5 + height / 2
            path.addLine(to: CGPoint(x: x, y: y))
        }

        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.closeSubpath()

        return path
    }
}
