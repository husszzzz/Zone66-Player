import SwiftUI

struct HomeView: View {
    @State private var selectedChannel: Channel?
    @State private var activeCategory: String = "الكل"

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    // 1. Hero Cinema Banner
                    HeroBannerView {
                        if let first = ChannelRepository.shared.channels.first {
                            selectedChannel = first
                        }
                    }

                    // 2. Categories Pills
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(ChannelRepository.shared.categories, id: \.self) { cat in
                                Button(action: { activeCategory = cat }) {
                                    Text(cat)
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 9)
                                        .background(activeCategory == cat ? Color.orange : Color(white: 0.12))
                                        .foregroundColor(activeCategory == cat ? .black : .white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.white.opacity(activeCategory == cat ? 0.3 : 0.08), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // 3. Featured Channels Grid
                    VStack(alignment: .trailing, spacing: 14) {
                        HStack {
                            Spacer()
                            Text("🔥 البثوث الأكثر مشاهدة")
                                .font(.system(size: 19, weight: .black))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)

                        let list = ChannelRepository.shared.channels
                            .filter { activeCategory == "الكل" || $0.category == activeCategory }
                            .prefix(20)

                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                            ForEach(Array(list), id: \.id) { ch in
                                ChannelCardView(channel: ch) {
                                    selectedChannel = ch
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.vertical, 16)
            }
            .background(Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea())
            .navigationTitle("ZONE 66 TV")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $selectedChannel) { ch in
                CinemaPlayerView(channel: ch)
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct HeroBannerView: View {
    var onPlay: () -> Void

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            LinearGradient(
                colors: [Color(red: 0.35, green: 0.12, blue: 0.02), Color(red: 0.1, green: 0.05, blue: 0.02)],
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

                    Text("قمة اليوم")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                }

                Text("BeIN SPORTS 1 HD")
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(.white)

                Text("شاهد البث بأعلى جودة مع مشغل سينمائي مدمج")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                Button(action: onPlay) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("مشاهدة القمة الآن")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Color.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 6)
            }
            .padding(18)
        }
        .frame(height: 190)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.orange.opacity(0.3), lineWidth: 1.5))
        .padding(.horizontal, 16)
    }
}

struct ChannelCardView: View {
    let channel: Channel
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    Circle().fill(Color.red).frame(width: 7, height: 7)
                    Spacer()
                    Image(systemName: "tv.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.orange)
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
