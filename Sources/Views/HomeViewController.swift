import UIKit

class HomeViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "الرئيسية"
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1.0)
        navigationController?.navigationBar.prefersLargeTitles = true
        setupUI()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 20
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        // Hero Card
        let hero = createHeroCard()
        contentView.addArrangedSubview(hero)

        // Section Title: القنوات الأكثر مشاهدة
        let sportsTitle = createSectionTitle(title: "⚡ قنوات رياضية مميزة")
        contentView.addArrangedSubview(sportsTitle)

        let sportsChannels = ChannelRepository.shared.channels.filter { $0.category == "رياضة" }.prefix(8)
        for ch in sportsChannels {
            let row = createChannelCard(channel: ch)
            contentView.addArrangedSubview(row)
        }
    }

    private func createHeroCard() -> UIView {
        let card = UIView()
        card.backgroundColor = UIColor(red: 0.12, green: 0.07, blue: 0.03, alpha: 1.0)
        card.layer.cornerRadius = 20
        card.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.4).cgColor
        card.layer.borderWidth = 1.5

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "مرحباً بك في ZONE 66 TV"
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = .white
        title.textAlignment = .right
        card.addSubview(title)

        let sub = UILabel()
        sub.translatesAutoresizingMaskIntoConstraints = false
        sub.text = "شاهد أكثر من 670 قناة مباشرة بدون تقطيع مع اللوغو الرسمي"
        sub.font = UIFont.systemFont(ofSize: 13)
        sub.textColor = .lightGray
        sub.numberOfLines = 2
        sub.textAlignment = .right
        card.addSubview(sub)

        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("مشاهدة بث BeIN SPORTS 1", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.backgroundColor = .systemOrange
        btn.tintColor = .black
        btn.layer.cornerRadius = 12
        btn.addTarget(self, action: #selector(playHeroChannel), for: .touchUpInside)
        card.addSubview(btn)

        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 160),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            sub.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            sub.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            sub.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),

            btn.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            btn.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            btn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            btn.heightAnchor.constraint(equalToConstant: 44)
        ])
        return card
    }

    private func createSectionTitle(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.textAlignment = .right
        return label
    }

    private func createChannelCard(channel: Channel) -> UIView {
        let card = UIButton(type: .system)
        card.backgroundColor = UIColor(white: 0.12, alpha: 0.8)
        card.layer.cornerRadius = 14
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
        card.heightAnchor.constraint(equalToConstant: 60).isActive = true

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = channel.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .right
        card.addSubview(nameLabel)

        let liveBadge = UILabel()
        liveBadge.translatesAutoresizingMaskIntoConstraints = false
        liveBadge.text = "● مباشر"
        liveBadge.font = UIFont.boldSystemFont(ofSize: 11)
        liveBadge.textColor = .systemRed
        card.addSubview(liveBadge)

        NSLayoutConstraint.activate([
            nameLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            nameLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            liveBadge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            liveBadge.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        card.addAction(UIAction { [weak self] _ in
            let p = PlayerViewController()
            p.channel = channel
            p.modalPresentationStyle = .fullScreen
            self?.present(p, animated: true)
        }, for: .touchUpInside)

        return card
    }

    @objc private func playHeroChannel() {
        if let first = ChannelRepository.shared.channels.first {
            let p = PlayerViewController()
            p.channel = first
            p.modalPresentationStyle = .fullScreen
            present(p, animated: true)
        }
    }
}
