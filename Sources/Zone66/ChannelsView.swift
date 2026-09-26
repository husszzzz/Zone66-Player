import SwiftUI

struct ChannelsView: View {
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @State private var searchText = ""
    @State private var selectedCategory = "الكل"
    @State private var selectedChannel: Zone66Channel?

    private var filtered: [Zone66Channel] {
        var result = selectedCategory == "الكل"
            ? repository.enabledChannels
            : repository.enabledChannels.filter { $0.category == selectedCategory }

        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(q) ||
                $0.category.localizedCaseInsensitiveContains(q)
            }
        }
        return result
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(repository.categories, id: \.self) { cat in
                            Button {
                                selectedCategory = cat
                            } label: {
                                Text(cat)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(selectedCategory == cat ? .black : .white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 9)
                                    .background(selectedCategory == cat ? theme.accent : theme.card)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                }

                if filtered.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tv.slash")
                            .font(.system(size: 45))
                            .foregroundColor(.gray)

                        Text("لا توجد قنوات")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.white)

                        Text("أضف القنوات من لوحة التحكم الخارجية")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 10) {
                            ForEach(filtered) { channel in
                                ChannelRow(channel: channel) {
                                    selectedChannel = channel
                                }
                            }
                        }
                        .padding(16)
                    }
                }
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("القنوات")
            .searchable(text: $searchText, prompt: "ابحث عن قناة...")
            .fullScreenCover(item: $selectedChannel) {
                PlayerView(channel: $0)
            }
        }
        .navigationViewStyle(.stack)
    }
}
