import SwiftUI

@main
struct Zone66App: App {
    @StateObject private var theme = Zone66Theme.shared
    @StateObject private var repository = ChannelRepository.shared
    @StateObject private var settings = Zone66Settings.shared
    @StateObject private var network = NetworkMonitor.shared
    @StateObject private var loc = LocalizationManager.shared

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
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
}

struct ZHSplashIntroView: View {
    @EnvironmentObject var theme: Zone66Theme
    var onFinished: () -> Void

    @State private var scale: CGFloat = 0.6
    @State private var opacity: Double = 0.0
    @State private var glowPulse: CGFloat = 1.0
    @State private var ballOffset: CGFloat = -120
    @State private var ballOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // Dark futuristic background
            Color.black.ignoresSafeArea()

            RadialGradient(
                colors: [theme.accent.opacity(0.25), Color.black],
                center: .center,
                startRadius: 20,
                endRadius: 350
            )
            .ignoresSafeArea()

            // Glowing pulsating sphere / aura
            Circle()
                .fill(theme.accent.opacity(0.18))
                .frame(width: 240, height: 240)
                .scaleEffect(glowPulse)
                .blur(radius: 40)

            VStack(spacing: 24) {
                // Ball entry animation
                Image(systemName: soccerball)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(theme.accent)
                    .offset(y: ballOffset)
                    .opacity(ballOpacity)
                    .shadow(color: theme.accent, radius: 10)

                // ZH Logo Badge
                ZStack {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [theme.accent, theme.accent.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                        .shadow(color: theme.accent.opacity(0.8), radius: 16)

                    BundledImageView(name: "zh_logo", ext: "png", placeholder: "tv.fill")
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                }
                .scaleEffect(scale)
                .opacity(opacity)

                VStack(spacing: 8) {
                    Text("ZH TEAM TV PRO")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(2)

                    Text("المشغل الملكي للبث المباشر")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(theme.accent)
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                scale = 1.0
                opacity = 1.0
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.2)) {
                ballOffset = 0
                ballOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glowPulse = 1.35
            }

            // Dismiss intro after 2.4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                onFinished()
            }
        }
    }
}
