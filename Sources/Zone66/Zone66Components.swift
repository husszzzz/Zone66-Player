import SwiftUI

struct BundledImageView: View {
    let name: String
    let ext: String
    var placeholder: String = "photo"

    var body: some View {
        if name == "zh_logo", let img = AppAssets.zhLogo {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        } else if (name == "developer_hussein" || name.contains("hussein")), let img = AppAssets.husseinPhoto {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        } else if (name == "manager_abboud" || name.contains("abboud")), let img = AppAssets.abboudPhoto {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
        } else if let path = Bundle.main.path(forResource: name, ofType: ext),
           let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: placeholder)
                .resizable()
                .scaledToFit()
        }
    }
}

struct ChannelRow: View {
    let channel: Zone66Channel
    let onSelect: () -> Void
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(theme.accent.opacity(0.3), lineWidth: 1)
                        )

                    Image(systemName: "tv.fill")
                        .font(.system(size: 20))
                        .foregroundColor(theme.accent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(channel.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(channel.category)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(theme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(theme.accent.opacity(0.15))
                            .cornerRadius(6)

                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)

                        Text("HD • بث مباشر")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                Spacer()

                Button {
                    repository.toggleFavorite(channel.id)
                } label: {
                    Image(systemName: repository.isFavorite(channel.id) ? "heart.fill" : "heart")
                        .font(.system(size: 20))
                        .foregroundColor(repository.isFavorite(channel.id) ? .red : .white.opacity(0.4))
                        .padding(8)
                }

                Image(systemName: "play.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(theme.accent)
            }
            .padding(14)
            .background(theme.card)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
            )
        }
    }
}
