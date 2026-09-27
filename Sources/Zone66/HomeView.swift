import SwiftUI

struct HomeView: View {
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @State private var selectedChannel: Zone66Channel?
    @State private var filterState: String = "الكل"

    private var filteredMatches: [ZHMatch] {
        switch filterState {
        case "مباشر":
            return repository.matches.filter { $0.isLive }
        case "قادمة":
            return repository.matches.filter { !$0.isLive && $0.status != "انتهت" }
        case "انتهت":
            return repository.matches.filter { $0.status == "انتهت" }
        default:
            return repository.matches
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    filterTabs
                    verticalMatchesList
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedChannel) { ch in
                PlayerView(channel: ch)
            }
            .refreshable {
                repository.refresh()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var header: some View {
        HStack(spacing: 12) {
            BundledImageView(name: "zh_logo", ext: "png", placeholder: "tv.fill")
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(theme.accent, lineWidth: 1.5))
                .shadow(color: theme.accent.opacity(0.4), radius: 5)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text("ZH TEAM")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(theme.accent)

                    Text("PRO")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.accent)
                        .foregroundColor(.black)
                        .cornerRadius(6)
                }

                Text("جدول وأهم مباريات اليوم المباشرة")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.65))
            }

            Spacer()

            Button {
                repository.refresh()
            } label: {
                Image(systemName: repository.isSyncing ? "arrow.triangle.2.circlepath.circle.fill" : "arrow.clockwise.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(theme.accent)
            }
        }
        .padding(.horizontal, 18)
    }

    private var filterTabs: some View {
        HStack(spacing: 10) {
            ForEach(["الكل", "مباشر", "قادمة", "انتهت"], id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        filterState = tab
                    }
                } label: {
                    HStack(spacing: 4) {
                        if tab == "مباشر" {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 6, height: 6)
                        }
                        Text(tab)
                            .font(.system(size: 13, weight: filterState == tab ? .bold : .medium))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(filterState == tab ? theme.accent : theme.card)
                    .foregroundColor(filterState == tab ? .black : .white.opacity(0.8))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(filterState == tab ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
            }
            Spacer()
        }
        .padding(.horizontal, 18)
    }

    private var verticalMatchesList: some View {
        VStack(spacing: 14) {
            if filteredMatches.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "sportscourt")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("لا توجد مباريات في هذا التصنيف حالياً")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(filteredMatches) { match in
                    verticalMatchCard(match)
                }
            }
        }
        .padding(.horizontal, 18)
    }

    private func verticalMatchCard(_ match: ZHMatch) -> some View {
        VStack(spacing: 12) {
            // League and match status header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11))
                        .foregroundColor(theme.accent)
                    Text(match.league)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                if match.isLive {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 7, height: 7)
                        Text("مباشر الان")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red)
                    .cornerRadius(8)
                } else if match.status == "انتهت" {
                    Text("انتهت المباراة")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.white.opacity(0.7))
                        .cornerRadius(8)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        Text(match.time)
                            .font(.system(size: 11, weight: .bold))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.accent.opacity(0.2))
                    .foregroundColor(theme.accent)
                    .cornerRadius(8)
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Teams & Score
            HStack(spacing: 16) {
                // Team A
                VStack(spacing: 6) {
                    Text(match.teamALogo)
                        .font(.system(size: 32))
                    Text(match.teamA)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)

                // Score or VS
                VStack(spacing: 4) {
                    Text(match.score)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(match.isLive ? theme.accent : .white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(match.isLive ? theme.accent.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
                        )

                    if match.isLive {
                        Text("الشوط الثاني")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(theme.accent)
                    }
                }

                // Team B
                VStack(spacing: 6) {
                    Text(match.teamBLogo)
                        .font(.system(size: 32))
                    Text(match.teamB)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 6)

            Divider()
                .background(Color.white.opacity(0.1))

            // Footer with Channel info & Watch button
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "tv.fill")
                        .font(.system(size: 13))
                        .foregroundColor(theme.accent)

                    Text(match.channelName)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()

                Button {
                    // Find the channel in repository or match channelName
                    let matchCh = repository.enabledChannels.first { ch in
                        ch.name.localizedCaseInsensitiveContains(match.channelName) ||
                        match.channelName.localizedCaseInsensitiveContains(ch.name)
                    }
                    if let found = matchCh {
                        selectedChannel = found
                    } else if let customURL = match.streamURL, !customURL.isEmpty {
                        selectedChannel = Zone66Channel(
                            id: "match_\(match.id)",
                            name: "\(match.teamA) vs \(match.teamB)",
                            category: "مباريات",
                            streamURL: customURL
                        )
                    } else if let fallback = repository.enabledChannels.first {
                        selectedChannel = fallback
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 11))
                        Text("مشاهدة البث المباشر")
                            .font(.system(size: 12, weight: .black))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [theme.accent, theme.accent.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .shadow(color: theme.accent.opacity(0.4), radius: 4)
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [theme.card, theme.card.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(match.isLive ? theme.accent.opacity(0.7) : Color.white.opacity(0.08), lineWidth: match.isLive ? 1.5 : 1)
        )
        .shadow(color: match.isLive ? theme.accent.opacity(0.2) : Color.black.opacity(0.3), radius: 8)
    }
}
