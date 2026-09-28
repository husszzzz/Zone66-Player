import SwiftUI
import AVKit

struct PlayerView: View {
    let channel: Zone66Channel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: Zone66Settings
    @EnvironmentObject var repository: ChannelRepository
    @EnvironmentObject var theme: Zone66Theme
    @ObservedObject var loc = LocalizationManager.shared

    @State private var player: AVPlayer? = nil
    @State private var isPlaying: Bool = true
    @State private var showControls: Bool = true
    @State private var isMuted: Bool = false
    @State private var aspectRatio: AVLayerVideoGravity = .resizeAspect
    @State private var isScreenLocked: Bool = false
    @State private var showQuickChannels: Bool = false
    @State private var volume: Float = 0.5
    @State private var brightness: CGFloat = UIScreen.main.brightness
    @State private var showHUD: Bool = false
    @State private var hudIcon: String = ""
    @State private var hudValue: Float = 0.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Video Player Core
            if let player = player {
                CustomVideoPlayer(player: player, videoGravity: aspectRatio)
                    .ignoresSafeArea()
                    .onTapGesture {
                        if !isScreenLocked {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showControls.toggle()
                            }
                        }
                    }
                    .onTapGesture(count: 2) {
                        if !isScreenLocked {
                            toggleAspectRatio()
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isScreenLocked {
                                    handleDrag(value)
                                }
                            }
                            .onEnded { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    showHUD = false
                                }
                            }
                    )
            }

            // HUD for Volume / Brightness
            if showHUD && !isScreenLocked {
                hudView
            }

            // Screen Lock Active floating badge
            if isScreenLocked {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.spring()) {
                                isScreenLocked = false
                                showControls = true
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.open.fill")
                                Text(loc.tr("unlock"))
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.black.opacity(0.75))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(theme.accent, lineWidth: 1.5))
                            .shadow(color: theme.accent.opacity(0.4), radius: 8)
                        }
                        .padding(.top, 40)
                        .padding(.trailing, 20)
                    }
                    Spacer()
                }
            }

            // Normal On-Screen Controls Overlay
            if showControls && !isScreenLocked {
                controlsOverlay
            }

            // Quick Channels Drawer (Side Drawer)
            if showQuickChannels && !isScreenLocked {
                quickChannelsDrawer
            }
        }
        .onAppear {
            setupPlayer(with: channel.streamURL)
            repository.recordWatched(channel.id)
        }
        .onDisappear {
            player?.pause()
            player = nil
        }
    }

    // MARK: - Controls Overlay
    private var controlsOverlay: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack {
                // Top Bar
                HStack(spacing: 14) {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(channel.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(channel.category)
                            .font(.system(size: 12))
                            .foregroundColor(theme.accent)
                    }

                    Spacer()

                    // Quick Channels List Button
                    Button {
                        withAnimation(.spring()) {
                            showQuickChannels.toggle()
                        }
                    } label: {
                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                            .font(.system(size: 18))
                            .foregroundColor(theme.accent)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }

                    // Touch Lock Button
                    Button {
                        withAnimation(.spring()) {
                            isScreenLocked = true
                            showControls = false
                        }
                    } label: {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 30)

                Spacer()

                // Center Play/Pause & Fast Actions
                HStack(spacing: 40) {
                    Button {
                        isMuted.toggle()
                        player?.isMuted = isMuted
                    } label: {
                        Image(systemName: isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }

                    Button {
                        togglePlay()
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.black)
                            .padding(22)
                            .background(theme.accent)
                            .clipShape(Circle())
                            .shadow(color: theme.accent.opacity(0.6), radius: 10)
                    }

                    Button {
                        toggleAspectRatio()
                    } label: {
                        Image(systemName: aspectRatio == .resizeAspect ? "viewfinder" : "arrow.up.left.and.down.right.and.arrow.up.right.and.down.left")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .padding(14)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }

                Spacer()

                // Bottom Status
                HStack {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                        Text(loc.tr("live_now"))
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)

                    Spacer()

                    Text("ZH TEAM PLAYER")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Quick Channels Drawer
    private var quickChannelsDrawer: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(loc.tr("quick_channels"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Button {
                        withAnimation { showQuickChannels = false }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 8)

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 8) {
                        ForEach(repository.enabledChannels.prefix(25)) { ch in
                            Button {
                                switchChannel(ch)
                            } label: {
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(ch.id == channel.id ? theme.accent : Color.white.opacity(0.2))
                                        .frame(width: 8, height: 8)

                                    Text(ch.name)
                                        .font(.system(size: 13, weight: ch.id == channel.id ? .bold : .medium))
                                        .foregroundColor(ch.id == channel.id ? theme.accent : .white)
                                        .lineLimit(1)

                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(ch.id == channel.id ? Color.white.opacity(0.12) : Color.white.opacity(0.04))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .frame(width: 260)
            .background(Color.black.opacity(0.92).ignoresSafeArea())
            .overlay(
                Rectangle()
                    .frame(width: 1)
                    .foregroundColor(theme.accent.opacity(0.3)),
                alignment: .leading
            )
        }
        .transition(.move(edge: .trailing))
    }

    // MARK: - HUD
    private var hudView: some View {
        VStack(spacing: 8) {
            Image(systemName: hudIcon)
                .font(.system(size: 28))
                .foregroundColor(theme.accent)
            ProgressView(value: hudValue)
                .progressViewStyle(LinearProgressViewStyle(tint: theme.accent))
                .frame(width: 100)
        }
        .padding(16)
        .background(Color.black.opacity(0.8))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(theme.accent.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Helpers
    private func setupPlayer(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.automaticallyWaitsToMinimizeStalling = !settings.lowLatencyMode
        self.player = newPlayer
        newPlayer.play()
        self.isPlaying = true
    }

    private func switchChannel(_ newCh: Zone66Channel) {
        showQuickChannels = false
        player?.pause()
        setupPlayer(with: newCh.streamURL)
        repository.recordWatched(newCh.id)
    }

    private func togglePlay() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
    }

    private func toggleAspectRatio() {
        withAnimation {
            aspectRatio = (aspectRatio == .resizeAspect) ? .resizeAspectFill : .resizeAspect
        }
    }

    private func handleDrag(_ value: DragGesture.Value) {
        let screenWidth = UIScreen.main.bounds.width
        let isRightSide = value.startLocation.x > screenWidth / 2
        let translation = -value.translation.height / 200.0

        if isRightSide {
            volume = max(0.0, min(1.0, volume + Float(translation) * 0.05))
            player?.volume = volume
            hudIcon = volume == 0 ? "speaker.slash.fill" : "speaker.wave.2.fill"
            hudValue = volume
        } else {
            brightness = max(0.0, min(1.0, brightness + translation * 0.05))
            UIScreen.main.brightness = brightness
            hudIcon = "sun.max.fill"
            hudValue = Float(brightness)
        }
        showHUD = true
    }
}

struct CustomVideoPlayer: UIViewControllerRepresentable {
    let player: AVPlayer
    let videoGravity: AVLayerVideoGravity

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = videoGravity
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.videoGravity = videoGravity
    }
}
