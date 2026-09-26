import SwiftUI

@main
struct Zone66App: App {
    @StateObject private var theme = Zone66Theme.shared
    @StateObject private var repository = ChannelRepository.shared
    @StateObject private var settings = Zone66Settings.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(theme)
                .environmentObject(repository)
                .environmentObject(settings)
                .preferredColorScheme(.dark)
                .accentColor(theme.accent)
        }
    }
}
