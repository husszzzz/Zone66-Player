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
                    // Live Sync Notification Banner
                    if repo.isSyncing {
                        HStack(spacing: 8) {
                            ProgressView()
                                .tint(themeManager.currentTheme.accentColor)
                                .scaleEffect(0.8)
                            Text("جارٍ جلب القنوات المحدثة من لوحة التحكم...")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.accentColor)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(themeManager.currentTheme.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                        .transition(.scale.combined(with: .opacity))
                    }

                    // Top Hero Banner
                    HeroBannerView(accentColor: themeManager.currentTheme.accentColor) {
                        if let first = repo.channels.first(where: { $0.enabled }) {
                            selectedChannel = first
                        }
                    }

                    // Categories Pills Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(repo.categories, id: \.self) { cat in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        activeCategory = cat
                                    }
                                }) {
                                    Text(cat)
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 9)
                                        .background(activeCategory == cat ? themeManager.currentTheme.accentColor : Color(white: 0.12))
                                        .foregroundColor(activeCategory == cat ? .black : .white)
                                        .clipShape(Capsule())
                                        .scaleEffect(activeCategory == cat ? 1.05 : 1.0)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Channels Grid
                    VStack(alignment: .trailing, spacing: 14) {
                        HStack {
                            Button(action: {
                                repo.syncWithRemoteServer()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                        .rotationEffect(.degrees(repo.isSyncing ? 360 : 0))
                                        .animation(repo.isSyncing ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: repo.isSyncing)
                                    Text("تحديث")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundColor(themeManager.currentTheme.accentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(themeManager.currentTheme.accentColor.opacity(0.15))
                                .clipShape(Capsule())
                            }

                            Spacer()

                            Text("🔥 البثوث المتاحة")
                                .font(.system(size: 19, weight: .black))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)

                        let list = repo.channels
                            .filter { $0.enabled && (activeCategory == "الكل" || $0.category == activeCategory) }
                            .prefix(30)

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
            .navigationTitle("Zh Team Live")
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

                    Text("Zh Team Cinema")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(accentColor)
                }

                Text("مشاهدة سينمائية فائقة")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)

                Text("تزامن سحابي فوري مع لوحة التحكم coomCraft")
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
