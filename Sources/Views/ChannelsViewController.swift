import UIKit

class ChannelsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    private var filteredChannels: [Channel] = []
    private let tableView = UITableView()
    private let searchController = UISearchController(searchResultsController: nil)
    private var selectedCategory: String = "الكل"

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "القنوات والبث"
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1.0)
        filteredChannels = ChannelRepository.shared.channels

        setupSearch()
        setupTable()
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "ابحث عن أي قناة..."
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func updateSearchResults(for searchController: UISearchController) {
        let q = searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if q.isEmpty {
            filteredChannels = ChannelRepository.shared.channels
        } else {
            filteredChannels = ChannelRepository.shared.channels.filter {
                $0.name.localizedCaseInsensitiveContains(q) || $0.category.localizedCaseInsensitiveContains(q)
            }
        }
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredChannels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor(white: 0.1, alpha: 0.6)
        cell.selectionStyle = .none

        let ch = filteredChannels[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = ch.name
        content.textProperties.color = .white
        content.textProperties.font = UIFont.boldSystemFont(ofSize: 15)
        content.secondaryText = "\(ch.category) • بث حي"
        content.secondaryTextProperties.color = .systemOrange
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12)
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ch = filteredChannels[indexPath.row]
        let p = PlayerViewController()
        p.channel = ch
        p.modalPresentationStyle = .fullScreen
        present(p, animated: true)
    }
}
