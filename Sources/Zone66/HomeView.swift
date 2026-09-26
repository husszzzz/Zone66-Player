import SwiftUI

struct HomeView: View {
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @State private var selectedChannel: Zone66Channel?
    @State private var category = "الكل"

    private var visibleChannels: [Zone66Channel] {
        let base = category == "الكل"
            ? repository.enabledChannels
            : repository.enabledChannels.filter { $0.category == category }

        return Array(base.prefix(12))
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    header
                    hero
                    categoryBar
                    sectionHeader
                    channels
                    footer
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
            .background(theme.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .fullScreenCover(item: $selectedChannel) {
                PlayerView(channel: $0)
            }
            .refreshable {
                repository.refresh()
            }
        }
        .navigationViewStyle(.stack)
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(repository.remoteSettings.appName)
                    .font(.system(size: 27, weight: .black))
                    .foregroundColor(.white)

                Text("كل ما تحتاجه للمشاهدة")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button {
                repository.refresh()
            } label: {
                Image(systemName: repository.isLoading ? "arrow.triangle.2.circlepath" : "arrow.clockwise")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(theme.accent)
                    .frame(width: 44, height: 44)
                    .background(theme.card)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 18)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Label("LIVE", systemImage: "circle.fill")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 7)
                    .background(Color.red.opacity(0.22))
                    .clipShape(Capsule())

                Spacer()

                Image(systemName: "sparkles")
                    .foregroundColor(theme.accent)
            }

            Text(repository.remoteSettings.heroTitle)
                .font(.system(size: 29, weight: .black))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Text(repository.remoteSettings.heroSubtitle)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.65))
                .lineSpacing(3)

            Button {
                selectedChannel = repository.featured.first ?? repository.enabledChannels.first
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text(repository.remoteSettings.heroButtonTitle)
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(theme.accent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    theme.accent.opacity(0.30),
                    Color.white.opacity(0.05),
                    Color.black.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .stroke(theme.accent.opacity(0.45), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .padding(.horizontal, 16)
    }

    private var categoryBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(repository.categories, id: \.self) { item in
                    Button {
                        category = item
                    } label: {
                        Text(item)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(category == item ? .black : .white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(category == item ? theme.accent : theme.card)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var sectionHeader: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing, spacing: 3) {
                Text("القنوات المميزة")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)

                Text("\(repository.enabledChannels.count) قناة متاحة")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 18)
    }

    private var channels: some View {
        LazyVStack(spacing: 10) {
            ForEach(visibleChannels) { channel in
                ChannelRow(channel: channel) {
                    selectedChannel = channel
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private var footer: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.shield.fill")
                .foregroundColor(theme.accent)

            Text("تتم إدارة القنوات والمحتوى من لوحة التحكم الخارجية")
                .font(.system(size: 11))
                .foregroundColor(.gray)
        }
        .padding(.top, 10)
    }
}
