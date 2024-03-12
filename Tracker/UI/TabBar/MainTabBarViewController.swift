//
//  MainTabBarViewController.swift
//  Tracker
//
//  Created by Dinara on 23.11.2023.
//

import UIKit

final class MainTabBarViewController: UITabBarController {

    // MARK: - Localized Strings
    private let trackersTabItemTitle = NSLocalizedString("trackersTabItemTitle", comment: "Text displayed on the Trackers TabBarItem")
    private let statisticsTabItemTitle = NSLocalizedString("statisticsTabItemTitle", comment: "Text displayed on the Statistics TabBarItem")


    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    private func setupTabBar() {
        view.backgroundColor = .systemBackground
        let tracker = UINavigationController(rootViewController: TrackersViewController())
        let statistics = UINavigationController(rootViewController: StatisticsViewController())
        tracker.tabBarItem = tabItem(for: .tracker, title: trackersTabItemTitle)
        statistics.tabBarItem = tabItem(for: .statistics, title: statisticsTabItemTitle)
        setViewControllers([tracker, statistics], animated: true)
        selectedIndex = 0

        tabBar.layer.borderWidth = 0.3
        tabBar.layer.borderColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.2).cgColor
    }

    private func tabItem(for type: TabItem, title: String) -> UITabBarItem {
        let item = UITabBarItem(title: title,
                                image: type.image,
                                selectedImage: type.selectedImage)
        return item
    }
}
