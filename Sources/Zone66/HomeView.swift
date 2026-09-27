import SwiftUI

struct HomeView: View {
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @State private var selectedChannel: Zone66Channel?
    @State private var category = "الكل"

    private var visibleChannels: [Zone66Channel] {
        let base = category == "الكل"
            ? repository.enabledChannels
            : repository.enabledChannels.filter { ch in ch.category == category }

        return Array(base.prefix(16))
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    heroBanner
                    matchesSection
                    categoriesBar
                    channelsGrid
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
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text("ZH TEAM")
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundColor(theme.accent)
                    
                    Text("PRO")
                        .font(.system(size: 11, weight: .heavy))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.accent)
                        .foregroundColor(.black)
                        .cornerRadius(6)
                }

                Text("منصة البث المباشر والمباريات الحصرية")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
            }

            Spacer()

            Button {
                repository.refresh()
            } label: {
                Image(systemName: repository.isSyncing ? "arrow.triangle.2.circlepath.circle.fill" : "arrow.clockwise.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(theme.accent)
            }
        }
        .padding(.horizontal, 18)
    }

    private var heroBanner: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.12, green: 0.16, blue: 0.08), Color(red: 0.05, green: 0.05, blue: 0.07)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(theme.accent.opacity(0.35), lineWidth: 1.2)
                )

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(theme.accent)
                            .frame(width: 8, height: 8)
                        Text("بث مباشر بجودة فائقة")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(theme.accent)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(20)

                    Spacer()

                    Text("\(repository.enabledChannels.count) قناة")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }

                Text("أقوى الباقات الرياضية والترفيهية")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Text("شاهد مباريات اليوم ومئات القنوات بدون تقطيع مع دعم ميزة صورة داخل صورة (PiP)")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(2)
            }
            .padding(18)
        }
        .frame(height: 145)
        .padding(.horizontal, 16)
    }

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sportscourt.fill")
                        .foregroundColor(theme.accent)
                    Text("مباريات اليوم")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 7, height: 7)
                    Text("محدث تلقائياً")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 18)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(repository.matches) { match in
                        matchCard(match)
                    }
                }
                .padding(.horizontal, 18)
            }
        }
    }

    private func matchCard(_ match: ZHMatch) -> some View {
        VStack(spacing: 10) {
            HStack {
                Text(match.league)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)

                Spacer()

                if match.isLive {
                    Text("مباشر")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                } else {
                    Text(match.time)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.12))
                        .foregroundColor(.white.opacity(0.9))
                        .cornerRadius(6)
                }
            }

            HStack(spacing: 10) {
                VStack(spacing: 4) {
                    Text(match.teamALogo)
                        .font(.system(size: 24))
                    Text(match.teamA)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(width: 75)

                Text(match.score)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundColor(theme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.4))
                    .cornerRadius(8)

                VStack(spacing: 4) {
                    Text(match.teamBLogo)
                        .font(.system(size: 24))
                    Text(match.teamB)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .frame(width: 75)
            }

            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "tv")
                        .font(.system(size: 10))
                        .foregroundColor(theme.accent)
                    Text(match.channelName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }

                Spacer()

                Button {
                    let matchCh = repository.enabledChannels.first { ch in
                        ch.name.localizedCaseInsensitiveContains(match.channelName) || match.channelName.localizedCaseInsensitiveContains(ch.name)
                    }
                    if let found = matchCh {
                        selectedChannel = found
                    } else if let fallback = repository.enabledChannels.first {
                        selectedChannel = fallback
                    }
                } label: {
                    Text("مشاهدة")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(theme.accent)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
            }
            .padding(.top, 4)
        }
        .padding(14)
        .frame(width: 260)
        .background(theme.card)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(match.isLive ? theme.accent.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var categoriesBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("الأقسام")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 18)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(repository.categories, id: \.self) { cat in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                category = cat
                            }
                        } label: {
                            Text(cat)
                                .font(.system(size: 13, weight: category == cat ? .bold : .medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(category == cat ? theme.accent : theme.card)
                                .foregroundColor(category == cat ? .black : .white.opacity(0.8))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 18)
            }
        }
    }

    private var channelsGrid: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("قنوات مميزة")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                NavigationLink(destination: ChannelsView()) {
                    Text("عرض الكل (\(repository.enabledChannels.count))")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(theme.accent)
                }
            }
            .padding(.horizontal, 18)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(visibleChannels) { channel in
                    channelCard(channel)
                }
            }
            .padding(.horizontal, 18)
        }
    }

    private func channelCard(_ channel: Zone66Channel) -> some View {
        Button {
            selectedChannel = channel
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.08))
                            .frame(width: 38, height: 38)

                        Image(systemName: "play.tv.fill")
                            .font(.system(size: 16))
                            .foregroundColor(theme.accent)
                    }

                    Spacer()

                    Button {
                        repository.toggleFavorite(channel.id)
                    } label: {
                        Image(systemName: repository.isFavorite(channel.id) ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(repository.isFavorite(channel.id) ? .red : .white.opacity(0.4))
                    }
                }

                Text(channel.name)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack {
                    Text(channel.category)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))

                    Spacer()

                    Circle()
                        .fill(theme.accent)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(12)
            .background(theme.card)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}
