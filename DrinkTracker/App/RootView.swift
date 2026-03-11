import SwiftUI

struct RootView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        #if os(iOS)
        if UIDevice.current.isPad {
            // iPad layout - NavigationSplitView
            NavigationSplitView {
                List {
                    Button("今日") {
                        selectedTab = 0
                    }
                    .tag(0)

                    Button("历史") {
                        selectedTab = 1
                    }
                    .tag(1)

                    Button("设置") {
                        selectedTab = 2
                    }
                    .tag(2)
                }
                .navigationTitle("饮水助手")
                .listStyle(.sidebar)
            } detail: {
                switch selectedTab {
                case 0: TodayView()
                case 1: HistoryView()
                case 2: SettingsView()
                default: TodayView()
                }
            }
        } else {
            // iPhone layout - TabView
            TabView {
                TodayView()
                    .tabItem {
                        Label("今日", systemImage: "drop.fill")
                    }

                HistoryView()
                    .tabItem {
                        Label("历史", systemImage: "calendar")
                    }

                SettingsView()
                    .tabItem {
                        Label("设置", systemImage: "gearshape.fill")
                    }
            }
        }
        #else
        // macOS fallback - TabView
        TabView {
            TodayView()
                .tabItem {
                    Label("今日", systemImage: "drop.fill")
                }

            HistoryView()
                .tabItem {
                    Label("历史", systemImage: "calendar")
                }

            SettingsView()
                .tabItem {
                    Label("设置", systemImage: "gearshape.fill")
                }
        }
        #endif
    }
}
