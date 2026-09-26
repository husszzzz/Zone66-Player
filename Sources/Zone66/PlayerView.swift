import SwiftUI
import AVKit

struct PlayerView: View {
    let channel: Zone66Channel

    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @EnvironmentObject var settings: Zone66Settings

    @State private var player: AVPlayer?
    @State private var playing = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .aspectRatio(contentMode: settings.fillVideo ? .fill : .fit)
                    .ignoresSafeArea()
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .tint(theme.accent)

                    Text("جاري تشغيل البث…")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            VStack {
                HStack {
                    Button {
                        player?.pause()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 42, height: 42)
                            .background(Color.black.opacity(0.65))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text(channel.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Spacer()

                    Button {
                        repository.toggleFavorite(channel.id)
                    } label: {
                        Image(systemName: repository.isFavorite(channel.id) ? "heart.fill" : "heart")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(repository.isFavorite(channel.id) ? .red : .white)
                            .frame(width: 42, height: 42)
                            .background(Color.black.opacity(0.65))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)

                Spacer()

                HStack(spacing: 14) {
                    Text(channel.category)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))

                    Button {
                        if playing {
                            player?.pause()
                        } else {
                            player?.play()
                        }
                        playing.toggle()
                    } label: {
                        Image(systemName: playing ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 56, height: 56)
                            .background(theme.accent)
                            .clipShape(Circle())
                    }

                    Text("LIVE")
                        .font(.system(size: 11, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.8))
                        .clipShape(Capsule())
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            guard let url = URL(string: channel.url) else { return }
            let p = AVPlayer(url: url)
            player = p

            if settings.autoPlay {
                p.play()
                playing = true
            } else {
                playing = false
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}
