import UIKit
import AVFoundation
import AVKit

class PlayerViewController: UIViewController {
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private let logoImageView = UIImageView()
    private let urlField = UITextField()
    private let playButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private let controlsContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupControls()
        setupLogo()

        // البث الافتراضي للقناة
        let defaultUrl = "http://26.dragonpro.net:8080/live/980399222412/372838219650/743609.m3u8"
        urlField.text = defaultUrl
        playUrlString(defaultUrl)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = view.bounds
        view.bringSubviewToFront(logoImageView)
        view.bringSubviewToFront(controlsContainer)
    }

    private func setupLogo() {
        // إعداد لوغو القناة أعلى اليمين
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.clipsToBounds = true
        logoImageView.layer.shadowColor = UIColor.black.cgColor
        logoImageView.layer.shadowOpacity = 0.8
        logoImageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        logoImageView.layer.shadowRadius = 4

        // إذا وجدت صورة محلية باسم logo.png نستخدمها، وإلا نرسم شارة ZONE 66 أنيقة
        if let localLogo = UIImage(named: "logo") {
            logoImageView.image = localLogo
        } else {
            logoImageView.image = createTextBadge(text: "ZONE 66 TV")
        }

        view.addSubview(logoImageView)

        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            logoImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoImageView.widthAnchor.constraint(equalToConstant: 120),
            logoImageView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func createTextBadge(text: String) -> UIImage {
        let size = CGSize(width: 140, height: 48)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let rect = CGRect(origin: .zero, size: size)

        let path = UIBezierPath(roundedRect: rect, cornerRadius: 12)
        UIColor(red: 0.95, green: 0.45, blue: 0.0, alpha: 0.85).setFill()
        path.fill()

        let strokePath = UIBezierPath(roundedRect: rect.insetBy(dx: 1, dy: 1), cornerRadius: 11)
        UIColor.white.withAlphaComponent(0.4).setStroke()
        strokePath.lineWidth = 1.5
        strokePath.stroke()

        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 15),
            .foregroundColor: UIColor.white
        ]
        let textSize = (text as NSString).size(withAttributes: attrs)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        (text as NSString).draw(in: textRect, withAttributes: attrs)

        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }

    private func setupControls() {
        controlsContainer.translatesAutoresizingMaskIntoConstraints = false
        controlsContainer.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        controlsContainer.layer.cornerRadius = 16
        controlsContainer.layer.borderWidth = 1
        controlsContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        view.addSubview(controlsContainer)

        urlField.translatesAutoresizingMaskIntoConstraints = false
        urlField.placeholder = "ضع رابط البث هنا (.m3u8 أو .ts)..."
        urlField.textColor = .white
        urlField.font = UIFont.systemFont(ofSize: 13)
        urlField.backgroundColor = UIColor(white: 0.2, alpha: 0.7)
        urlField.layer.cornerRadius = 8
        urlField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        urlField.leftViewMode = .always
        urlField.autocapitalizationType = .none
        urlField.autocorrectionType = .no
        controlsContainer.addSubview(urlField)

        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.setTitle("تشغيل البث", for: .normal)
        playButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        playButton.backgroundColor = UIColor(red: 0.95, green: 0.45, blue: 0.0, alpha: 1.0)
        playButton.tintColor = .white
        playButton.layer.cornerRadius = 8
        playButton.addTarget(self, action: #selector(onPlayTapped), for: .touchUpInside)
        controlsContainer.addSubview(playButton)

        NSLayoutConstraint.activate([
            controlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            controlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            controlsContainer.heightAnchor.constraint(equalToConstant: 60),

            urlField.leadingAnchor.constraint(equalTo: controlsContainer.leadingAnchor, constant: 10),
            urlField.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            urlField.heightAnchor.constraint(equalToConstant: 40),

            playButton.leadingAnchor.constraint(equalTo: urlField.trailingAnchor, constant: 10),
            playButton.trailingAnchor.constraint(equalTo: controlsContainer.trailingAnchor, constant: -10),
            playButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 95),
            playButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        // نقرة على الشاشة لإخفاء/إظهار شريط الرابط
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleControls))
        view.addGestureRecognizer(tap)
    }

    @objc private func toggleControls() {
        UIView.animate(withDuration: 0.3) {
            self.controlsContainer.alpha = self.controlsContainer.alpha == 0 ? 1 : 0
        }
    }

    @objc private func onPlayTapped() {
        view.endEditing(true)
        if let text = urlField.text, !text.isEmpty {
            playUrlString(text)
        }
    }

    func playUrlString(_ raw: String) {
        var clean = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if clean.hasPrefix("zone66://") {
            clean = String(clean.dropFirst("zone66://".count))
        }
        guard let url = URL(string: clean) else { return }

        player?.pause()
        playerLayer?.removeFromSuperlayer()

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        let newLayer = AVPlayerLayer(player: newPlayer)
        newLayer.frame = view.bounds
        newLayer.videoGravity = .resizeAspect
        view.layer.insertSublayer(newLayer, at: 0)

        self.player = newPlayer
        self.playerLayer = newLayer

        newPlayer.play()
    }
}
