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
                    headerBrandSection
                    filterTabsSection

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

                    Spacer(minLength: 40)
                }
                .padding(.top, 12)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .fullScreenCover(item: $playingChannel) { channel in
                PlayerView(channel: channel)
                    .environmentObject(theme)
                    .environmentObject(repository)
            }
            .sheet(isPresented: $isPickerPresented) {
                if let match = matchToSelectChannelFor {
                    MatchChannelPickerSheet(match: match) { selectedChannel in
                        isPickerPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                playingChannel = selectedChannel
                            }
                        }
                    }
                    .environmentObject(theme)
                    .environmentObject(repository)
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private var headerBrandSection: some View {
        HStack(spacing: 12) {
            BundledImageView(name: "zh_logo", ext: "png", placeholder: "tv.fill")
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(theme.accent, lineWidth: 1.5))
                .shadow(color: theme.accent.opacity(0.6), radius: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text("ZH TEAM")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(1)

                Text(loc.tr("matches_today"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(theme.accent)
            }

            Spacer()

            Button {
                repository.refresh()
            } label: {
                Image(
                    systemName: repository.isSyncing
                        ? "arrow.triangle.2.circlepath"
                        : "arrow.clockwise"
                )
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 38, height: 38)
                .background(Color.white.opacity(0.08))
                .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
    }

    private var filterTabsSection: some View {
        HStack(spacing: 8) {
            filterButton(title: loc.tr("all"), id: "all")
            filterButton(title: loc.tr("live_now"), id: "live", isLive: true)
            filterButton(title: loc.tr("upcoming"), id: "upcoming")
            filterButton(title: loc.tr("finished"), id: "finished")
        }
        .padding(.horizontal, 16)
    }

    private func filterButton(
        title: String,
        id: String,
        isLive: Bool = false
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = id
            }
        } label: {
            HStack(spacing: 5) {
                if isLive {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                }

                Text(title)
                    .font(.system(size: 13, weight: .bold))
            }
            .foregroundColor(selectedFilter == id ? .black : .white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                selectedFilter == id
                    ? theme.accent
                    : Color.white.opacity(0.08)
            )
            .cornerRadius(20)
        }
    }

    private var emptyMatchesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "sportscourt")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.3))
                .padding(.top, 40)

            Text("لا توجد مباريات مسجلة حالياً")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.7))

            Text("يمكنك إضافة المباريات عبر لوحة التحكم ومزامنتها فوراً")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }

    private func handleMatchPlayback(_ match: ZHMatch) {
        if let directUrl = match.streamURL, !directUrl.isEmpty {
            let channel = Zone66Channel(
                id: match.id,
                name: "\(match.team1) vs \(match.team2)",
                category: "Sports",
                streamURL: directUrl,
                iconURL: nil,
                isFeatured: false,
                isEnabled: true
            )

            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                playingChannel = channel
            }
            return
        }

        if let chName = match.channelName,
           let found = repository.channels.first(where: {
               $0.name.contains(chName) || chName.contains($0.name)
           }) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                playingChannel = found
            }
            return
        }

        matchToSelectChannelFor = match
        isPickerPresented = true
    }
}

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
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11))
                        .foregroundColor(theme.accent)

                    Text(match.details)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }

                Spacer()

                HStack(spacing: 6) {
                    if match.isLive {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 6, height: 6)
                            .shadow(color: .white, radius: 4)
                    }

                    Text(statusBadgeText)
                        .font(.system(size: 11, weight: .heavy))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(statusColor)
                        .shadow(color: statusColor.opacity(0.6), radius: 6)
                )
            }

            HStack(alignment: .center, spacing: 10) {
                VStack(spacing: 6) {
                    RemoteOrTextImage(
                        value: match.team1Logo,
                        size: 62,
                        cornerRadius: 16
                    )

                    Text(match.team1)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity)
                }

                VStack(spacing: 4) {
                    Text(match.score)
                        .font(.system(size: 22, weight: .black, design: .monospaced))
                        .foregroundColor(match.isLive ? theme.accent : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.55))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    match.isLive
                                        ? theme.accent.opacity(0.7)
                                        : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )

                    if !match.date.isEmpty {
                        Text(match.date)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .frame(width: 90)

                VStack(spacing: 6) {
                    RemoteOrTextImage(
                        value: match.team2Logo,
                        size: 62,
                        cornerRadius: 16
                    )

                    Text(match.team2)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 4)

            Button(action: onPlay) {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12, weight: .bold))

                    Text(match.channelName ?? loc.tr("watch_now"))
                        .font(.system(size: 14, weight: .bold))

                    Spacer()

                    Image(systemName: "chevron.left")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [
                            theme.accent,
                            theme.accent.opacity(0.85)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: theme.accent.opacity(0.4), radius: 8, y: 2)
            }
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(white: 0.12).opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 22))

                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: match.isLive
                                ? [
                                    theme.accent,
                                    theme.accent.opacity(0.4),
                                    Color.red.opacity(0.6)
                                ]
                                : [
                                    theme.accent.opacity(0.4),
                                    Color.white.opacity(0.12)
                                ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: match.isLive ? 2 : 1.2
                    )
            }
        )
        .shadow(
            color: match.isLive
                ? theme.accent.opacity(0.25)
                : Color.black.opacity(0.4),
            radius: 10,
            y: 5
        )
    }
}

struct MatchChannelPickerSheet: View {
    let match: ZHMatch
    let onSelect: (Zone66Channel) -> Void

    @EnvironmentObject var theme: Zone66Theme
    @EnvironmentObject var repository: ChannelRepository
    @ObservedObject var loc = LocalizationManager.shared
    @Environment(\.presentationMode) var presentationMode

    @State private var search: String = ""

    var filteredChannels: [Zone66Channel] {
        if search.isEmpty {
            return repository.enabledChannels
        }

        return repository.enabledChannels.filter {
            $0.name.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    RemoteOrTextImage(
                        value: match.team1Logo,
                        size: 32,
                        cornerRadius: 8
                    )

                    Text(match.team1)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)

                    Text("VS")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(theme.accent)

                    Text(match.team2)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)

                    RemoteOrTextImage(
                        value: match.team2Logo,
                        size: 32,
                        cornerRadius: 8
                    )
                }
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.06))
                .cornerRadius(12)
                .padding(.horizontal, 16)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.5))

                    TextField(
                        loc.tr("search_placeholder"),
                        text: $search
                    )
                    .foregroundColor(.white)
                }
                .padding(10)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 16)

                List {
                    ForEach(filteredChannels) { channel in
                        Button {
                            onSelect(channel)
                        } label: {
                            HStack(spacing: 12) {
                                if let icon = channel.iconURL,
                                   !icon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    RemoteOrTextImage(
                                        value: icon,
                                        size: 38,
                                        cornerRadius: 9
                                    )
                                } else {
                                    Image(systemName: "tv.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(theme.accent)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(channel.name)
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.white)

                                    Text(channel.category)
                                        .font(.system(size: 11))
                                        .foregroundColor(.white.opacity(0.5))
                                }

                                Spacer()

                                Image(systemName: "play.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(theme.accent)
                            }
                        }
                    }
                    .listRowBackground(theme.card)
                }
                .listStyle(PlainListStyle())
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle(loc.tr("choose_channel"))
            .navigationBarItems(
                leading: Button("إلغاء") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(theme.accent)
            )
        }
        .navigationViewStyle(.stack)
    }
}
