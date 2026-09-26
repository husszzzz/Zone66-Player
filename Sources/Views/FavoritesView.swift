import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [Channel] = []
    @State private var selectedChannel: Channel?

    var body: some View {
        NavigationView {
            Group {
                if favorites.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("لا توجد قنوات في المفضلة")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                        Text("اضغط على علامة القلب داخل أي قناة لإضافتها هنا")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                } else {
                    List(favorites, id: \.id) { ch in
                        Button(action: { selectedChannel = ch }) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text(ch.name)
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "play.fill")
                                    .foregroundColor(.orange)
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(Color(white: 0.08))
                    }
                }
            }
            .background(Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea())
            .navigationTitle("المفضلة")
            .onAppear {
                favorites = ChannelRepository.shared.getFavorites()
            }
            .fullScreenCover(item: $selectedChannel) { ch in
                CinemaPlayerView(channel: ch)
            }
        }
        .navigationViewStyle(.stack)
    }
}
