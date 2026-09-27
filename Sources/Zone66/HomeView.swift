import SwiftUI

struct HomeView: View {
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @State private var selectedChannel: Zone66Channel?
    @State private var selectedCategory: String = "الكل"
    @State private var searchQuery: String = ""

    private var availableCategories: [String] {
        var set = Set<String>()
        for ch in repository.enabledChannels {
            if !ch.category.isEmpty {
                set.insert(ch.category)
            }
        }
        var list = Array(set).sorted()
        list.insert("الكل", at: 0)
        return list
    }

    private var displayedChannels: [Zone66Channel] {
        var list = repository.enabledChannels
        if selectedCategory != "الكل" {
            list = list.filter { $0.category == selectedCategory }
        }
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
        }
        return list
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    searchBar
                    
                    if !repository.recentChannels.isEmpty && searchQuery.isEmpty && selectedCategory == "الكل" {
                        recentChannelsSection
                    }

                    if let topChannel = repository.enabledChannels.first, searchQuery.isEmpty && selectedCategory == "الكل" && repository.recentChannels.isEmpty {
                        heroLiveCard(channel: topChannel)
                    }

                    categoryChips
                    realChannelsVerticalList
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
                .shadow(color: theme.accent.opacity(0.4), radius: 6)

            VStack(alignment: .leading, spacing: 2) {
                Text("ZH TEAM")
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    Text("البث المباشر للقنوات الحقيقية")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()

            Button {
                repository.refresh()
            } label: {
                Image(systemName: repository.isSyncing ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(theme.accent)
                    .padding(10)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.4))
            TextField("ابحث عن القناة...", text: $searchQuery)
                .foregroundColor(.white)
                .font(.system(size: 14))
            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(12)
        .background(theme.card)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    private var recentChannelsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(theme.accent)
                Text("شوهد مؤخراً")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(repository.recentChannels) { ch in
                        Button {
                            selectedChannel = ch
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(theme.accent.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(theme.accent)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ch.name)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                    Text(ch.category)
                                        .font(.system(size: 10))
                                        .foregroundColor(theme.accent)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(theme.card)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(theme.accent.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func heroLiveCard(channel: Zone66Channel) -> some View {
        Button {
            selectedChannel = channel
        } label: {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [theme.accent.opacity(0.25), Color.black.opacity(0.85)],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        )
                    )
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(theme.accent.opacity(0.4), lineWidth: 1.5)
                    )

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("البث الأبرز الآن")
                                .font(.system(size: 11, weight: .black))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.85))
                        .cornerRadius(20)

                        Spacer()

                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 38))
                            .foregroundColor(theme.accent)
                            .shadow(color: theme.accent.opacity(0.6), radius: 10)
                    }

                    Spacer()

                    VStack(alignment: .leading, spacing: 2) {
                        Text(channel.name)
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                        Text(channel.category)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(theme.accent)
                    }
                }
                .padding(16)
            }
        }
        .padding(.horizontal, 16)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availableCategories, id: \.self) { cat in
                    Button {
                        selectedCategory = cat
                    } label: {
                        Text(cat)
                            .font(.system(size: 13, weight: .bold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(selectedCategory == cat ? theme.accent : Color.white.opacity(0.06))
                            .foregroundColor(selectedCategory == cat ? .black : .white)
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var realChannelsVerticalList: some View {
        LazyVStack(spacing: 12) {
            HStack {
                Text("القنوات المتوفرة (\\(displayedChannels.count))")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 16)

            if displayedChannels.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "tv.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.3))
                    Text("لا توجد قنوات تطابق البحث")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.vertical, 40)
            } else {
                ForEach(displayedChannels) { ch in
                    ChannelRow(channel: ch) {
                        selectedChannel = ch
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
    }
}
