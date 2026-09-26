import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("الرئيسية", systemImage: "sparkles.tv")
                }
                .tag(0)

            ChannelsListView()
                .tabItem {
                    Label("القنوات", systemImage: "play.tv.fill")
                }
                .tag(1)

            ChannelManagerView()
                .tabItem {
                    Label("إدارة القنوات", systemImage: "slider.horizontal.3")
                }
                .tag(2)

            FavoritesView()
                .tabItem {
                    Label("المفضلة", systemImage: "heart.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("الإعدادات", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(themeManager.currentTheme.accentColor)
    }
}
