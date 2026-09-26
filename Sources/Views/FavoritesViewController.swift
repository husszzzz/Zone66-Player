import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var favorites: [Channel] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "المفضلة"
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1.0)
        setupTable()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favorites = ChannelRepository.shared.getFavorites()
        tableView.reloadData()
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "favCell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favCell", for: indexPath)
        cell.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
        let ch = favorites[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = ch.name
        content.textProperties.color = .white
        content.secondaryText = "♥ في المفضلة"
        content.secondaryTextProperties.color = .systemRed
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ch = favorites[indexPath.row]
        let p = PlayerViewController()
        p.channel = ch
        p.modalPresentationStyle = .fullScreen
        present(p, animated: true)
    }
}
