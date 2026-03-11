import SwiftUI
import CoreData

struct TodayView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: TodayViewModel
    @State private var showingAddDrink = false
    @State private var addButtonScale: Double = 1.0

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
        if viewModel.progress < 0.3 { return Color.orange }
        else if viewModel.progress < 0.6 { return Color.blue }
        else if viewModel.progress < 1.0 { return Color.green }
        else { return Color.green }
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
        NavigationView {
            VStack(spacing: 20) {
                // 顶部标题区
                VStack(alignment: .leading, spacing: 4) {
                    Text(dateString)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.gray)
                        .tracking(2)

                    Text("今日饮水")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)

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
            .background(Color(red: 0.98, green: 0.97, blue: 0.89))
            .navigationBarHidden(true)
            .sheet(isPresented: $showingAddDrink) {
                AddDrinkView(drinkTypes: viewModel.drinkTypes.isEmpty ?
                             DrinkStore(context: context).getDrinkTypes() :
                             viewModel.drinkTypes) {
                    viewModel.loadTodayData()
                }
            }
        }
    }

    // MARK: - Subviews

    private var liquidProgressCard: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.1, green: 0.1, blue: 0.18))
                .frame(height: 280)

            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(stateColor.opacity(0.3))
                        .frame(height: geometry.size.height * min(viewModel.progress, 1.0))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: viewModel.progress)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24))

            VStack(spacing: 16) {
                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(viewModel.todayTotal)")
                        .font(.system(size: 88, weight: .bold))
                        .foregroundColor(.white)

                    Text("/ \(viewModel.dailyGoal) 杯")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }

                HStack(spacing: 8) {
                    Circle()
                        .fill(stateColor)
                        .frame(width: 8, height: 8)
                        .shadow(color: stateColor, radius: 4)

                    Text(stateText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)

                    Image(systemName: stateIcon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.white.opacity(0.15)))

                Spacer()

                VStack(spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(stateColor)
                                .frame(width: geo.size.width * min(viewModel.progress, 1), height: 6)
                                .shadow(color: stateColor, radius: 3)
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
                .foregroundColor(.blue)

            Text(quote)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
                Text("+")
                    .rotationEffect(.degrees(addButtonScale == 0.97 ? 90 : 0))
                    .animation(.spring(response: 0.2), value: addButtonScale)
                Text("添加一杯饮水")
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(red: 0.1, green: 0.1, blue: 0.18))
            .cornerRadius(16)
        }
        .scaleEffect(addButtonScale)
        .padding(.horizontal, 20)
    }

    private var recordsList: some View {
        Group {
            if !viewModel.recentRecords.isEmpty {
                VStack(spacing: 10) {
                    ForEach(viewModel.recentRecords) { record in
                        recordItem(for: record)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }

    private func recordItem(for record: DrinkRecord) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: record.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("\(record.cups) 杯\(record.drinkTypeName)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)

                Text("约 \(record.cups * 250)ml")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(formatTime(record.date))
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .background(RoundedRectangle(cornerRadius: 12).fill(.ultraThinMaterial))
        )
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
