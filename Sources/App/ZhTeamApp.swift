import SwiftUI

@main
struct ZhTeamApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var repository = ChannelRepository.shared
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(themeManager)
                .environmentObject(repository)
                .environmentObject(settings)
                .preferredColorScheme(.dark)
                .accentColor(themeManager.currentTheme.accentColor)
        }
    }
}
