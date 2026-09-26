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
            if let p = player {
                VideoPlayer(player: p)
                    .aspectRatio(contentMode: settings.videoAspectMode == "fill" ? .fill : .fit)
                    .ignoresSafeArea()
            } else {
                ProgressView().tint(themeManager.currentTheme.accentColor)
            }

            if settings.watermarkEnabled {
                VStack {
                    HStack {
                        Spacer()
                        Text(settings.watermarkTitle.isEmpty ? "Zone66" : settings.watermarkTitle)
                            .font(.system(size: 14, weight: .black)).foregroundColor(.white)
                            .padding(.horizontal, 16).padding(.vertical, 9)
                            .background(LinearGradient(colors: [themeManager.currentTheme.accentColor, .red], startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule()).shadow(radius: 6)
                            .padding(.top, 16).padding(.trailing, 20)
                    }
                    Spacer()
                }.ignoresSafeArea(.all, edges: .top)
            }

            if showControls {
                VStack {
                    HStack {
                        Button { player?.pause(); dismiss() } label: {
                            Label("إغلاق", systemImage: "xmark.circle.fill")
                                .foregroundColor(.white).padding(.horizontal, 14).padding(.vertical, 8)
                                .background(Color.black.opacity(0.6)).clipShape(Capsule())
                        }
                        Spacer()
                        Text(channel.name).font(.system(size: 16, weight: .bold)).foregroundColor(.white).lineLimit(1)
                        Spacer()
                        Button { repo.toggleFavorite(id: channel.id) } label: {
                            Image(systemName: repo.isFavorite(id: channel.id) ? "heart.fill" : "heart")
                                .font(.system(size: 20)).foregroundColor(repo.isFavorite(id: channel.id) ? .red : .white)
                                .padding(10).background(Color.black.opacity(0.6)).clipShape(Circle())
                        }
                    }.padding(.horizontal, 20).padding(.top, 16)

                    Spacer()

                    Button {
                        if isPlaying { player?.pause() } else { player?.play() }
                        isPlaying.toggle()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 26)).foregroundColor(.black)
                            .frame(width: 60, height: 60)
                            .background(themeManager.currentTheme.accentColor).clipShape(Circle())
                    }.padding(.bottom, 36)
                }
                .background(LinearGradient(colors: [Color.black.opacity(0.8), .clear, Color.black.opacity(0.85)], startPoint: .top, endPoint: .bottom).ignoresSafeArea())
            }
        }
        .onTapGesture { withAnimation(.easeInOut(duration: 0.25)) { showControls.toggle() } }
        .onAppear {
            if settings.autoPlay, let url = URL(string: channel.url) {
                let p = AVPlayer(url: url)
                player = p
                p.play()
            } else if let url = URL(string: channel.url) {
                player = AVPlayer(url: url)
            }
        }
        .onDisappear { player?.pause(); player = nil }
    }
}
