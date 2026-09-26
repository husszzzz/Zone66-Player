import SwiftUI

struct ChannelsListView: View {
    @State private var searchText = ""
    @State private var selectedChannel: Channel?

    var filtered: [Channel] {
        let all = ChannelRepository.shared.channels
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return all
        }
        return all.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered, id: \.id) { ch in
                Button(action: { selectedChannel = ch }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.orange)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(ch.name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(ch.category) • بث حي")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        Text("مباشر")
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
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.04, green: 0.04, blue: 0.05).ignoresSafeArea())
            .navigationTitle("كل القنوات (671)")
            .searchable(text: $searchText, prompt: "ابحث عن اسم القناة...")
            .fullScreenCover(item: $selectedChannel) { ch in
                CinemaPlayerView(channel: ch)
            }
        }
    }
}
