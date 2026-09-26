import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var theme: Zone66Theme

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("الرئيسية", systemImage: "house.fill")
                }

            ChannelsView()
                .tabItem {
                    Label("القنوات", systemImage: "play.tv.fill")
                }

            FavoritesView()
                .tabItem {
                    Label("المفضلة", systemImage: "heart.fill")
                }

            SettingsView()
                .tabItem {
                    Label("الإعدادات", systemImage: "gearshape.fill")
                }
        }
        .accentColor(theme.accent)
    }
}
