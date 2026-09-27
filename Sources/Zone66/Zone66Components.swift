import SwiftUI

struct ChannelLogoView: View {
    let channel: Zone66Channel
    @EnvironmentObject var theme: Zone66Theme

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [theme.accent.opacity(0.24), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let iconStr = channel.iconURL, !iconStr.isEmpty, let url = URL(string: iconStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(14)
                    default:
                        Image(systemName: "tv.fill")
                            .font(.system(size: 28))
                            .foregroundColor(theme.accent)
                    }
                }
            } else {
                Image(systemName: "tv.fill")
                    .font(.system(size: 28))
                    .foregroundColor(theme.accent)
            }
        }
    }
}

struct ChannelRow: View {
    let channel: Zone66Channel
    var onPlay: () -> Void
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme

    var body: some View {
        Button(action: onPlay) {
            HStack(spacing: 14) {
                ChannelLogoView(channel: channel)
                    .frame(width: 62, height: 62)

                VStack(alignment: .leading, spacing: 7) {
                    Text(channel.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 7) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 7, height: 7)

                        Text("مباشر")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.gray)

                        Text("•")
                            .foregroundColor(.gray)

                        Text(channel.category)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Image(systemName: repository.isFavorite(channel.id) ? "heart.fill" : "play.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(repository.isFavorite(channel.id) ? .red : theme.accent)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Circle())
            }
            .padding(12)
            .background(theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
