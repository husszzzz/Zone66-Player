import SwiftUI

struct HomeView: View {
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedChannel: Channel?
    @State private var activeCategory: String = "الكل"

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // Top Hero Banner
                    HeroBannerView(accentColor: themeManager.currentTheme.accentColor) {
                        if let first = repo.channels.first {
                            selectedChannel = first
                        }
                    }

                    // Categories Pills Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(repo.categories, id: \.self) { cat in
                                Button(action: { activeCategory = cat }) {
                                    Text(cat)
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 9)
                                        .background(activeCategory == cat ? themeManager.currentTheme.accentColor : Color(white: 0.12))
                                        .foregroundColor(activeCategory == cat ? .black : .white)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Channels Grid
                    VStack(alignment: .trailing, spacing: 14) {
                        HStack {
                            Spacer()
                            Text("🔥 البثوث المميزة")
                                .font(.system(size: 19, weight: .black))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)

                        let list = repo.channels
                            .filter { activeCategory == "الكل" || $0.category == activeCategory }
                            .prefix(20)

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(Array(list), id: \.id) { ch in
                                ChannelCardView(channel: ch, accentColor: themeManager.currentTheme.accentColor) {
                                    selectedChannel = ch
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(themeManager.currentTheme.backgroundDark.ignoresSafeArea())
            .navigationTitle("Zh Team TV")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $selectedChannel) { ch in
                CinemaPlayerView(channel: ch)
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct HeroBannerView: View {
    let accentColor: Color
    var onPlay: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [accentColor.opacity(0.4), Color(white: 0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    HStack(spacing: 6) {
                        Circle().fill(Color.red).frame(width: 8, height: 8)
                        Text("مباشر الآن")
                            .font(.system(size: 11, weight: .black))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.4))
                    .clipShape(Capsule())

                    Spacer()

                    Text("Zh Team Live")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(accentColor)
                }

                Text("مشاهدة سينمائية متكاملة")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)

                Text("جودة عالية مع إمكانية إدارة وتعديل كافة القنوات")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Button(action: onPlay) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("تشغيل البث الآن")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 6)
            }
            .padding(18)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(accentColor.opacity(0.3), lineWidth: 1.5))
        .padding(.horizontal, 16)
    }
}

struct ChannelCardView: View {
    let channel: Channel
    let accentColor: Color
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    Circle().fill(Color.red).frame(width: 7, height: 7)
                    Spacer()
                    if channel.isCustom {
                        Text("مخصصة")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.orange)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    Image(systemName: "tv.fill")
                        .font(.system(size: 13))
                        .foregroundColor(accentColor)
                }

                Spacer()

                Text(channel.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .multilineTextAlignment(.trailing)

                Text(channel.category)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(14)
            .frame(height: 105)
            .frame(maxWidth: .infinity)
            .background(Color(white: 0.11))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}
