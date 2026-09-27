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
                // Category Pills Bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(repository.categories, id: \.self) { cat in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedCategory = cat
                                }
                            } label: {
                                Text(cat)
                                    .font(.system(size: 13, weight: selectedCategory == cat ? .bold : .medium))
                                    .foregroundColor(selectedCategory == cat ? .black : .white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == cat ? theme.accent : theme.card)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(selectedCategory == cat ? Color.clear : Color.white.opacity(0.08), lineWidth: 1)
                                    )
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
                            .font(.system(size: 48))
                            .foregroundColor(.gray)

                        Text("لا توجد قنوات مطابقة")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text("جرب البحث عن اسم آخر أو اختيار تصنيف مختلف")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(filtered) { channel in
                                ChannelRow(channel: channel) {
                                    selectedChannel = channel
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
            }
            .background(theme.background.ignoresSafeArea())
            .navigationTitle("باقة القنوات")
            .searchable(text: $searchText, prompt: "ابحث في القنوات...")
            .fullScreenCover(item: $selectedChannel) {
                PlayerView(channel: $0)
            }
        }
        .navigationViewStyle(.stack)
    }
}
