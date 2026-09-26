import UIKit
import AVFoundation
import AVKit

class PlayerViewController: UIViewController {
    var channel: Channel?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let logoImageView = UIImageView()
    private let overlayControls = UIView()
    private let titleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let playPauseButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    private let statusIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupPlayer()
        setupLogo()
        setupControls()

        if let ch = channel {
            play(channel: ch)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
        view.bringSubviewToFront(logoImageView)
        view.bringSubviewToFront(overlayControls)
    }

    private func setupLogo() {
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = createWatermarkLogo()
        logoImageView.layer.shadowColor = UIColor.black.cgColor
        logoImageView.layer.shadowOpacity = 0.85
        logoImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoImageView.layer.shadowRadius = 6
        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            logoImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoImageView.widthAnchor.constraint(equalToConstant: 130),
            logoImageView.heightAnchor.constraint(equalToConstant: 42)
        ])
    }

    private func createWatermarkLogo() -> UIImage {
        let size = CGSize(width: 140, height: 44)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let rect = CGRect(origin: .zero, size: size)

        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        UIColor(red: 0.95, green: 0.45, blue: 0.0, alpha: 0.85).setFill()
        path.fill()

        let stroke = UIBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 9)
        UIColor.white.withAlphaComponent(0.35).setStroke()
        stroke.lineWidth = 1.2
        stroke.stroke()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.white
        ]
        let text: NSString = "ZONE 66 TV"
        let textSize = text.size(withAttributes: attrs)
        let tr = CGRect(
            x: (size.width - textSize.width)/2,
            y: (size.height - textSize.height)/2,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: tr, withAttributes: attrs)

        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }

    private func setupPlayer() {
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        statusIndicator.color = .systemOrange
        statusIndicator.hidesWhenStopped = true
        view.addSubview(statusIndicator)
        NSLayoutConstraint.activate([
            statusIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupControls() {
        overlayControls.translatesAutoresizingMaskIntoConstraints = false
        overlayControls.backgroundColor = UIColor(white: 0, alpha: 0.6)
        view.addSubview(overlayControls)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("✕ إغلاق", for: .normal)
        backButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        backButton.tintColor = .white
        backButton.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        backButton.layer.cornerRadius = 10
        backButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        backButton.addTarget(self, action: #selector(dismissPlayer), for: .touchUpInside)
        overlayControls.addSubview(backButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        overlayControls.addSubview(titleLabel)

        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.setTitle("❚❚ إيقاف", for: .normal)
        playPauseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        playPauseButton.tintColor = .white
        playPauseButton.backgroundColor = UIColor(red: 0.95, green: 0.45, blue: 0.0, alpha: 0.9)
        playPauseButton.layer.cornerRadius = 10
        playPauseButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 18, bottom: 8, right: 18)
        playPauseButton.addTarget(self, action: #selector(togglePlay), for: .touchUpInside)
        overlayControls.addSubview(playPauseButton)

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setTitle("♥ مفضلة", for: .normal)
        favoriteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        favoriteButton.tintColor = .systemRed
        favoriteButton.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        favoriteButton.layer.cornerRadius = 10
        favoriteButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        favoriteButton.addTarget(self, action: #selector(toggleFav), for: .touchUpInside)
        overlayControls.addSubview(favoriteButton)

        NSLayoutConstraint.activate([
            overlayControls.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayControls.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayControls.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            overlayControls.heightAnchor.constraint(equalToConstant: 110),

            backButton.leadingAnchor.constraint(equalTo: overlayControls.leadingAnchor, constant: 18),
            backButton.topAnchor.constraint(equalTo: overlayControls.topAnchor, constant: 12),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: overlayControls.trailingAnchor, constant: -18),

            playPauseButton.centerXAnchor.constraint(equalTo: overlayControls.centerXAnchor),
            playPauseButton.bottomAnchor.constraint(equalTo: overlayControls.safeAreaLayoutGuide.bottomAnchor, constant: -12),

            favoriteButton.trailingAnchor.constraint(equalTo: overlayControls.trailingAnchor, constant: -18),
            favoriteButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleOverlay))
        view.addGestureRecognizer(tap)
    }

    @objc private func toggleOverlay() {
        UIView.animate(withDuration: 0.25) {
            self.overlayControls.alpha = self.overlayControls.alpha == 0 ? 1 : 0
        }
    }

    @objc private func dismissPlayer() {
        player?.pause()
        dismiss(animated: true)
    }

    @objc private func togglePlay() {
        guard let p = player else { return }
        if p.timeControlStatus == .playing {
            p.pause()
            playPauseButton.setTitle("▶ تشغيل", for: .normal)
        } else {
            p.play()
            playPauseButton.setTitle("❚❚ إيقاف", for: .normal)
        }
    }

    @objc private func toggleFav() {
        guard let ch = channel else { return }
        ChannelRepository.shared.toggleFavorite(channel: ch)
        updateFavBtn()
    }

    private func updateFavBtn() {
        guard let ch = channel else { return }
        let isFav = ChannelRepository.shared.isFavorite(channel: ch)
        favoriteButton.setTitle(isFav ? "♥ بالمفضلة" : "♡ إضافة", for: .normal)
    }

    func play(channel: Channel) {
        self.channel = channel
        titleLabel.text = channel.name
        updateFavBtn()

        statusIndicator.startAnimating()
        player?.pause()
        playerLayer?.removeFromSuperlayer()

        guard let url = URL(string: channel.url) else { return }
        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        let newLayer = AVPlayerLayer(player: newPlayer)
        newLayer.frame = view.bounds
        newLayer.videoGravity = .resizeAspect
        view.layer.insertSublayer(newLayer, at: 0)

        self.player = newPlayer
        self.playerLayer = newLayer

        newPlayer.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.statusIndicator.stopAnimating()
        }
    }
}
