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
        NavigationView {
            Form {
                Section(header: Text("每日目标")) {
                    Stepper("每日杯数：\(viewModel.dailyGoal)", value: $viewModel.dailyGoal, in: 1...20)
                        .onChange(of: viewModel.dailyGoal) { newValue in
                            viewModel.updateDailyGoal(newValue)
                        }
                }

                Section(header: Text("数据")) {
                    Button("重置所有数据", role: .destructive) {
                        showingResetConfirmation = true
                    }
                }

                Section(header: Text("关于")) {
                    Text("饮水助手 v1.0")
                    Text("记录你每天的饮水量")
                }
            }
            .navigationTitle("设置")
            .confirmationDialog("重置数据", isPresented: $showingResetConfirmation) {
                Button("重置", role: .destructive) {
                    resetData()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("确定要删除所有饮水记录吗？此操作无法撤销。")
            }
            .onChange(of: showingResetSuccess) { newValue in
                if newValue {
                    // Reset flag after animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showingResetSuccess = false
                    }
                }
            }
            .overlay(
                Group {
                    if showingResetSuccess {
                        VStack {
                            Spacer()
                            Text("数据已重置")
                                .font(.system(size: 16))
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.bottom, 50)
                        }
                    }
                }
            )
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
        showingResetSuccess = true
    }
}
