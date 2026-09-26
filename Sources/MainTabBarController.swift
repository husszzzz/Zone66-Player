import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = UIColor(red: 0.08, green: 0.08, blue: 0.09, alpha: 1.0)
        tabBar.tintColor = .systemOrange
        tabBar.unselectedItemTintColor = .gray

        let home = UINavigationController(rootViewController: HomeViewController())
        home.tabBarItem = UITabBarItem(title: "الرئيسية", image: UIImage(systemName: "house.fill"), tag: 0)

        let channels = UINavigationController(rootViewController: ChannelsViewController())
        channels.tabBarItem = UITabBarItem(title: "القنوات", image: UIImage(systemName: "tv.fill"), tag: 1)

        let fav = UINavigationController(rootViewController: FavoritesViewController())
        fav.tabBarItem = UITabBarItem(title: "المفضلة", image: UIImage(systemName: "heart.fill"), tag: 2)

        let settings = UINavigationController(rootViewController: SettingsViewController())
        settings.tabBarItem = UITabBarItem(title: "الإعدادات", image: UIImage(systemName: "gearshape.fill"), tag: 3)

        viewControllers = [home, channels, fav, settings]
    }
}
