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
    @State private var isFillMode = false

    // HUD Feedback
    @State private var showHUD = false
    @State private var hudIcon = ""
    @State private var hudTitle = ""
    @State private var hudValue: Double = 0.5
    @State private var hudDismissWorkItem: DispatchWorkItem?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                CustomVideoPlayer(player: player, fillVideo: isFillMode)
                    .ignoresSafeArea()
                    .overlay(gestureOverlay)
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

            if showHUD {
                hudView
                    .transition(.opacity)
            }

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
            isFillMode = settings.fillVideo
            setupPlayer()
            repository.recordWatched(channel.id)
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    private var gestureOverlay: some View {
        GeometryReader { geo in
            Color.clear
                .contentShape(Rectangle())
                .gesture(
                    TapGesture(count: 2).onEnded {
                        isFillMode.toggle()
                        triggerHUD(icon: isFillMode ? "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left" : "aspectratio", title: isFillMode ? "ملء الشاشة" : "العرض الأصلي", value: isFillMode ? 1.0 : 0.0)
                    }
                    .exclusively(before: TapGesture(count: 1).onEnded {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showControls.toggle()
                        }
                    })
                )
                .gesture(
                    DragGesture(minimumDistance: 15)
                        .onChanged { val in
                            let isRight = val.startLocation.x > (geo.size.width / 2)
                            let delta = -Double(val.translation.height) / 300.0
                            if isRight {
                                let cur = Double(player?.volume ?? 1.0)
                                let nextVal = min(max(cur + delta * 0.05, 0.0), 1.0)
                                player?.volume = Float(nextVal)
                                isMuted = (nextVal == 0.0)
                                triggerHUD(icon: nextVal == 0 ? "speaker.slash.fill" : "speaker.wave.3.fill", title: "مستوى الصوت", value: nextVal)
                            } else {
                                let cur = Double(UIScreen.main.brightness)
                                let nextVal = min(max(cur + delta * 0.05, 0.0), 1.0)
                                UIScreen.main.brightness = CGFloat(nextVal)
                                triggerHUD(icon: "sun.max.fill", title: "السطوع", value: nextVal)
                            }
                        }
                )
        }
    }

    private var hudView: some View {
        VStack(spacing: 10) {
            Image(systemName: hudIcon)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(theme.accent)

            Text(hudTitle)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)

            ProgressView(value: hudValue, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: theme.accent))
                .frame(width: 120)
        }
        .padding(18)
        .background(Color.black.opacity(0.85))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(theme.accent.opacity(0.3), lineWidth: 1)
        )
    }

    private func triggerHUD(icon: String, title: String, value: Double) {
        hudIcon = icon
        hudTitle = title
        hudValue = value
        withAnimation { showHUD = true }

        hudDismissWorkItem?.cancel()
        let item = DispatchWorkItem {
            withAnimation { self.showHUD = false }
        }
        hudDismissWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: item)
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
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("بث نشط • ZH TEAM")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

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
        HStack(spacing: 16) {
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
                    .frame(width: 44, height: 44)
                    .background(theme.accent)
                    .foregroundColor(.black)
                    .clipShape(Circle())
            }

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

            Button {
                isFillMode.toggle()
                triggerHUD(icon: isFillMode ? "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left" : "aspectratio", title: isFillMode ? "ملء الشاشة" : "العرض الأصلي", value: isFillMode ? 1.0 : 0.0)
            } label: {
                Image(systemName: isFillMode ? "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left" : "aspectratio")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isFillMode ? theme.accent : .white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "pip.enter")
                    .font(.system(size: 16))
                    .foregroundColor(theme.accent)
                Text("PiP مفعّل")
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
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession error")
        }

        let playerItem = AVPlayerItem(url: url)
        let avPlayer = AVPlayer(playerItem: playerItem)
        avPlayer.allowsExternalPlayback = true
        self.player = avPlayer

        if settings.autoPlay {
            avPlayer.play()
            playing = true
        }

        // Auto reconnect notification on stall
        NotificationCenter.default.addObserver(forName: .AVPlayerItemPlaybackStalled, object: playerItem, queue: .main) { _ in
            if self.settings.autoReconnect {
                self.player?.play()
            }
        }
    }
}

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
