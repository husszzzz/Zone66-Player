import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "الإعدادات"
        view.backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.06, alpha: 1.0)
        setupUI()
    }

    private func setupUI() {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        let count = ChannelRepository.shared.channels.count
        stack.addArrangedSubview(createItem(title: "عدد القنوات المتوفرة", value: "\(count) قناة"))
        stack.addArrangedSubview(createItem(title: "إصدار التطبيق", value: "1.0.0 Pro"))
        stack.addArrangedSubview(createItem(title: "شعار القناة", value: "مدمج تلقائياً (ZONE 66)"))
        stack.addArrangedSubview(createItem(title: "طريقة التثبيت", value: "TrollStore (دائم)"))
    }

    private func createItem(title: String, value: String) -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.12, alpha: 0.8)
        v.layer.cornerRadius = 12
        v.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let t = UILabel()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.text = title
        t.textColor = .white
        t.font = UIFont.systemFont(ofSize: 15)
        v.addSubview(t)

        let val = UILabel()
        val.translatesAutoresizingMaskIntoConstraints = false
        val.text = value
        val.textColor = .systemOrange
        val.font = UIFont.boldSystemFont(ofSize: 14)
        v.addSubview(val)

        NSLayoutConstraint.activate([
            t.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -16),
            t.centerYAnchor.constraint(equalTo: v.centerYAnchor),
            val.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 16),
            val.centerYAnchor.constraint(equalTo: v.centerYAnchor)
        ])
        return v
    }
}
