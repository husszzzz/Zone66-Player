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

// Supports normal text/emoji and remote image URLs.
struct RemoteOrTextImage: View {
    let value: String
    var size: CGFloat = 56
    var cornerRadius: CGFloat = 14

    private var cleanedValue: String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var remoteURL: URL? {
        guard let url = URL(string: cleanedValue),
              let scheme = url.scheme?.lowercased(),
              (scheme == "http" || scheme == "https"),
              !cleanedValue.isEmpty else {
            return nil
        }
        return url
    }

    var body: some View {
        Group {
            if let url = remoteURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding(4)

                    case .failure:
                        fallback

                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.white.opacity(0.06))

                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(
                                        tint: .white.opacity(0.7)
                                    )
                                )
                        }

                    @unknown default:
                        fallback
                    }
                }
            } else {
                fallback
            }
        }
        .frame(width: size, height: size)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.white.opacity(0.06))
        )
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var fallback: some View {
        Text(cleanedValue.isEmpty ? "⚽" : cleanedValue)
            .font(.system(size: min(size * 0.55, 38), weight: .bold))
            .foregroundColor(.white)
            .minimumScaleFactor(0.4)
            .lineLimit(1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                                colors: [
                                    Color.white.opacity(0.12),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(theme.accent.opacity(0.3), lineWidth: 1)
                        )

                    if let icon = channel.iconURL,
                       !icon.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        RemoteOrTextImage(
                            value: icon,
                            size: 42,
                            cornerRadius: 11
                        )
                    } else {
                        Image(systemName: "tv.fill")
                            .font(.system(size: 20))
                            .foregroundColor(theme.accent)
                    }
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
                    Image(
                        systemName: repository.isFavorite(channel.id)
                            ? "heart.fill"
                            : "heart"
                    )
                    .font(.system(size: 20))
                    .foregroundColor(
                        repository.isFavorite(channel.id)
                            ? .red
                            : .white.opacity(0.4)
                    )
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
