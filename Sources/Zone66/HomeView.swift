import SwiftUI

struct HomeView: View {
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @ObservedObject var loc = LocalizationManager.shared

    @State private var selectedFilter: String = "all"
    @State private var playingChannel: Zone66Channel? = nil
    @State private var matchToSelectChannelFor: ZHMatch? = nil
    @State private var isPickerPresented = false

    var filteredMatches: [ZHMatch] {
        switch selectedFilter {
        case "live":
            return repository.matches.filter { $0.isLive }
        case "upcoming":
            return repository.matches.filter { $0.isUpcoming }
        case "finished":
            return repository.matches.filter { $0.isFinished }
        default:
            return repository.matches
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // MARK: - Header Branding Card
                    headerBrandSection

                    // MARK: - Match Filter Tabs
                    filterTabsSection

                    // MARK: - Matches List
                    if filteredMatches.isEmpty {
                        emptyMatchesView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredMatches) { match in
                                MatchCardView(match: match) {
                                    handleMatchPlayback(match)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Spacer for bottom tabs
                    Spacer(minLength: 40)
                }
                .padding(.top, 12)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .fullScreenCover(item: $playingChannel) { channel in
                PlayerView(channel: channel)
            }
            .sheet(isPresented: $isPickerPresented) {
                channelSelectionSheet
            }
            .refreshable {
                repository.refresh()
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Header Section
    private var headerBrandSection: some View {
        HStack(spacing: 14) {
            BundledImageView(name: "zh_logo", ext: "png", placeholder: "tv.fill")
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(theme.accent, lineWidth: 1.5))
                .shadow(color: theme.accent.opacity(0.4), radius: 6)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("ZH TEAM")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text("PRO")
                        .font(.system(size: 10, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.accent)
                        .foregroundColor(.black)
                        .cornerRadius(6)
                }

                Text(loc.tr("matches_today"))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                repository.refresh()
            } label: {
                ZStack {
                    Circle()
                        .fill(theme.card)
                        .frame(width: 40, height: 40)

                    Image(systemName: repository.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(theme.accent)
                        .rotationEffect(.degrees(repository.isSyncing ? 360 : 0))
                        .animation(repository.isSyncing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: repository.isSyncing)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Filter Tabs Section
    private var filterTabsSection: some View {
        HStack(spacing: 8) {
            filterButton(id: "all", title: loc.tr("all"))
            filterButton(id: "live", title: loc.tr("live_now"), isLivePulse: true)
            filterButton(id: "upcoming", title: loc.tr("upcoming"))
            filterButton(id: "finished", title: loc.tr("finished"))
        }
        .padding(.horizontal, 16)
    }

    private func filterButton(id: String, title: String, isLivePulse: Bool = false) -> some View {
        let isSelected = selectedFilter == id
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selectedFilter = id
            }
        } label: {
            HStack(spacing: 6) {
                if isLivePulse {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                }
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? .black : .white.opacity(0.8))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? theme.accent : theme.card)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? theme.accent : Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }

    // MARK: - Empty Matches State
    private var emptyMatchesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "sportscourt")
                .font(.system(size: 44))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 40)

            Text("لا توجد مباريات مسجلة حالياً")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))

            Text("يتم تحديث جدول المباريات تلقائياً عبر لوحة التحكم")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Match Playback Logic
    private func handleMatchPlayback(_ match: ZHMatch) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // 1. Direct stream URL in match
        if let directURL = match.streamURL, !directURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            playingChannel = Zone66Channel(
                id: match.id,
                name: "\(match.team1) vs \(match.team2)",
                category: match.details,
                streamURL: directURL
            )
            return
        }

        // 2. ChannelId specified and matched in repository
        if let chId = match.channelId, let found = repository.channels.first(where: { $0.id == chId }) {
            playingChannel = found
            return
        }

        // 3. ChannelName match in repository
        if let chName = match.channelName, let found = repository.channels.first(where: { $0.name.lowercased().contains(chName.lowercased()) }) {
            playingChannel = found
            return
        }

        // 4. Otherwise, open channel picker
        matchToSelectChannelFor = match
        isPickerPresented = true
    }

    // MARK: - Channel Picker Sheet
    private var channelSelectionSheet: some View {
        NavigationView {
            List(repository.enabledChannels) { ch in
                Button {
                    isPickerPresented = false
                    playingChannel = ch
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "tv")
                            .foregroundColor(theme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(ch.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text(ch.category)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Spacer()
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(theme.accent)
                            .font(.system(size: 20))
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(theme.card)
            }
            .listStyle(InsetGroupedListStyle())
            .background(theme.background.ignoresSafeArea())
            .navigationTitle(loc.tr("choose_channel"))
            .navigationBarItems(trailing: Button("إلغاء") { isPickerPresented = false })
        }
    }
}

// MARK: - Match Card View
struct MatchCardView: View {
    let match: ZHMatch
    let onPlay: () -> Void
    @EnvironmentObject var theme: Zone66Theme
    @ObservedObject var loc = LocalizationManager.shared

    var statusColor: Color {
        if match.isLive { return .red }
        if match.isUpcoming { return theme.accent }
        return .gray
    }

    var statusBadgeText: String {
        if match.isLive { return loc.tr("live_now") }
        if match.isUpcoming { return match.time }
        return loc.tr("finished")
    }

    var body: some View {
        VStack(spacing: 14) {
            // League and Time Info Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11))
                        .foregroundColor(theme.accent)

                    Text(match.details)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }

                Spacer()

                // Status Badge
                HStack(spacing: 5) {
                    if match.isLive {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 5, height: 5)
                    }
                    Text(statusBadgeText)
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(statusColor)
                .cornerRadius(12)
            }

            // Teams Versus Section
            HStack(alignment: .center, spacing: 10) {
                // Team 1
                VStack(spacing: 6) {
                    Text(match.team1Logo)
                        .font(.system(size: 38))
                    Text(match.team1)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity)
                }

                // Score / Time Center
                VStack(spacing: 4) {
                    Text(match.score)
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(match.isLive ? theme.accent : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(10)

                    if !match.date.isEmpty {
                        Text(match.date)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .frame(width: 90)

                // Team 2
                VStack(spacing: 6) {
                    Text(match.team2Logo)
                        .font(.system(size: 38))
                    Text(match.team2)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)

            // Watch Button & Channel Info
            Button(action: onPlay) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .bold))

                    Text(match.channelName ?? loc.tr("watch_now"))
                        .font(.system(size: 14, weight: .bold))

                    Spacer()

                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [theme.accent, theme.accent.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: theme.accent.opacity(0.3), radius: 6, y: 2)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(theme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(match.isLive ? theme.accent.opacity(0.5) : Color.white.opacity(0.08), lineWidth: 1.5)
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 8, y: 4)
    }
}
