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
    @State private var isMuted = false
    @State private var showControls = true
    @State private var playerController: AVPlayerViewController?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                CustomVideoPlayer(player: player, fillVideo: settings.fillVideo)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showControls.toggle()
                        }
                    }
            } else {
                VStack(spacing: 14) {
                    ProgressView()
                        .tint(theme.accent)
                        .scaleEffect(1.3)

                    Text("جاري الاتصال بالبث المباشر…")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.accent)
                }
            }

            // Controls Overlay
            if showControls {
                VStack {
                    topBar
                    Spacer()
                    bottomBar
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.85))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(channel.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("بث مباشر • ZH TEAM")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            // Favorite Button
            Button {
                repository.toggleFavorite(channel.id)
            } label: {
                Image(systemName: repository.isFavorite(channel.id) ? "heart.fill" : "heart")
                    .font(.system(size: 20))
                    .foregroundColor(repository.isFavorite(channel.id) ? .red : .white)
                    .padding(8)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            LinearGradient(colors: [Color.black.opacity(0.85), Color.clear], startPoint: .top, endPoint: .bottom)
        )
    }

    private var bottomBar: some View {
        HStack(spacing: 20) {
            // Play / Pause
            Button {
                if playing {
                    player?.pause()
                } else {
                    player?.play()
                }
                playing.toggle()
            } label: {
                Image(systemName: playing ? "pause.fill" : "play.fill")
                    .font(.system(size: 22))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(theme.accent)
                    .foregroundColor(.black)
                    .clipShape(Circle())
            }

            // Mute / Unmute
            Button {
                isMuted.toggle()
                player?.isMuted = isMuted
            } label: {
                Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer()

            // Picture in Picture hint
            HStack(spacing: 6) {
                Image(systemName: "pip.enter")
                    .font(.system(size: 16))
                    .foregroundColor(theme.accent)
                Text("دعم PiP مفعل")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.6))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
        .background(
            LinearGradient(colors: [Color.clear, Color.black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
        )
    }

    private func setupPlayer() {
        guard let url = URL(string: channel.streamURL) else { return }
        
        // Setup audio session for background playback and PiP
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession error: \(error)")
        }

        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.allowsExternalPlayback = true
        self.player = avPlayer

        if settings.autoPlay {
            avPlayer.play()
            playing = true
        }
    }
}

// UIViewControllerRepresentable using AVPlayerViewController to provide native PiP
struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    let fillVideo: Bool

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.allowsPictureInPicturePlayback = true
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        controller.videoGravity = fillVideo ? .resizeAspectFill : .resizeAspect
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
        uiViewController.videoGravity = fillVideo ? .resizeAspectFill : .resizeAspect
    }
}
