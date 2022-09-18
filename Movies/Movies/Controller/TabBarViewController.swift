import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if let mainItem = self.tabBar.items?[0] {
            mainItem.title = "Movies".localized()
        }

        if let favoritesItem = self.tabBar.items?[1] {
            favoritesItem.title = "Favorites".localized()
        }

        if let castsItem = self.tabBar.items?[2]{
            castsItem.title = "Casts".localized()
        }
    }

}
