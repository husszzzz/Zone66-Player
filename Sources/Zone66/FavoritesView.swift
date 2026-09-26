import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @State private var selectedChannel: Zone66Channel?

    var body: some View {
        NavigationView {
            Group {
                if repository.favoriteChannels.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "heart.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(theme.accent)

                        Text("المفضلة فارغة")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)

                        Text("اضغط على القلب داخل المشغل لحفظ القنوات هنا")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(30)
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(repository.favoriteChannels) { channel in
                                ChannelRow(channel: channel) {
                                    selectedChannel = channel
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("المفضلة")
            .fullScreenCover(item: $selectedChannel) {
                PlayerView(channel: $0)
            }
        }
        .navigationViewStyle(.stack)
    }
}
