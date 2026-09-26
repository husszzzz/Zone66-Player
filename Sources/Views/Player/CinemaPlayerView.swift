import SwiftUI
import AVKit

struct CinemaPlayerView: View {
    let channel: Channel
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var repo: ChannelRepository
    @EnvironmentObject var settings: AppSettings
    @EnvironmentObject var themeManager: ThemeManager

    @State private var player: AVPlayer?
    @State private var isPlaying = true
    @State private var showControls = true

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Video Player
            if let p = player {
                VideoPlayer(player: p)
                    .ignoresSafeArea()
            } else {
                ProgressView()
                    .tint(themeManager.currentTheme.accentColor)
            }

            // Custom Watermark
            if settings.watermarkEnabled {
                VStack {
                    HStack {
                        Spacer()
                        ZStack {
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [themeManager.currentTheme.accentColor.opacity(0.9), Color.red.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: 140, height: 38)
                                .shadow(color: .black.opacity(0.8), radius: 6, x: 0, y: 3)

                            Text(settings.watermarkTitle.isEmpty ? "Zh Team" : settings.watermarkTitle)
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 16)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
                .ignoresSafeArea(.all, edges: .top)
            }

            // Controls Overlay
            if showControls {
                VStack {
                    // Top Bar
                    HStack {
                        Button(action: {
                            player?.pause()
                            dismiss()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 22))
                                Text("إغلاق")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Capsule())
                        }

                        Spacer()

                        Text(channel.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Spacer()

                        Button(action: {
                            repo.toggleFavorite(id: channel.id)
                        }) {
                            Image(systemName: repo.isFavorite(id: channel.id) ? "heart.fill" : "heart")
                                .font(.system(size: 20))
                                .foregroundColor(repo.isFavorite(id: channel.id) ? .red : .white)
                                .padding(10)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer()

                    // Bottom Play/Pause Bar
                    HStack(spacing: 24) {
                        Button(action: {
                            if isPlaying {
                                player?.pause()
                            } else {
                                player?.play()
                            }
                            isPlaying.toggle()
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.black)
                                .frame(width: 60, height: 60)
                                .background(themeManager.currentTheme.accentColor)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 36)
                }
                .background(
                    LinearGradient(
                        colors: [Color.black.opacity(0.8), Color.clear, Color.black.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                showControls.toggle()
            }
        }
        .onAppear {
            if let url = URL(string: channel.url) {
                let p = AVPlayer(url: url)
                self.player = p
                p.play()
            }
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }
}
