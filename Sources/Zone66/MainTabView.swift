import SwiftUI

public enum AppTab: Int, CaseIterable, Identifiable {
    case matches = 0
    case channels = 1
    case favorites = 2
    case settings = 3

    public var id: Int { rawValue }

    var icon: String {
        switch self {
        case .matches: return "sportscourt.fill"
        case .channels: return "tv.fill"
        case .favorites: return "star.fill"
        case .settings: return "gearshape.fill"
        }
    }

    func title(loc: LocalizationManager) -> String {
        switch self {
        case .matches: return loc.tr("matches_today")
        case .channels: return loc.tr("channels")
        case .favorites: return loc.tr("favorites")
        case .settings: return loc.tr("settings")
        }
    }
}

// Glassmorphism Blur background compatible with iOS 15, 16, 17, 18+
struct GlassBlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style = .systemUltraThinMaterialDark

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

struct FloatingGlassTabBar: View {
    @Binding var selectedTab: AppTab
    @EnvironmentObject var theme: Zone66Theme
    @ObservedObject var loc = LocalizationManager.shared

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selectedTab == tab
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 19, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? theme.accent : .white)
                            .shadow(color: isSelected ? theme.accent.opacity(0.6) : .clear, radius: 6)

                        Text(tab.title(loc: loc))
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? theme.accent : .white.opacity(0.85))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Group {
                            if isSelected {
                                Capsule()
                                    .fill(Color.black.opacity(0.6))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.1), lineWidth: 0.8)
                                    )
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 3)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 6)
        .background(
            ZStack {
                // Glass frosted blur layer
                GlassBlurView(style: .systemUltraThinMaterialDark)
                    .clipShape(Capsule())

                // Dark glass tint
                Capsule()
                    .fill(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.82))

                // Subtle reflective glass stroke
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.28),
                                Color.white.opacity(0.08),
                                Color.white.opacity(0.15)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
            }
        )
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.45), radius: 18, x: 0, y: 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 6)
    }
}

struct MainTabView: View {
    @EnvironmentObject var theme: Zone66Theme
    @ObservedObject var loc = LocalizationManager.shared
    @State private var selectedTab: AppTab = .matches

    var body: some View {
        ZStack(alignment: .bottom) {
            // Keep tabs active in hierarchy to preserve state & fast switching
            ZStack {
                HomeView()
                    .opacity(selectedTab == .matches ? 1 : 0)
                    .allowsHitTesting(selectedTab == .matches)

                ChannelsView()
                    .opacity(selectedTab == .channels ? 1 : 0)
                    .allowsHitTesting(selectedTab == .channels)

                FavoritesView()
                    .opacity(selectedTab == .favorites ? 1 : 0)
                    .allowsHitTesting(selectedTab == .favorites)

                SettingsView()
                    .opacity(selectedTab == .settings ? 1 : 0)
                    .allowsHitTesting(selectedTab == .settings)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Extra bottom safe padding so bottom rows/items are not obscured by floating bar
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 70)
            }

            // Floating Glass Capsule Tab Bar
            FloatingGlassTabBar(selectedTab: $selectedTab)
        }
        .background(theme.background.ignoresSafeArea())
    }
}
