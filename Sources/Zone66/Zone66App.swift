import SwiftUI

final class AppResetManager: ObservableObject {
    static let shared = AppResetManager()
    @Published var restartToken: UUID = UUID()
    @Published var isRestarting: Bool = false

    func restartApp() {
        // Clear all URL and data caches
        URLCache.shared.removeAllCachedResponses()

        // Reset player & app settings
        Zone66Settings.shared.resetToDefaults()

        // Reload data from local and sync
        ChannelRepository.shared.resetAndReload()

        // Smoothly restart app hierarchy
        DispatchQueue.main.async {
            self.isRestarting = true
            self.restartToken = UUID()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.isRestarting = false
                }
            }
        }
    }
}

@main
struct Zone66App: App {
    @StateObject private var theme = Zone66Theme.shared
    @StateObject private var repository = ChannelRepository.shared
    @StateObject private var settings = Zone66Settings.shared
    @StateObject private var network = NetworkMonitor.shared
    @StateObject private var loc = LocalizationManager.shared
    @StateObject private var resetManager = AppResetManager.shared

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash || resetManager.isRestarting {
                    ZHSplashIntroView {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            showSplash = false
                        }
                    }
                    .environmentObject(theme)
                    .transition(.opacity)
                } else {
                    if network.isConnected {
                        MainTabView()
                            .environmentObject(theme)
                            .environmentObject(repository)
                            .environmentObject(settings)
                            .environmentObject(loc)
                            .environmentObject(network)
                            .environmentObject(resetManager)
                            .environment(\.layoutDirection, loc.currentLanguage.layoutDirection)
                            .preferredColorScheme(.dark)
                            .accentColor(theme.accent)
                            .id("\(loc.currentLanguage.rawValue)-\(resetManager.restartToken)")
                    } else {
                        NoInternetView()
                            .environmentObject(theme)
                            .environment(\.layoutDirection, loc.currentLanguage.layoutDirection)
                    }
                }
            }
        }
    }
}

struct ZHSplashIntroView: View {
    var onFinished: () -> Void
    @EnvironmentObject var theme: Zone66Theme

    @State private var logoScale: CGFloat = 0.7
    @State private var logoOpacity: Double = 0.0

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(theme.accent.opacity(0.12))
                        .frame(width: 140, height: 140)

                    Circle()
                        .stroke(theme.accent.opacity(0.3), lineWidth: 2)
                        .frame(width: 120, height: 120)

                    BundledImageView(name: "zh_logo", ext: "png", placeholder: "tv.fill")
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .shadow(color: theme.accent.opacity(0.7), radius: 12)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                VStack(spacing: 6) {
                    Text("ZH TEAM")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)

                    Text("ROYAL LIVE TV PRO")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(theme.accent)
                        .tracking(3)
                }
                .opacity(logoOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                onFinished()
            }
        }
    }
}

struct NoInternetView: View {
    @EnvironmentObject var theme: Zone66Theme
    @ObservedObject var loc = LocalizationManager.shared

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 60))
                    .foregroundColor(theme.accent)

                Text(loc.tr("no_internet_title"))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Text(loc.tr("no_internet_desc"))
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Button {
                    NetworkMonitor.shared.checkConnection()
                } label: {
                    Text(loc.tr("retry"))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(theme.accent)
                        .clipShape(Capsule())
                }
            }
        }
    }
}
