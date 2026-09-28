import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var theme: Zone66Theme
    @ObservedObject var loc = LocalizationManager.shared

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label(loc.tr("matches_today"), systemImage: "sportscourt.fill")
                }

            ChannelsView()
                .tabItem {
                    Label(loc.tr("channels"), systemImage: "tv.fill")
                }

            FavoritesView()
                .tabItem {
                    Label(loc.tr("favorites"), systemImage: "star.fill")
                }

            SettingsView()
                .tabItem {
                    Label(loc.tr("settings"), systemImage: "gearshape.fill")
                }
        }
        .accentColor(theme.accent)
    }
}
