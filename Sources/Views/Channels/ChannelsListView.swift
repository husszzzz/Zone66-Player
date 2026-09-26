import SwiftUI

struct ChannelsListView: View {
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var themeManager: ThemeManager
    @State private var searchText = ""
    @State private var selectedChannel: Channel?

    var filtered: [Channel] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return repo.channels
        }
        return repo.channels.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            List(filtered, id: \.id) { ch in
                Button(action: { selectedChannel = ch }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(themeManager.currentTheme.accentColor)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(ch.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(ch.category) • مباشر")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("LIVE")
                            .font(.system(size: 10, weight: .black))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.2))
                            .foregroundColor(.red)
                            .clipShape(Capsule())
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color(white: 0.08))
            }
            .background(themeManager.currentTheme.backgroundDark.ignoresSafeArea())
            .navigationTitle("كل القنوات (\(repo.channels.count))")
            .searchable(text: $searchText, prompt: "ابحث عن القناة...")
            .fullScreenCover(item: $selectedChannel) { ch in
                CinemaPlayerView(channel: ch)
            }
        }
        .navigationViewStyle(.stack)
    }
}
