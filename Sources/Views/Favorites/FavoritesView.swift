import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedChannel: Channel?

    var body: some View {
        NavigationView {
            let favs = repo.favoriteChannels()
            Group {
                if favs.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "heart.slash.fill").font(.system(size: 48)).foregroundColor(.gray)
                        Text("لا توجد قنوات في المفضلة").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                        Text("اضغط على علامة القلب داخل أي قناة لإضافتها هنا").font(.system(size: 13)).foregroundColor(.gray)
                    }
                } else {
                    List(favs, id: \.id) { ch in
                        Button { selectedChannel = ch } label: {
                            HStack {
                                Image(systemName: "heart.fill").foregroundColor(.red)
                                Text(ch.name).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                                Spacer()
                                Image(systemName: "play.fill").foregroundColor(themeManager.currentTheme.accentColor)
                            }.padding(.vertical, 6)
                        }.listRowBackground(Color(white: 0.08))
                    }
                }
            }
            .background(themeManager.currentTheme.backgroundDark.ignoresSafeArea())
            .navigationTitle("المفضلة (\(favs.count))")
            .fullScreenCover(item: $selectedChannel) { CinemaPlayerView(channel: $0) }
        }.navigationViewStyle(.stack)
    }
}
