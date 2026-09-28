import SwiftUI

@main
struct Zone66App: App {
    @StateObject private var theme = Zone66Theme.shared
    @StateObject private var repository = ChannelRepository.shared
    @StateObject private var settings = Zone66Settings.shared
    @StateObject private var network = NetworkMonitor.shared
    @StateObject private var loc = LocalizationManager.shared

    var body: some Scene {
        WindowGroup {
            ZStack {
                if network.isConnected {
                    MainTabView()
                        .environmentObject(theme)
                        .environmentObject(repository)
                        .environmentObject(settings)
                        .environmentObject(loc)
                        .environmentObject(network)
                        .preferredColorScheme(.dark)
                        .accentColor(theme.accent)
                } else {
                    NoInternetView()
                        .environmentObject(theme)
                }
            }
        }
    }
}
