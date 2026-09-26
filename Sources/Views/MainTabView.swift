import SwiftUI

struct MainTabView: View {
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

            FavoritesView()
                .tabItem {
                    Label("المفضلة", systemImage: "heart.fill")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("الإعدادات", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .accentColor(.orange)
    }
}
